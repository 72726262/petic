import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/core/utils/app_strings.dart';
import 'package:employee_portal/features/chatbot/cubit/chatbot_cubit.dart';
import 'package:employee_portal/features/chatbot/cubit/chatbot_state.dart';
import 'package:employee_portal/features/chatbot/models/chat_message_model.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatbotCubit(),
      child: const _ChatbotView(),
    );
  }
}

class _ChatbotView extends StatefulWidget {
  const _ChatbotView();

  @override
  State<_ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<_ChatbotView> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<String> _quickReplies(AppStrings s) => s.isAr
    ? ['كيف أطلب إجازة؟', 'موعد صرف الراتب', 'مشكلة في الطابعة', 'كلمة مرور الواي فاي', 'برامج التدريب']
    : ['How to request leave?', 'Salary schedule', 'Printer problem', 'WiFi password', 'Training programs'];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final msg = text ?? _msgCtrl.text.trim();
    if (msg.isEmpty) return;
    _msgCtrl.clear();
    context.read<ChatbotCubit>().sendMessage(msg);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.chatbotScreenTitle, style: AppTypography.titleSmall),
                BlocBuilder<ChatbotCubit, ChatbotState>(
                  builder: (_, state) {
                    final isTyping =
                        state is ChatbotReady && state.isTyping;
                    return Text(
                      isTyping ? s.typing : 'Online',
                      style: AppTypography.labelSmall.copyWith(
                        color: isTyping
                            ? AppColors.warning
                            : AppColors.success,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: s.isAr ? 'مسح المحادثة' : 'Clear chat',
            onPressed: () =>
                context.read<ChatbotCubit>().clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocConsumer<ChatbotCubit, ChatbotState>(
              listener: (_, state) {
                if (state is ChatbotReady) _scrollToBottom();
              },
              builder: (context, state) {
                if (state is! ChatbotReady) {
                  return const SizedBox.shrink();
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                  itemCount:
                      state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isTyping &&
                        index == state.messages.length) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(
                      message: state.messages[index],
                    );
                  },
                );
              },
            ),
          ),

          // Quick replies
          BlocBuilder<ChatbotCubit, ChatbotState>(
            buildWhen: (prev, curr) =>
                prev is ChatbotReady &&
                curr is ChatbotReady &&
                prev.messages.length != curr.messages.length,
            builder: (context, state) {
              if (state is! ChatbotReady || state.messages.length > 3) {
                return const SizedBox.shrink();
              }
              final replies = _quickReplies(s);
              return SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  scrollDirection: Axis.horizontal,
                  itemCount: replies.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, idx) => _QuickReplyChip(
                    label: replies[idx],
                    onTap: () => _send(replies[idx]),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          // Input bar
          _MessageInput(
            controller: _msgCtrl,
            onSend: () => _send(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isUser) ...[
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 6),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser ? Colors.white : null,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatTime(message.timestamp),
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : (isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 6),
            const CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person_outline_rounded,
                  size: 14, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TYPING INDICATOR
// ═══════════════════════════════════════════════════════════════════
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final offset = (i / 3);
                    final t =
                        (_ctrl.value - offset + 1) % 1;
                    final y = t < 0.5
                        ? -4 * t
                        : -4 * (1 - t);
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: Container(
                        width: 7,
                        height: 7,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// QUICK REPLY CHIP
// ═══════════════════════════════════════════════════════════════════
class _QuickReplyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickReplyChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.fullBorderRadius,
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MESSAGE INPUT
// ═══════════════════════════════════════════════════════════════════
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTypography.bodyMedium,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppStrings.of(context).typeMessage,
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.fullBorderRadius,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
