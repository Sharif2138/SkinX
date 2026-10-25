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
  late final Set<String> _vocabulary = _buildVocabulary();

  static const _ignored = <String>{
    'the', 'for', 'and', 'with', 'from', 'have', 'has', 'will', 'what',
    'why', 'when', 'where', 'how', 'can', 'could', 'should', 'would',
    'about', 'this', 'that', 'your', 'their', 'they', 'them', 'are',
    'was', 'were', 'does', 'did', 'into', 'some', 'skin', 'there',
    'want', 'need', 'please', 'tell', 'you', 'all',
    'is', 'it', 'to', 'do', 'of', 'in', 'on', 'at', 'an', 'a', 'i', 'my',
    'me', 'we', 'our', 'or', 'if', 'be', 'so', 'very', 'really',
    'someone', 'something', 'other', 'many', 'much', 'meaning',
    'know', 'happens', 'happen', 'get', 'got', 'any', 'ever',
  };

  static const _aliases = <String, String>{
    'albino': 'albinism', 'albinos': 'albinism', 'pwa': 'albinism',
    'wounds': 'wound', 'ulcer': 'wound', 'ulcers': 'wound',
    'sores': 'sore', 'healing': 'heal', 'healed': 'heal',
    'bleeds': 'bleed', 'bleeding': 'bleed', 'blood': 'bleed',
    'grows': 'grow', 'growing': 'grow', 'growth': 'grow',
    'changes': 'change', 'changed': 'change', 'changing': 'change',
    'sunlight': 'sun', 'sunny': 'sun', 'sunshine': 'sun',
    'moles': 'mole', 'pictures': 'photo', 'picture': 'photo',
    'photos': 'photo', 'images': 'photo', 'image': 'photo',
    'blurry': 'blur', 'blurred': 'blur', 'blurredness': 'blur',
    'cancers': 'cancer', 'carcinomas': 'carcinoma',
    'protecting': 'protect', 'protection': 'protect', 'protected': 'protect',
    'sunscreens': 'sunscreen', 'spots': 'spot', 'patches': 'patch',
    'scales': 'scale', 'scaly': 'scale', 'children': 'child',
    'kids': 'child', 'babies': 'baby', 'glasses': 'sunglasses',
    'questions': 'question', 'answers': 'answer', 'results': 'result',
    'diagnosed': 'diagnosis', 'diagnose': 'diagnosis',
    'painless': 'pain', 'painful': 'pain', 'hurts': 'hurt',
    'ears': 'ear', 'lips': 'lip', 'hats': 'hat', 'caps': 'cap',
    'symptoms': 'signs', 'symptom': 'signs', 'sign': 'signs',
    'preventing': 'prevent', 'prevention': 'prevent',
    'rashs': 'rash', 'scabs': 'scab',
    'sunblock': 'sunscreen', 'suncream': 'sunscreen',
    'sunscrean': 'sunscreen', 'severely': 'severe',
    'cream': 'sunscreen', 'creams': 'sunscreen',
    'uses': 'use', 'using': 'use', 'takes': 'take',
  };

  Set<String> _terms(String text) {
    return RegExp(r'[a-z0-9]+')
        .allMatches(text.toLowerCase())
        .map((match) => match.group(0)!)
        .where((word) => word.length > 2 && !_ignored.contains(word))
        .map((word) => _aliases[word] ?? word)
        .toSet();
  }

  bool _oneEditApart(String a, String b) {
    if ((a.length - b.length).abs() > 1) return false;
    var i = 0;
    var j = 0;
    var edits = 0;
    while (i < a.length && j < b.length) {
      if (a[i] == b[j]) {
        i++;
        j++;
      } else {
        edits++;
        if (edits > 1) return false;
        if (a.length >= b.length) i++;
        if (b.length >= a.length) j++;
      }
    }
    return true;
  }

  Set<String> _buildVocabulary() {
    final vocabulary = <String>{};
    for (final entry in entries) {
      for (final question in (entry['questions'] as List).cast<String>()) {
        vocabulary.addAll(_terms(question));
      }
      vocabulary.addAll(_terms((entry['keywords'] as List).join(' ')));
    }
    return vocabulary;
  }

  Set<String> _normalizedQuestion(String question) {
    final tokens = _terms(question);
    return tokens.map((word) {
      if (_vocabulary.contains(word) || word.length < 5) return word;
      final matches = _vocabulary.where(
        (term) => term.length >= 5 && _oneEditApart(word, term),
      ).take(2).toList();
      return matches.length == 1 ? matches.first : word;
    }).toSet();
  }

  ChatAnswer search(String question, {String? previousTopic}) {
    final words = _normalizedQuestion(question);
    if (words.isEmpty) return _fallback;
    if (words.length == 1) {
      const specificTerms = {'melanoma', 'scc', 'bcc', 'ak', 'sunscreen'};
      if (!specificTerms.contains(words.first)) return _fallback;
    }

    if (words.contains('bleed') &&
        (words.contains('heavy') || words.contains('severe') || words.contains('stop'))) {
      return _entryById('skin_bleeding_urgent');
    }
    if ((words.contains('wound') || words.contains('sore')) &&
        (words.contains('heal') || words.contains('weeks') || words.contains('months'))) {
      return _entryById('healing_wound');
    }
    if (words.contains('bleed') &&
        (words.contains('spot') || words.contains('lesion') || words.contains('wound'))) {
      return _entryById('bleeding_lesion');
    }

    final requestedText = question.trim().toLowerCase();
    Map<String, dynamic>? best;
    var bestScore = 0.0;
    var secondScore = 0.0;

    for (final entry in entries) {
      var score = 0.0;
      final keywordWords = _terms((entry['keywords'] as List).join(' '));
      for (final example in (entry['questions'] as List).cast<String>()) {
        if (example.trim().toLowerCase() == requestedText) {
          return _asAnswer(entry);
        }
        final exampleWords = _terms(example);
        if (exampleWords.isEmpty) continue;
        final shared = words.intersection(exampleWords).length;
        if (shared == 0) continue;
        final coverage = shared / words.length;
        final similarity = shared / exampleWords.length;
        final candidate = coverage * 0.76 + similarity * 0.24;
        if (candidate > score) score = candidate;
      }
      if (score > 0 && keywordWords.isNotEmpty) {
        score += 0.08 * words.intersection(keywordWords).length / words.length;
      }
      if (score > bestScore) {
        secondScore = bestScore;
        bestScore = score;
        best = entry;
      } else if (score > secondScore) {
        secondScore = score;
      }
    }

    if (best == null || bestScore < 0.69 ||
        (bestScore - secondScore < 0.05 && bestScore < 0.95)) {
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
    return ChatAnswer(
      '${item['answer']}\n\nThis is general information, not a diagnosis.',
      source: url.isEmpty ? null : url,
      topic: item['id'] as String,
    );
  }

  static const _fallback = ChatAnswer(
    'I do not have a reliable answer for that question offline. Try asking about sun protection, albinism, skin changes, screening results or medical care. If a spot is growing, bleeding or not healing, please see a health professional.',
  );
}

class ChatbotService {
  static const apiBaseUrl = String.fromEnvironment('SKINX_API_URL');
  OfflineKnowledgeBase? _knowledge;
  String? _previousTopic;

  Future<void> load() async {
    if (_knowledge != null) return;
    final data = jsonDecode(
      await rootBundle.loadString('assets/knowledge/skin_health_faq.json'),
    ) as List;
    _knowledge = OfflineKnowledgeBase(
      data.map((item) => (item as Map).cast<String, dynamic>()).toList(),
    );
  }

  Future<ChatAnswer> answer(String question, {bool useOnline = false}) async {
    await load();
    final offline = _knowledge!.search(question, previousTopic: _previousTopic);
    if (offline.topic != null) _previousTopic = offline.topic;
    if (!useOnline || !ConnectivityService.instance.online ||
        apiBaseUrl.isEmpty || !AuthService.configured) {
      return offline;
    }
    final session = AuthService.user == null ? null : AuthService.accessToken;
    if (session == null) return offline;
    try {
      final response = await http.post(
        Uri.parse('${apiBaseUrl.replaceAll(RegExp(r"/+$"), "")}/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $session',
        },
        body: jsonEncode({'question': question}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return offline;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = (data['answer'] as String?)?.trim();
      if (message == null || message.isEmpty) return offline;
      return ChatAnswer(
        message,
        source: data['source'] as String?,
        online: data['mode'] == 'online',
      );
    } catch (_) {
      return offline;
    }
  }
}
