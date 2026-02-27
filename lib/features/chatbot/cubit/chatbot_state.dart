import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/chatbot/models/chat_message_model.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();
  @override
  List<Object?> get props => [];
}

class ChatbotInitial extends ChatbotState {
  const ChatbotInitial();
}

class ChatbotReady extends ChatbotState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatbotReady({required this.messages, this.isTyping = false});

  ChatbotReady copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatbotReady(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping];
}
