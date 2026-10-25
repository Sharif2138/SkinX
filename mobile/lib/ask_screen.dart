import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/auth_service.dart';
import 'services/chatbot_service.dart';
import 'services/connectivity_service.dart';
import 'widgets/skinx_header.dart';

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
    this.onlineAvailable = false,
  });

  final ValueChanged<String>? onQuestionSubmitted;
  final ValueChanged<Uri>? onSourceTap;
  final VoidCallback? onLanguageTap;
  final String languageCode;
  final bool onlineAvailable;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _questionController = TextEditingController();
  final _scrollController = ScrollController();
  final _chat = ChatbotService();
  final List<({String question, ChatAnswer? answer})> _conversation = [];
  bool _useOnline = false;
  bool _replying = false;

  bool get _onlineChatAvailable => widget.onlineAvailable &&
      AuthService.configured &&
      AuthService.user != null &&
      ChatbotService.apiBaseUrl.isNotEmpty;

  Future<void> _submitQuestion([String? suggestion]) async {
    final question = (suggestion ?? _questionController.text).trim();
    if (question.isEmpty || _replying) return;
    FocusScope.of(context).unfocus();
    widget.onQuestionSubmitted?.call(question);
    _questionController.clear();
    setState(() {
      _conversation.add((question: question, answer: null));
      _replying = true;
    });
    _scrollToBottom();
    ChatAnswer answer;
    try {
      answer = await _chat.answer(question, useOnline: _useOnline && _onlineChatAvailable);
    } catch (_) {
      answer = const ChatAnswer(
        'I cannot find an answer right now. If you have a worrying skin change, please speak to a health professional.',
      );
    }
    if (!mounted) return;
    setState(() {
      _conversation[_conversation.length - 1] = (question: question, answer: answer);
      _replying = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openSource(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.scheme != 'https') return;
    if (!ConnectivityService.instance.online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source links can be opened when internet is available.')),
      );
      return;
    }
    if (widget.onSourceTap != null) {
      widget.onSourceTap!(uri);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkinXHeader(
                      languageCode: widget.languageCode,
                      onLanguageTap: widget.onLanguageTap,
                    ),
                    const SizedBox(height: 20),
                    const Text('Ask SkinX', style: TextStyle(
                      color: _ink, fontSize: 25, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 5),
                    const Text(
                      'Simple answers about skin health and sun protection.',
                      style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
                    ),
                    if (_onlineChatAvailable) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(child: Text('Use online AI', style: TextStyle(
                            color: _ink, fontSize: 13, fontWeight: FontWeight.w500,
                          ))),
                          Switch.adaptive(
                            value: _useOnline,
                            activeTrackColor: _teal,
                            onChanged: (value) => setState(() => _useOnline = value),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(color: _border, height: 1),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    if (_conversation.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F6F1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.forum_outlined, size: 28, color: _teal),
                            SizedBox(height: 10),
                            Text('What would you like to know?', style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600, color: _ink,
                            )),
                            SizedBox(height: 7),
                            Text('Choose a question below or type your own. Basic skin-health answers are available offline.',
                              style: TextStyle(fontSize: 13, height: 1.5, color: _muted)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...[
                        'What are the warning signs of skin cancer?',
                        'How do I protect my skin from the sun?',
                        'What does a suspicious result mean?',
                        'How do I check my skin?',
                      ].map((question) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: _border),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: () => _submitQuestion(question),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              child: Row(
                                children: [
                                  Expanded(child: Text(question, style: const TextStyle(
                                    fontSize: 13.5, color: _ink,
                                  ))),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: _teal, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                    ],
                    for (final turn in _conversation) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 460),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F1E1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(turn.question, style: const TextStyle(
                            color: _ink, fontSize: 14, height: 1.5,
                          )),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 540),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: turn.answer == null
                              ? const Text('Finding an answer...', style: TextStyle(color: _muted))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(turn.answer!.text, style: const TextStyle(
                                      color: _ink, fontSize: 14, height: 1.55,
                                    )),
                                    if (turn.answer!.source != null) ...[
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _openSource(turn.answer!.source!),
                                        child: const Text('View source', style: TextStyle(
                                          color: _teal, fontSize: 12, fontWeight: FontWeight.w600,
                                        )),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 19),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _questionController,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 4,
                            onSubmitted: (value) => _submitQuestion(value),
                            decoration: InputDecoration(
                              hintText: 'Ask a question...',
                              hintStyle: const TextStyle(color: _muted, fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFF8FAF8),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 13,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _teal),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        IconButton.filled(
                          tooltip: 'Send question',
                          onPressed: _replying ? null : () => _submitQuestion(),
                          style: IconButton.styleFrom(
                            backgroundColor: _teal,
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'For education only, not a diagnosis.',
                      style: TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
