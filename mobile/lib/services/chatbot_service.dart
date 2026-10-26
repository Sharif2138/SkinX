import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'connectivity_service.dart';
import 'app_language.dart';

class ChatAnswer {
  const ChatAnswer(this.text, {this.source, this.online = false, this.topic, this.problem});

  final String text;
  final String? source;
  final bool online;
  final String? topic;
  final String? problem;
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
    if (previousTopic != null && words.length <= 2 &&
        RegExp(r'^(why|how|more|explain|tell me more|what about it|and then)', caseSensitive: false)
            .hasMatch(question.trim())) {
      final previous = _entryById(previousTopic);
      if (previous.topic != null) return previous;
    }
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

class ChatHistoryMessage {
  const ChatHistoryMessage({required this.role, required this.content});

  final String role;
  final String content;
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

  Future<ChatAnswer> answer(String question, {List<ChatHistoryMessage> history = const []}) async {
    await load();
    final offline = AppLanguage.instance.code == 'rw'
        ? _kinyarwandaOfflineAnswer(question)
        : _knowledge!.search(question, previousTopic: _previousTopic);
    if (offline.topic != null) _previousTopic = offline.topic;
    if (!ConnectivityService.instance.online) return offline;
    if (apiBaseUrl.isEmpty) {
      return ChatAnswer(offline.text, topic: offline.topic, source: offline.source,
          problem: 'Online chat has no FastAPI URL configured.');
    }

    try {
      final response = await http.post(
        Uri.parse('${apiBaseUrl.replaceAll(RegExp(r"/+$"), "")}/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'language': AppLanguage.instance.code,
          'history': history.reversed.take(8).toList().reversed.map((message) => {
            'role': message.role,
            'content': message.content,
          }).toList(),
        }),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        var reason = 'Online chat could not respond (HTTP ${response.statusCode}).';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final code = body['detail']?.toString();
          reason = switch (code) {
            'GROQ_KEY_MISSING' => 'Groq API key is missing in FastAPI.',
            'GROQ_AUTH_FAILED' => 'Groq rejected the API key. Check the backend configuration.',
            'GROQ_MODEL_NOT_FOUND' => 'The Groq model is unavailable. Check GROQ_MODEL.',
            'GROQ_RATE_LIMITED' => 'Groq request limit reached. Try again later.',
            'GROQ_TIMEOUT' => 'Groq timed out. Try again.',
            'GROQ_NETWORK_ERROR' => 'FastAPI cannot reach Groq.',
            'GROQ_REQUEST_REJECTED' => 'Groq rejected this request. Check the backend logs.',
            _ => reason,
          };
        } catch (_) {}
        return ChatAnswer(offline.text, source: offline.source,
            topic: offline.topic, problem: reason);
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = (data['answer'] as String?)?.trim();
      if (message == null || message.isEmpty) {
        return ChatAnswer(offline.text, source: offline.source, topic: offline.topic,
            problem: 'FastAPI returned an empty answer.');
      }
      return ChatAnswer(message, source: data['source'] as String?, online: true);
    } catch (_) {
      return ChatAnswer(offline.text, source: offline.source, topic: offline.topic,
          problem: 'Could not reach FastAPI. Check the API URL and network connection.');
    }
  }
}

ChatAnswer _kinyarwandaOfflineAnswer(String question) {
  final text = question.toLowerCase().trim();
  const ending = '\n\nAya ni amakuru rusange, si isuzuma rya muganga.';
  if (RegExp(r'amaraso|igisebe|ibisebe|kidakira|gikura|ibyimba').hasMatch(text)) {
    return ChatAnswer(
      'Igisebe kidakira, ikibyimba gikura cyangwa ahantu ku ruhu hakunze kuva amaraso bigomba gusuzumwa vuba n’umukozi w’ubuzima.'
      + ending, topic: 'healing_wound');
  }
  if (RegExp(r'izuba|sunscreen|spf|kwirinda|kurinda uruhu').hasMatch(text)) {
    return ChatAnswer(
      'Irinde izuba rikaze uko bishoboka. Ambara ingofero nini n’imyenda ipfuka uruhu, jya mu gicucu, kandi ukoreshe amavuta arinda UVA na UVB afite SPF 30 cyangwa irenze. Ongera uyisige buri masaha abiri uri hanze.'
      + ending, topic: 'sun_protection');
  }
  if (RegExp(r'albinism|albinisme|umuntu ufite|abafite').hasMatch(text)) {
    return ChatAnswer(
      'Albinisme ni imiterere y’umubiri ituma umuntu agira melanin nke mu ruhu, umusatsi no mu maso. Abantu bafite albinisme bakenera kurinda uruhu izuba no kwita ku buzima bw’amaso.'
      + ending, topic: 'albinism');
  }
  if (RegExp(r'kanseri|cancer|scc|bcc|ak\b|melanoma').hasMatch(text)) {
    return ChatAnswer(
      'Kanseri y’uruhu ishobora kugaragara nk’ikibyimba, agace k’uruhu kahindutse cyangwa igisebe kidakira. Ibimenyetso bishobora gusa n’izindi ndwara. Umukozi w’ubuzima ni we ushobora gukora isuzuma rikenewe.'
      + ending, topic: 'skin_cancer');
  }
  if (RegExp(r'igisubizo|skinx|suzuma|suspicious|infer').hasMatch(text)) {
    return ChatAnswer(
      'Igisubizo cya SkinX ni icy’isuzuma ry’ibanze gusa. Nta gisubizo cyayo cyemeza ko umuntu afite kanseri cyangwa ko atayifite. Niba uruhu rufite impinduka iguhangayikishije, gisha inama umukozi w’ubuzima.'
      + ending, topic: 'using_skinx');
  }
  if (RegExp(r'nisuzuma|kwisuzuma|nareba|nahora').hasMatch(text)) {
    return ChatAnswer(
      'Isuzume ahantu hose ku ruhu ukoresheje urumuri rwiza. Itondere ibibara bishya, ibisebe bidakira cyangwa ahantu hakura. Gusuzuma uruhu mu rugo ntibisimbura kwa muganga.'
      + ending, topic: 'self_check');
  }
  return const ChatAnswer(
    'Nta gisubizo cyizewe mfite kuri icyo kibazo igihe nta interineti. Ushobora kumbaza uko warinda uruhu izuba, albinisme, ibimenyetso bya kanseri y’uruhu cyangwa ibisubizo bya SkinX.');
}
