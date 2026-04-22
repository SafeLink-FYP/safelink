import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/chatbot/controllers/chat_controller.dart';
import 'package:safelink/features/chatbot/services/chatbot_service.dart';
import 'package:safelink/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:safelink/features/chatbot/presentation/widgets/quick_action.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController _chatController = Get.put(
    ChatController(chatService: Get.find<ChatbotService>()),
  );
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _chatController.sendMessage(text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _sendQuickAction(String action) {
    _chatController.sendMessage(action);
    _scrollToBottom();
  }

  void _showClearChatDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat', style: theme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to clear all messages?',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: theme.textTheme.bodyLarge),
          ),
          TextButton(
            onPressed: () {
              _chatController.clearChat();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientHeader(
              gradient: AppTheme.primaryGradient,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.white.withValues(alpha: 0.20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.10),
                          offset: const Offset(0, 10),
                          blurRadius: 15.r,
                          spreadRadius: -3.r,
                        ),
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.10),
                          offset: const Offset(0, 4),
                          blurRadius: 6.r,
                          spreadRadius: -4.r,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(AppAssets.assistantIcon),
                  ),
                  SizedBox(width: 15.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Assistant',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Obx(
                        () => Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _chatController.isOffline.value
                                    ? AppTheme.red
                                    : AppTheme.green,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              _chatController.isOffline.value
                                  ? 'Offline'
                                  : 'Online',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Obx(
                    () => _chatController.messages.isNotEmpty
                        ? InkWell(
                            onTap: _showClearChatDialog,
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.white.withValues(alpha: 0.20),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: AppTheme.white,
                                size: 20.sp,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_chatController.messages.isEmpty) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(25.r),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Help',
                                style: theme.textTheme.headlineLarge,
                              ),
                              SizedBox(height: 25.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: QuickAction(
                                      label: 'First Aid',
                                      icon: AppAssets.heartIcon,
                                      onTap: () =>
                                          _sendQuickAction('First aid tips'),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: QuickAction(
                                      label: 'Earthquake Safety',
                                      icon: AppAssets.shieldIcon,
                                      onTap: () => _sendQuickAction(
                                        'Earthquake safety tips',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: QuickAction(
                                      label: 'Flood Safety',
                                      icon: AppAssets.dropletsIcon,
                                      onTap: () =>
                                          _sendQuickAction('Flood safety tips'),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: QuickAction(
                                      label: 'Medical Help',
                                      icon: AppAssets.waveIcon,
                                      onTap: () => _sendQuickAction(
                                        'Emergency helplines in Pakistan',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: theme.dividerColor),
                        Container(
                          margin: EdgeInsets.all(25.r),
                          padding: EdgeInsets.all(15.r),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assalam-o-Alaikum! 👋',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'I\'m your SafeLink Safety Assistant. I can help you with earthquake and flood safety tips, emergency contacts, and first aid guidance.',
                                style: theme.textTheme.headlineMedium,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Tap a quick action above or type your question below.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 10.h,
                  ),
                  itemCount: _chatController.messages.length,
                  itemBuilder: (context, index) {
                    final message = _chatController.messages[index];
                    return ChatBubble(message: message);
                  },
                );
              }),
            ),
            Divider(color: theme.dividerColor),
            Padding(
              padding: EdgeInsets.all(15.r),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      onSubmitted: (_) => _sendMessage(),
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        contentPadding: EdgeInsets.all(15.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(25.r),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: SvgPicture.asset(AppAssets.planeIcon),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
