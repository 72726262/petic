import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:employee_portal/features/chatbot/cubit/chatbot_state.dart';
import 'package:employee_portal/features/chatbot/models/chat_message_model.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  // ── Gemini 1.5 Flash (free tier) ──────────────────────────────────
  // Replace with your own key from https://aistudio.google.com/app/apikey
  static const _geminiKey = 'AIzaSyExampleKeyReplaceMe';
  static const _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-1.5-flash:generateContent?key=$_geminiKey';

  // System context for the chatbot
  static const _systemPrompt = '''
أنت مساعد ذكي لبوابة الموظفين الداخلية. أجب باللغة العربية فقط بشكل موجز وواضح.
معلومات الشركة:
- نظام الراتب: يُصرف في أول الشهر
- الإجازة السنوية: 21 يوم عمل
- الواي فاي: CorpNet (كلمة المرور لدى IT)
- التأخر بعد 15 دقيقة يُحتسب غياب نصف يوم
- شكاوى الموظفين: confidential@company.com
- دعم IT: it@company.com
إذا سُئلت عن شيء لا تعرف جوابه الدقيق، اعترف بذلك وانصح بالتواصل مع الجهة المختصة.
''';

  // Fallback knowledge base (used when Gemini key is not configured)
  static const Map<String, String> _fallback = {
    'إجازة': 'يمكنك تقديم طلب إجازة من خلال قسم الموارد البشرية. الحد الأقصى للإجازة السنوية 21 يوم.',
    'راتب': 'يصرف الراتب في اليوم الأول من كل شهر. للاستفسار تواصل مع قسم الموارد البشرية.',
    'كلمة المرور': 'لإعادة تعيين كلمة المرور تواصل مع فريق IT عبر it@company.com.',
    'واي فاي': 'شبكة الواي فاي: CorpNet. كلمة المرور متاحة لدى فريق IT.',
    'حضور': 'نظام الحضور من 8:00 ص حتى 5:00 م. التأخر بعد 15 دقيقة يُحتسب غياب نصف يوم.',
    'تدريب': 'اطلع على برامج التدريب في قسم الموارد البشرية تحت تبويب "التدريب".',
    'شكوى': 'لتقديم شكوى تواصل مع الموارد البشرية أو أرسل إلى confidential@company.com.',
    'طابعة': 'للإبلاغ عن مشكلة في الطابعة تواصل مع فريق IT.',
  };

  static const _defaultFallback =
      'شكرًا على سؤالك. يُرجى التواصل مع الجهة المختصة (الموارد البشرية أو تقنية المعلومات).';

  static const _greeting = '''مرحبًا بك في مساعدك الذكي! 🤖

يمكنني مساعدتك في:
• 📅 استفسارات الإجازات والحضور
• 💰 معلومات الراتب
• 🖥️ دعم تقنية المعلومات
• 📚 برامج التدريب
• 📋 سياسات الشركة

اكتب سؤالك وسأجيبك على الفور!''';

  ChatbotCubit()
      : super(ChatbotReady(
          messages: [
            ChatMessage(
              id: 'welcome',
              text: _greeting,
              sender: MessageSender.bot,
              timestamp: DateTime.now(),
            ),
          ],
        ));

  Future<void> sendMessage(String text) async {
    final currentState = state;
    if (currentState is! ChatbotReady) return;
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    emit(currentState.copyWith(
      messages: [...currentState.messages, userMsg],
      isTyping: true,
    ));

    String response;
    // Try Gemini first; fallback to local if key is placeholder or request fails
    if (_geminiKey != 'AIzaSyExampleKeyReplaceMe') {
      response = await _askGemini(text.trim());
    } else {
      await Future.delayed(const Duration(milliseconds: 700));
      response = _localAnswer(text.trim());
    }

    final botMsg = ChatMessage(
      id: const Uuid().v4(),
      text: response,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
    );

    final typing = state;
    if (typing is ChatbotReady) {
      emit(typing.copyWith(
        messages: [...typing.messages, botMsg],
        isTyping: false,
      ));
    }
  }

  Future<String> _askGemini(String userText) async {
    try {
      final body = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '$_systemPrompt\n\nسؤال الموظف: $userText'},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 400,
        },
      });
      final res = await http
          .post(
            Uri.parse(_geminiUrl),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (((data['candidates'] as List).first)['content']['parts']
                as List)
            .first['text'] as String;
      }
      return _localAnswer(userText);
    } catch (_) {
      return _localAnswer(userText);
    }
  }

  String _localAnswer(String input) {
    final lower = input.toLowerCase();
    for (final entry in _fallback.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return _defaultFallback;
  }

  void clearChat() {
    emit(ChatbotReady(
      messages: [
        ChatMessage(
          id: 'welcome',
          text: _greeting,
          sender: MessageSender.bot,
          timestamp: DateTime.now(),
        ),
      ],
    ));
  }
}
