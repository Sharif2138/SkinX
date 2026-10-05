import 'package:flutter/material.dart';

import 'widgets/skinx_header.dart';
import 'widgets/skinx_icon.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF8C9D9B);
const _inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(color: Color(0xFFE6ECE4)),
);

class ScreeningScreen extends StatelessWidget {
  const ScreeningScreen({
    super.key,
    this.initialPatientName = 'Sharif Kiviiri',
    this.onPatientNameChanged,
    this.onTakePhoto,
    this.onUploadPhoto,
    this.onScreenPhoto,
    this.onChangePhoto,
    this.photo,
    this.isIllustrativePhoto = false,
    this.languageCode = 'EN',
    this.onLanguageTap,
  });

  final String initialPatientName;
  final ValueChanged<String>? onPatientNameChanged;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onUploadPhoto;
  final VoidCallback? onScreenPhoto;
  final VoidCallback? onChangePhoto;
  // Supply a MemoryImage, FileImage or another ImageProvider after selection.
  final ImageProvider<Object>? photo;
  // Use true for a sample photo to show the reference's illustrative badge.
  final bool isIllustrativePhoto;
  final String languageCode;
  final VoidCallback? onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // A centered form keeps the same proportions on larger screens.
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              photo == null ? 20 : 24,
              16,
              photo == null ? 20 : 24,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkinXHeader(
                  languageCode: languageCode,
                  onLanguageTap: onLanguageTap,
                ),
                SizedBox(height: photo == null ? 30 : 18),
                Text(
                  'Screen a skin change',
                  style: _textStyle(24, weight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check a skin change, step by step.',
                  style: _textStyle(14, color: _muted, height: 1.4),
                ),
                const SizedBox(height: 20),
                Text(
                  'Patient name',
                  style: _textStyle(13, weight: FontWeight.w600, height: 1.3),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Patient name',
                  child: TextFormField(
                    initialValue: initialPatientName,
                    onChanged: onPatientNameChanged,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    style: _textStyle(14, height: 1.4),
                    cursorColor: _teal,
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 16, right: 10),
                        child: SkinXIcon(
                          SkinXIconType.account,
                          size: 18,
                          color: Color(0xFF647D78),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 44, minHeight: 24),
                      border: _inputBorder,
                      enabledBorder: _inputBorder,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: _teal),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Illustrative name • confirm consent before taking a photo.',
                  style: _textStyle(11, color: _muted, height: 1.4),
                ),
                const SizedBox(height: 18),
                if (photo == null)
                  Text(
                    'Photo',
                    style: _textStyle(13, weight: FontWeight.w600, height: 1.3),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Skin photo',
                          style: _textStyle(13, weight: FontWeight.w600, height: 1.3),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SkinXIcon(SkinXIconType.checkCircle, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Ready to review',
                              style: _textStyle(11, color: _teal, height: 1.4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                if (photo != null) ...[
                  _SelectedPhoto(
                    photo: photo!,
                    isIllustrative: isIllustrativePhoto,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check the area is clear before screening.',
                    style: _textStyle(11, color: _muted, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  _PhotoButton(
                    label: 'Screen photo',
                    icon: SkinXIconType.scan,
                    filled: true,
                    elevation: 3,
                    onTap: onScreenPhoto,
                  ),
                  const SizedBox(height: 10),
                  _PhotoButton(
                    label: 'Change photo',
                    icon: SkinXIconType.image,
                    backgroundColor: const Color(0xFFF3F4EC),
                    borderColor: const Color(0xFFD1E5CA),
                    onTap: onChangePhoto,
                  ),
                ] else ...[
                  const _PhotoPlaceholder(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PhotoButton(
                          label: 'Take photo',
                          icon: SkinXIconType.camera,
                          filled: true,
                          onTap: onTakePhoto,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PhotoButton(
                          label: 'Upload',
                          icon: SkinXIconType.upload,
                          onTap: onUploadPhoto,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: photo == null ? const Color(0xFFE6EEE5) : const Color(0xFFEAF2E9),
                    border: photo == null ? null : Border.all(color: const Color(0xFFD1E5CA)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkinXIcon(SkinXIconType.info, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Screening, not a diagnosis',
                              style: _textStyle(13, weight: FontWeight.w700, height: 1.4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'A health professional should assess any concerning skin change.',
                              style: _textStyle(12.5, color: _muted, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedPhoto extends StatelessWidget {
  const _SelectedPhoto({required this.photo, required this.isIllustrative});

  final ImageProvider<Object> photo;
  final bool isIllustrative;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const _DashedOutlinePainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 1.64,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(image: photo, fit: BoxFit.cover, semanticLabel: 'Selected skin photo'),
              Positioned(
                top: 12,
                right: 12,
                child: Semantics(
                  label: 'View photo fullscreen',
                  button: true,
                  child: Material(
                    color: const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showPhoto(context, photo),
                      child: const SizedBox.square(
                        dimension: 42,
                        child: Center(child: SkinXIcon(SkinXIconType.expand, size: 22)),
                      ),
                    ),
                  ),
                ),
              ),
              if (isIllustrative)
                Positioned(
                  left: 12,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xF2FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ILLUSTRATIVE PHOTO',
                      style: _textStyle(10, color: const Color(0xFF647D78), weight: FontWeight.w700, height: 1.2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPhoto(BuildContext context, ImageProvider<Object> photo) {
  FocusScope.of(context).unfocus();
  showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (dialogContext) => Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image(image: photo, fit: BoxFit.contain, semanticLabel: 'Selected skin photo'),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: 'Close photo',
                color: _teal,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const _DashedOutlinePainter(),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 198),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEEE8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFD8EBD6),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const SkinXIcon(SkinXIconType.camera, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a clear skin photo',
              textAlign: TextAlign.center,
              style: _textStyle(16, weight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 310),
              child: Text(
                'Use even daylight. Keep the area centered and in focus.',
                textAlign: TextAlign.center,
                style: _textStyle(13, color: const Color(0xFF57948B), height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({
    required this.label,
    required this.icon,
    this.filled = false,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE6ECE4),
    this.elevation = 0,
    this.onTap,
  });

  final String label;
  final SkinXIconType icon;
  final bool filled;
  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: Material(
        color: filled ? _teal : backgroundColor,
        elevation: elevation,
        shadowColor: const Color(0x3314665E),
        shape: StadiumBorder(
          side: BorderSide(color: filled ? _teal : borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkinXIcon(icon, size: 20, color: filled ? Colors.white : _teal),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: _textStyle(
                        14,
                        color: filled ? Colors.white : _ink,
                        weight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedOutlinePainter extends CustomPainter {
  const _DashedOutlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(0.75),
        const Radius.circular(14),
      ));
    final paint = Paint()
      ..color = const Color(0xFFC5DDC3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 12) {
        final end = start + 7 < metric.length ? start + 7 : metric.length;
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedOutlinePainter oldDelegate) => false;
}

TextStyle _textStyle(
  double size, {
  Color color = _ink,
  FontWeight weight = FontWeight.w400,
  double height = 1.4,
}) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
