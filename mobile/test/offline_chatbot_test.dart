import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinx/services/chatbot_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offline knowledge loads and answers common questions', () async {
    final data = jsonDecode(await rootBundle.loadString(
      'assets/knowledge/skin_health_faq.json')) as List;
    final knowledge = OfflineKnowledgeBase(
      data.map((entry) => (entry as Map).cast<String, dynamic>()).toList(),
    );
    final answer = knowledge.search('How can I protect my skin from the sun?');
    expect(answer.text.toLowerCase(), contains('sunscreen'));
    expect(answer.online, isFalse);
    expect(answer.source, isNotNull);
  });

  test('warning signs receive referral guidance', () async {
    final data = jsonDecode(await rootBundle.loadString(
      'assets/knowledge/skin_health_faq.json')) as List;
    final knowledge = OfflineKnowledgeBase(
      data.map((entry) => (entry as Map).cast<String, dynamic>()).toList(),
    );
    expect(knowledge.search('My wound has not healed for weeks').text.toLowerCase(),
        contains('health professional'));
    expect(knowledge.search('My spot keeps bleeding').text.toLowerCase(),
        contains('health professional'));
  });

  test('unrelated questions receive a safe fallback', () async {
    final data = jsonDecode(await rootBundle.loadString(
      'assets/knowledge/skin_health_faq.json')) as List;
    final knowledge = OfflineKnowledgeBase(
      data.map((entry) => (entry as Map).cast<String, dynamic>()).toList(),
    );
    final answer = knowledge.search('What is the football score?');
    expect(answer.text, contains('do not have a reliable offline answer'));
  });
}
