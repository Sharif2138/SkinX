import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'connectivity_service.dart';

class ChatAnswer {
  const ChatAnswer(this.text, {this.source, this.online = false, this.topic});

  final String text;
  final String? source;
  final bool online;
  final String? topic;
}

class OfflineKnowledgeBase {
  OfflineKnowledgeBase(this.entries);

  final List<Map<String, dynamic>> entries;

  static const _ignored = <String>{
    'the', 'for', 'and', 'with', 'from', 'have', 'has', 'will', 'what',
    'why', 'when', 'where', 'how', 'can', 'could', 'should', 'would',
    'about', 'this', 'that', 'my', 'your', 'their', 'they', 'them',
    'are', 'was', 'were', 'does', 'did', 'into', 'some', 'skin',
    'there', 'want', 'need', 'please', 'tell', 'me', 'you', 'all',
  };
  static const _aliases = <String, String>{
    'albino': 'albinism', 'albinos': 'albinism', 'pwa': 'albinism',
    'wounds': 'wound', 'ulcer': 'wound', 'ulcers': 'wound',
    'sores': 'sore', 'healing': 'heal', 'healed': 'heal',
    'bleeds': 'bleed', 'bleeding': 'bleed', 'blood': 'bleed',
    'grows': 'grow', 'growing': 'grow', 'growth': 'grow',
    'changes': 'changing', 'changed': 'changing',
    'sunlight': 'sun', 'sunny': 'sun',
    'moles': 'mole', 'pictures': 'photo', 'picture': 'photo',
    'photos': 'photo', 'images': 'photo', 'image': 'photo',
    'blurry': 'blur', 'blurred': 'blur',
    'cancers': 'cancer', 'carcinomas': 'carcinoma',
    'protecting': 'protect', 'protection': 'protect',
  };

  Set<String> _terms(String text) {
    final tokens = RegExp(r'[a-z0-9]+').allMatches(text.toLowerCase())
        .map((m) => m.group(0)!)
        .where((t) => t.length > 2 && !_ignored.contains(t));
    return tokens.map((term) => _aliases[term] ?? term).toSet();
  }

  ChatAnswer search(String question, {String? previousTopic}) {
    final words = _terms(question);
    if (words.isEmpty) return _fallback;

    if ((words.contains('wound') || words.contains('sore')) &&
        (words.contains('heal') || words.contains('weeks') || words.contains('months') || words.contains('sun'))) {
      return _entryById('healing_wound');
    }
    if (words.contains('bleed') && (words.contains('spot') || words.contains('lesion') || words.contains('wound'))) {
      return _entryById('bleeding_lesion');
    }

    final query = question.toLowerCase().trim();
    Map<String, dynamic>? best;
    var highest = 0.0;
    for (final entry in entries) {
      final questions = (entry['questions'] as List).cast<String>();
      final tags = (entry['keywords'] as List).cast<String>();
      final keywordTerms = _terms(tags.join(' '));
      final questionTerms = _terms(questions.join(' '));
      final hits = words.intersection(keywordTerms).length * 2 +
          words.intersection(questionTerms).length;
      final exact = questions.any((q) => q.toLowerCase().trim() == query);
      final followup = words.length <= 2 && entry['id'] == previousTopic;
      final score = hits.toDouble() + (exact ? 15 : 0) + (followup ? 1 : 0);
      if (score > highest) {
        highest = score;
        best = entry;
      }
    }
    if (best == null || (highest < 3 && words.length > 1) ||
        (highest < 2 && words.length == 1)) {
      return _fallback;
    }
    return _asAnswer(best);
  }

  ChatAnswer _entryById(String id) {
    for (final entry in entries) {
      if (entry['id'] == id) return _asAnswer(entry);
    }
    return _fallback;
  }

  ChatAnswer _asAnswer(Map<String, dynamic> item) {
    final url = item['source']?.toString() ?? '';
    return ChatAnswer("${item['answer']}\n\nEducational information only. SkinX cannot diagnose skin disease.",
        source: url.isEmpty ? null : url, topic: item['id'] as String);
  }

  static const _fallback = ChatAnswer(
    'I do not have a reliable offline answer for that question yet. You can ask about sun protection, albinism, skin changes, or screening results. If you have a new, bleeding, changing, or non-healing skin spot, please see a health professional.',
  );
}

class ChatbotService {
  static const apiBaseUrl = String.fromEnvironment('SKINX_API_URL');
  OfflineKnowledgeBase? _knowledge;
  String? _previousTopic;

  Future<void> load() async {
    if (_knowledge != null) return;
    final data = jsonDecode(await rootBundle.loadString('assets/knowledge/skin_health_faq.json')) as List;
    _knowledge = OfflineKnowledgeBase(data.map((item) => (item as Map).cast<String, dynamic>()).toList());
  }

  Future<ChatAnswer> answer(String question, {bool useOnline = false}) async {
    await load();
    final offline = _knowledge!.search(question, previousTopic: _previousTopic);
    if (offline.topic != null) _previousTopic = offline.topic;
    if (!useOnline || !ConnectivityService.instance.online || apiBaseUrl.isEmpty || !AuthService.configured) {
      return offline;
    }
    final session = AuthService.user == null ? null : AuthService.accessToken;
    if (session == null) return offline;
    try {
      final response = await http.post(
        Uri.parse('${apiBaseUrl.replaceAll(RegExp(r"/+$"), "")}/chat'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $session'},
        body: jsonEncode({'question': question}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return offline;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = (data['answer'] as String?)?.trim();
      if (message == null || message.isEmpty) return offline;
      return ChatAnswer(message, source: data['source'] as String?, online: data['mode'] == 'online');
    } catch (_) {
      return offline;
    }
  }
}
