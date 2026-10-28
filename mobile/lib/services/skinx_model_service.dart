import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/screening_result.dart';
import 'screening_decision_policy.dart';

const _modelInputSize = 224;

List<List<List<double>>> _preprocess(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null || decoded.numFrames != 1) {
    throw const FormatException('Cannot read this photo. Please choose another JPEG or PNG.');
  }
  final image = img.bakeOrientation(decoded);
  if (image.width < 32 || image.height < 32 ||
      image.width * image.height > 20000000) {
    throw const FormatException('Unsupported image dimensions.');
  }
  var minBrightness = 255.0;
  var maxBrightness = 0.0;
  var brightnessTotal = 0.0;
  var sampled = 0;
  for (var y = 0; y < image.height; y += math.max(1, image.height ~/ 40)) {
    for (var x = 0; x < image.width; x += math.max(1, image.width ~/ 40)) {
      final color = image.getPixel(x, y);
      final value = (color.r + color.g + color.b) / 3.0;
      minBrightness = math.min(minBrightness, value);
      maxBrightness = math.max(maxBrightness, value);
      brightnessTotal += value;
      sampled++;
    }
  }
  final average = brightnessTotal / sampled;
  if (average < 8 || average > 248 || maxBrightness - minBrightness < 4) {
    throw const FormatException('This photo is too dark, too bright or has too little visible detail. Take another photo in even light.');
  }
  const target = _modelInputSize;
  final scale = math.min(target / image.width, target / image.height);
  final w = math.max(1, (image.width * scale).round());
  final h = math.max(1, (image.height * scale).round());
  final resized = img.copyResize(image, width: w, height: h,
      interpolation: img.Interpolation.linear);
  final left = (target - w) ~/ 2;
  final top = (target - h) ~/ 2;
  final canvas = img.Image(width: target, height: target, numChannels: 3);
  img.fill(canvas, color: img.ColorRgb8(0, 0, 0));
  img.compositeImage(canvas, resized, dstX: left, dstY: top);
  return List.generate(target, (y) => List.generate(target, (x) {
    final p = canvas.getPixel(x, y);
    return <double>[p.r.toDouble(), p.g.toDouble(), p.b.toDouble()];
  }));
}

List<int> _heatColor(double value) {
  final t = value.clamp(0.0, 1.0).toDouble();
  if (t < 1 / 3) {
    final f = t * 3;
    return [0, (255 * f).round(), 255];
  }
  if (t < 2 / 3) {
    final f = (t - 1 / 3) * 3;
    return [(255 * f).round(), 255, (255 * (1 - f)).round()];
  }
  final f = (t - 2 / 3) * 3;
  return [255, (255 * (1 - f)).round(), 0];
}

Uint8List _buildHeatmapOverlay(Map<String, dynamic> arguments) {
  final bytes = arguments['bytes'] as Uint8List;
  final values = (arguments['cam_values'] as List)
      .map((value) => (value as num).toDouble()).toList();
  final mapHeight = arguments['cam_height'] as int;
  final mapWidth = arguments['cam_width'] as int;
  if (values.length != mapHeight * mapWidth || values.isEmpty) {
    throw const FormatException('The model explanation map has an unexpected size.');
  }

  final decoded = img.decodeImage(bytes);
  if (decoded == null || decoded.numFrames != 1) {
    throw const FormatException('Cannot decode the original photo for the explanation overlay.');
  }
  final original = img.bakeOrientation(decoded);
  final maximum = values.reduce((a, b) => a > b ? a : b);
  if (!maximum.isFinite || maximum <= 1e-12) {
    throw const FormatException('The model did not produce a usable explanation map.');
  }

  final smallMap = img.Image(width: mapWidth, height: mapHeight, numChannels: 3);
  for (var y = 0; y < mapHeight; y++) {
    for (var x = 0; x < mapWidth; x++) {
      final normalized = (values[y * mapWidth + x] / maximum).clamp(0.0, 1.0).toDouble();
      final gray = (normalized * 255).round();
      smallMap.setPixel(x, y, img.ColorRgb8(gray, gray, gray));
    }
  }

  // Reverse the model's centered resize-and-pad step before resizing the map to the photo.
  final scale = math.min(_modelInputSize / original.width, _modelInputSize / original.height);
  final resizedWidth = math.max(1, (original.width * scale).round());
  final resizedHeight = math.max(1, (original.height * scale).round());
  final left = (_modelInputSize - resizedWidth) ~/ 2;
  final top = (_modelInputSize - resizedHeight) ~/ 2;
  final squareMap = img.copyResize(smallMap, width: _modelInputSize, height: _modelInputSize,
      interpolation: img.Interpolation.linear);
  final contentMap = img.copyCrop(squareMap, x: left, y: top,
      width: resizedWidth, height: resizedHeight);
  final displayScale = math.min(1.0, 1280 / math.max(original.width, original.height));
  final displayWidth = math.max(1, (original.width * displayScale).round());
  final displayHeight = math.max(1, (original.height * displayScale).round());
  final displayOriginal = img.copyResize(original, width: displayWidth, height: displayHeight,
      interpolation: img.Interpolation.linear);
  final photoMap = img.copyResize(contentMap, width: displayWidth, height: displayHeight,
      interpolation: img.Interpolation.linear);

  final composite = img.Image(width: displayWidth, height: displayHeight, numChannels: 3);
  for (var y = 0; y < displayHeight; y++) {
    for (var x = 0; x < displayWidth; x++) {
      final basePixel = displayOriginal.getPixel(x, y);
      final heatValue = (photoMap.getPixel(x, y).r / 255.0).clamp(0.0, 1.0).toDouble();
      if (heatValue < 0.15) {
        composite.setPixel(x, y, img.ColorRgb8(
          basePixel.r.toInt(), basePixel.g.toInt(), basePixel.b.toInt()));
        continue;
      }
      final intensity = ((heatValue - 0.15) / 0.85).clamp(0.0, 1.0).toDouble();
      final heat = _heatColor(intensity);
      final alpha = 0.55 * intensity;
      final red = (basePixel.r * (1 - alpha) + heat[0] * alpha).round().clamp(0, 255).toInt();
      final green = (basePixel.g * (1 - alpha) + heat[1] * alpha).round().clamp(0, 255).toInt();
      final blue = (basePixel.b * (1 - alpha) + heat[2] * alpha).round().clamp(0, 255).toInt();
      composite.setPixel(x, y, img.ColorRgb8(red, green, blue));
    }
  }
  return Uint8List.fromList(img.encodePng(composite));
}

class SkinXModelService {
  static const _model = 'assets/models/skinx_screening.tflite';
  static const _config = 'assets/models/skinx_model_config.json';
  static const _camModel = 'assets/models/skinx_screening_cam.tflite';
  static const _camConfig = 'assets/models/skinx_cam_model_config.json';

  Interpreter? _interpreter;
  IsolateInterpreter? _worker;
  late double _threshold;
  int _outputElements = 1;
  int _camHeight = 0;
  int _camWidth = 0;
  bool _camEnabled = false;
  bool _uncertaintyAbstentionEnabled = false;
  double _uncertaintyMargin = 0.0;

  Future<void> load() async {
    if (_interpreter != null) return;
    try {
      await _loadModel(modelAsset: _camModel, configAsset: _camConfig, expectCam: true);
      debugPrint('SkinX: loaded the offline CAM explanation model.');
      return;
    } catch (error) {
      debugPrint('SkinX: CAM model unavailable; using the screening-only model ($error).');
    }
    await _loadModel(modelAsset: _model, configAsset: _config, expectCam: false);
  }

  Future<void> _loadModel({
    required String modelAsset,
    required String configAsset,
    required bool expectCam,
  }) async {
    final settings = jsonDecode(await rootBundle.loadString(configAsset)) as Map<String, dynamic>;
    final shape = (settings['input_shape'] as List).cast<int>();
    if (shape.join(',') != '1,224,224,3' ||
        settings['input_dtype'] != 'float32' ||
        settings['output_dtype'] != 'float32' ||
        settings['external_normalization'] != 'NONE; pixel values are float32 0..255 before tensor quantization') {
      throw const FormatException('Unsupported SkinX model configuration.');
    }

    final threshold = (settings['target_probability_threshold'] as num).toDouble();
    final uncertaintyEnabled = settings['uncertainty_abstention_enabled'] == true;
    final uncertaintyMargin = (settings['uncertainty_margin'] as num?)?.toDouble() ?? 0.0;
    if (!threshold.isFinite || threshold <= 0 || threshold >= 1) {
      throw const FormatException('The screening threshold is invalid.');
    }
    if (!uncertaintyMargin.isFinite || uncertaintyMargin < 0 ||
        (uncertaintyEnabled && (uncertaintyMargin <= 0 ||
            uncertaintyMargin >= threshold || uncertaintyMargin >= 1 - threshold))) {
      throw const FormatException('The screening uncertainty margin is invalid.');
    }
    final interpreter = await Interpreter.fromAsset(modelAsset,
        options: InterpreterOptions()..threads = 2);
    IsolateInterpreter? worker;
    try {
      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;
      if (inputShape.join(',') != shape.join(',')) {
        throw const FormatException('The screening model input does not match its configuration.');
      }

      var outputElements = 1;
      var camHeight = 0;
      var camWidth = 0;
      if (expectCam) {
        final cam = settings['cam'] as Map<String, dynamic>;
        camHeight = (cam['height'] as num).toInt();
        camWidth = (cam['width'] as num).toInt();
        outputElements = 1 + camHeight * camWidth;
        if (cam['enabled'] != true ||
            cam['output_layout'] != 'target_score_then_row_major_cam' ||
            outputShape.join(',') != '1,$outputElements') {
          throw const FormatException('The CAM output does not match its configuration.');
        }
      } else if (outputShape.join(',') != '1,1') {
        throw const FormatException('The screening model output does not match its configuration.');
      }

      worker = await IsolateInterpreter.create(address: interpreter.address);
      _interpreter = interpreter;
      _worker = worker;
      _threshold = threshold;
      _uncertaintyAbstentionEnabled = uncertaintyEnabled;
      _uncertaintyMargin = uncertaintyMargin;
      _outputElements = outputElements;
      _camHeight = camHeight;
      _camWidth = camWidth;
      _camEnabled = expectCam;
    } catch (_) {
      await worker?.close();
      interpreter.close();
      rethrow;
    }
  }

  Future<ScreeningResult> screen(Uint8List bytes) async {
    if (bytes.isEmpty) return ScreeningResult.failed('The selected image is empty.');
    if (bytes.length > 12582912) return ScreeningResult.failed('The photo is too large (maximum 12 MB).');
    final jpeg = bytes.length >= 3 && bytes[0] == 0xff && bytes[1] == 0xd8 && bytes[2] == 0xff;
    final png = bytes.length >= 8 && bytes[0] == 137 && bytes[1] == 80 &&
        bytes[2] == 78 && bytes[3] == 71;
    if (!jpeg && !png) return ScreeningResult.failed('Only JPEG or PNG images are supported.');
    try {
      await load();
      final pixels = await compute(_preprocess, bytes);
      final output = [List<double>.filled(_outputElements, 0.0)];
      await _worker!.run([pixels], output);
      final probability = output[0][0];
      if (!probability.isFinite || probability < 0 || probability > 1) {
        return ScreeningResult.failed('The model did not return a valid score.');
      }

      final decision = ScreeningDecisionPolicy.classify(
        targetProbability: probability,
        threshold: _threshold,
        uncertaintyMargin: _uncertaintyMargin,
        uncertaintyAbstentionEnabled: _uncertaintyAbstentionEnabled,
      );
      if (decision == ScreeningDecision.cannotInfer) {
        return ScreeningResult.borderline(
          targetProbability: probability,
          decisionThreshold: _threshold,
          uncertaintyLowerBoundary: math.max(0.0, _threshold - _uncertaintyMargin),
          uncertaintyUpperBoundary: math.min(1.0, _threshold + _uncertaintyMargin),
        );
      }

      Uint8List? explanationImageBytes;
      if (_camEnabled && _camHeight > 0 && _camWidth > 0) {
        final camValues = output[0].sublist(1);
        if (camValues.length == _camHeight * _camWidth && camValues.every((value) => value.isFinite)) {
          try {
            explanationImageBytes = await compute(_buildHeatmapOverlay, <String, dynamic>{
              'bytes': bytes,
              'cam_values': camValues,
              'cam_height': _camHeight,
              'cam_width': _camWidth,
            });
          } catch (error) {
            debugPrint('SkinX: heatmap overlay could not be created ($error).');
          }
        }
      }

      if (decision == ScreeningDecision.suspicious) {
        return ScreeningResult(
          status: ScreeningResult.suspicious,
          targetProbability: probability,
          decisionThreshold: _threshold,
          explanationImageBytes: explanationImageBytes,
          message: 'This image has a suspicious pattern. Please seek a clinical assessment. SkinX is not a diagnosis.',
        );
      }
      return ScreeningResult(
        status: ScreeningResult.lessSuspicious,
        targetProbability: probability,
        decisionThreshold: _threshold,
        explanationImageBytes: explanationImageBytes,
        message: 'This does not rule out skin cancer. Have any growing, bleeding, changing or non-healing lesion checked by a health professional.',
      );
    } on FormatException catch (e) {
      return ScreeningResult.failed(e.message);
    } catch (_) {
      return ScreeningResult.failed('Screening could not finish on this device. Please try again.');
    }
  }

  Future<void> close() async {
    await _worker?.close();
    _interpreter?.close();
    _worker = null;
    _interpreter = null;
    _camEnabled = false;
    _uncertaintyAbstentionEnabled = false;
    _uncertaintyMargin = 0.0;
    _outputElements = 1;
    _camHeight = 0;
    _camWidth = 0;
  }
}
