import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'widgets/skinx_header.dart';
import 'widgets/skinx_icon.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF647D78);
const _border = Color(0xFFDDE6DE);

class AskScreen extends StatefulWidget {
  const AskScreen({
    super.key,
    this.onQuestionSubmitted,
    this.onSourceTap,
    this.onLanguageTap,
    this.languageCode = 'EN',
  });

  // Connect these callbacks to your chat service and source-link handler.
  final ValueChanged<String>? onQuestionSubmitted;
  final ValueChanged<Uri>? onSourceTap;
  final VoidCallback? onLanguageTap;
  final String languageCode;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _questionController = TextEditingController();

  void _submitQuestion([String? suggestion]) {
    final question = (suggestion ?? _questionController.text).trim();
    if (question.isEmpty) return;

    if (widget.onQuestionSubmitted == null) {
      if (suggestion != null) {
        _questionController.text = question;
        _questionController.selection = TextSelection.collapsed(offset: question.length);
      }
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onQuestionSubmitted!(question);
    _questionController.clear();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // Keep the conversation readable on both phones and tablets.
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkinXHeader(
                  languageCode: widget.languageCode,
                  onLanguageTap: widget.onLanguageTap,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ask about skin health',
                  style: _type(24, weight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skin-health questions, grounded in sources.',
                  style: _type(14, color: _muted, height: 1.4),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const SkinXIcon(SkinXIconType.info, size: 14, color: _muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Example conversation · not a live response',
                        style: _type(12, color: _muted, height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDFF0DE),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22),
                          ),
                        ),
                        child: Text(
                          'How can I protect my skin from the sun?',
                          style: _type(13, weight: FontWeight.w500, height: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ExcludeSemantics(
                      child: SvgPicture.asset('assets/skinx_logo.svg', width: 28, height: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SunProtectionCard(onSourceTap: widget.onSourceTap),
                const SizedBox(height: 18),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _submitQuestion('When should I seek care?'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          const SkinXIcon(SkinXIconType.chat, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('When should I seek care?', style: _type(14, height: 1.4)),
                          ),
                          const SizedBox(width: 10),
                          const SkinXIcon(SkinXIconType.chevronRight, size: 12, color: _muted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          minLines: 1,
                          maxLines: 4,
                          cursorColor: _teal,
                          style: _type(14, height: 1.4),
                          onSubmitted: (value) => _submitQuestion(value),
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            hintText: 'Ask a skin-health question...',
                            hintStyle: _type(14, color: const Color(0xFF9CADAA), height: 1.4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Send question',
                        button: true,
                        enabled: widget.onQuestionSubmitted != null,
                        child: Material(
                          color: _teal,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: widget.onQuestionSubmitted == null ? null : () => _submitQuestion(),
                            child: const SizedBox.square(
                              dimension: 44,
                              child: Center(
                                child: SkinXIcon(SkinXIconType.arrowUp, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Education, not a diagnosis. See a health professional for a new or changing skin spot.',
                  style: _type(12, color: _muted, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SunProtectionCard extends StatelessWidget {
  const _SunProtectionCard({this.onSourceTap});

  final ValueChanged<Uri>? onSourceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkinXIcon(SkinXIconType.book, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Everyday sun protection',
                  style: _type(14, color: _teal, weight: FontWeight.w700, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _ProtectionStep('1', 'Seek shade, especially at midday. [1]'),
          const SizedBox(height: 10),
          const _ProtectionStep('2', 'Cover up with a wide-brimmed hat and long sleeves. [1]'),
          const SizedBox(height: 10),
          const _ProtectionStep('3', 'Use broad-spectrum SPF 30+. Reapply every 2 hours outdoors. [2]'),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFEDF1EC)),
          const SizedBox(height: 12),
          Text(
            'REFERENCE SOURCES',
            style: _type(9, color: _muted, weight: FontWeight.w700, height: 1.4).copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          _SourceLink(
            text: '[1] WHO · Ultraviolet radiation (2022)',
            url: 'https://www.who.int/news-room/fact-sheets/detail/ultraviolet-radiation',
            onTap: onSourceTap,
          ),
          const SizedBox(height: 4),
          _SourceLink(
            text: '[2] American Academy of Dermatology · Sunscreen FAQs',
            url: 'https://www.aad.org/media/stats-sunscreen',
            onTap: onSourceTap,
          ),
          const SizedBox(height: 8),
          Text(
            'Reference examples only. No live source retrieval.',
            style: _type(10, color: _muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ProtectionStep extends StatelessWidget {
  const _ProtectionStep(this.number, this.text);

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(color: Color(0xFFEAF2E9), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(number, style: _type(11, color: _teal, weight: FontWeight.w700, height: 1)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: _type(14, height: 1.4))),
      ],
    );
  }
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.text, required this.url, this.onTap});

  final String text;
  final String url;
  final ValueChanged<Uri>? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(Uri.parse(url)),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(text, style: _type(12.5, color: _teal, height: 1.35))),
              const SizedBox(width: 8),
              const SkinXIcon(SkinXIconType.externalLink, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle _type(
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
