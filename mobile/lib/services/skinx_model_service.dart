import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/screening_result.dart';

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
  const target = 224;
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

class SkinXModelService {
  static const _model = 'assets/models/skinx_screening.tflite';
  static const _config = 'assets/models/skinx_model_config.json';
  Interpreter? _interpreter;
  IsolateInterpreter? _worker;
  late double _threshold;

  Future<void> load() async {
    if (_interpreter != null) return;
    final settings = jsonDecode(await rootBundle.loadString(_config)) as Map<String, dynamic>;
    final shape = (settings['input_shape'] as List).cast<int>();
    if (settings['selected_variant'] != 'float16' ||
        shape.join(',') != '1,224,224,3' ||
        settings['input_dtype'] != 'float32' ||
        settings['output_dtype'] != 'float32' ||
        settings['external_normalization'] != 'NONE; pixel values are float32 0..255 before tensor quantization') {
      throw const FormatException('Unsupported SkinX model configuration.');
    }
    _threshold = (settings['target_probability_threshold'] as num).toDouble();
    final interpreter = await Interpreter.fromAsset(_model, options: InterpreterOptions()..threads = 2);
    if (interpreter.getInputTensor(0).shape.join(',') != shape.join(',') ||
        interpreter.getOutputTensor(0).shape.join(',') != '1,1') {
      interpreter.close();
      throw const FormatException('The screening model input or output does not match its configuration.');
    }
    _interpreter = interpreter;
    _worker = await IsolateInterpreter.create(address: interpreter.address);
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
      final output = [<double>[0.0]];
      await _worker!.run([pixels], output);
      final probability = output[0][0];
      if (!probability.isFinite || probability < 0 || probability > 1) {
        return ScreeningResult.failed('The model did not return a valid score.');
      }
      if (probability >= _threshold) {
        return ScreeningResult(
          status: ScreeningResult.suspicious,
          targetProbability: probability,
          message: 'This image has a suspicious pattern. Please seek a clinical assessment. SkinX is not a diagnosis.',
        );
      }
      return ScreeningResult(
        status: ScreeningResult.lessSuspicious,
        targetProbability: probability,
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
  }
}
