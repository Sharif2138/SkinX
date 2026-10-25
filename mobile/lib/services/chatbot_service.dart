import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatAnswer {
  const ChatAnswer(this.text, {this.source, this.online = false});
  final String text;
  final String? source;
  final bool online;
}

class ChatbotService {
  static const apiBaseUrl = String.fromEnvironment('SKINX_API_URL');
  List<dynamic>? _faq;

  Future<ChatAnswer> answer(String question, {bool useOnline = false}) async {
    // Offline is always available and is the fallback for online failures.
    final offline = await _offline(question);
    if (!useOnline || apiBaseUrl.isEmpty) return offline;
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return ChatAnswer('${offline.text}\n\nSign in to use optional online AI.');
    }
    try {
      final response = await http.post(
        Uri.parse('${apiBaseUrl.replaceAll(RegExp(r"/+$"), "")}/chat'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${session.accessToken}'},
        body: jsonEncode({'question': question}),
      ).timeout(const Duration(seconds: 22));
      if (response.statusCode != 200) return offline;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ChatAnswer(data['answer'] as String, source: data['source'] as String?,
          online: data['mode'] == 'online');
    } catch (_) {
      return offline;
    }
  }

  Future<ChatAnswer> _offline(String question) async {
    _faq ??= jsonDecode(await rootBundle.loadString('assets/knowledge/skin_health_faq.json')) as List;
    final terms = RegExp(r'[a-z]{3,}').allMatches(question.toLowerCase()).map((m) => m.group(0)!).toSet();
    Map<String, dynamic>? best;
    var topScore = 0;
    for (final entry in _faq!) {
      final item = (entry as Map).cast<String, dynamic>();
      final keys = [...(item['keywords'] as List), ...(item['questions'] as List)].join(' ').toLowerCase();
      final relevant = RegExp(r'[a-z]{3,}').allMatches(keys).map((m) => m.group(0)!).toSet();
      final score = terms.intersection(relevant).length;
      if (score > topScore) {
        topScore = score;
        best = item;
      }
    }
    if (best == null) {
      return const ChatAnswer('I do not have a prepared answer for that question. Please ask a health professional if you are worried about a skin change. SkinX cannot diagnose skin conditions.');
    }
    return ChatAnswer('${best['answer']}\n\nEducational guidance only, not a diagnosis.',
        source: (best['source'] as String).isEmpty ? null : best['source'] as String);
  }
}
