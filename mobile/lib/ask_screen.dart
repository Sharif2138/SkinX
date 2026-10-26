import 'services/app_language.dart';
import 'widgets/skinx_feedback.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/chatbot_service.dart';
import 'services/connectivity_service.dart';
import 'widgets/chat_message_text.dart';
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
  bool _replying = false;

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
    final contextMessages = <ChatHistoryMessage>[];
    for (final turn in _conversation.take(_conversation.length - 1)) {
      if (turn.answer == null) continue;
      contextMessages.add(ChatHistoryMessage(role: 'user', content: turn.question));
      contextMessages.add(ChatHistoryMessage(role: 'assistant', content: turn.answer!.text));
    }
    ChatAnswer answer;
    try {
      answer = await _chat.answer(question, history: contextMessages);
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
      SkinXNotice.show(context, 'Source links can be opened when internet is available.', error: true);
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
                    const SkinXText('Ask SkinX', style: TextStyle(
                      color: _ink, fontSize: 25, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 5),
                    const SkinXText(
                      'Ask about skin care for people with albinism.',
                      style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
                    ),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 4, 2, 16),
                        child: Row(
                          children: [
                            const Icon(Icons.forum_outlined, color: _teal, size: 20),
                            const SizedBox(width: 9),
                            Expanded(child: SkinXText(
                              'Explore common questions',
                              style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: _ink,
                              ),
                            )),
                          ],
                        ),
                      ),
                      ...[
                        'What are signs of skin cancer in people with albinism?',
                        'How can a person with albinism protect their skin?',
                        'What should I do if a sore does not heal?',
                        'Can SkinX diagnose skin cancer?',
                      ].map((englishQuestion) {
                        final question = AppLanguage.text(englishQuestion);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: const Color(0xFFF7FAF7),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _submitQuestion(question),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(question,
                                      style: const TextStyle(fontSize: 13.5, color: _ink, height: 1.4))),
                                    const Icon(Icons.north_east_rounded, size: 16, color: _teal),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
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
                          child: SkinXText(turn.question, style: const TextStyle(
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
                              ? const SkinXText('Finding an answer...', style: TextStyle(color: _muted))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectionArea(
                                      child: ChatMessageText(turn.answer!.text),
                                    ),
                                    if (turn.answer!.problem != null) ...[
                                      const SizedBox(height: 8),
                                      SkinXText(turn.answer!.problem!,
                                        style: const TextStyle(fontSize: 12, color: _muted, height: 1.4)),

                                    ],
                                    if (turn.answer!.source != null) ...[
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _openSource(turn.answer!.source!),
                                        child: const SkinXText('View source', style: TextStyle(
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
                              hintText: AppLanguage.text('Ask a question...'),
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
                    const SkinXText(
                      'This answer is for education, not a diagnosis.',
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
