import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/chatbot/controllers/chat_controller.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final ChatController _chatController = Get.find<ChatController>();

  Future<void> _callHelpline(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _submitFeedback(String messageId, bool helpful) async {
    final success = await _chatController.submitFeedback(messageId, helpful);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Thank you for your feedback!' : 'Feedback saved locally',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.type == MessageType.user;
    final isSystem = widget.message.type == MessageType.system;
    final isLoading = widget.message.isLoading;
    final isEmergency = widget.message.isEmergency;
    final isCritical = widget.message.urgencyLevel == UrgencyLevel.critical;

    if (isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h, right: 60.w),
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(strokeWidth: 1.w),
              ),
              SizedBox(width: 10.w),
              Text('Typing...', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    if (isSystem) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 30.w),
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            widget.message.content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.primaryColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10.h,
          left: isUser ? 60.w : 0,
          right: isUser ? 0 : 60.w,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isEmergency || isCritical) ...[
              Container(
                margin: EdgeInsets.only(bottom: 5.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.red,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 14.sp, color: AppTheme.white),
                    SizedBox(width: 5.w),
                    Text(
                      'EMERGENCY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.primaryGradient : null,
                color: isUser
                    ? null
                    : (isEmergency || isCritical)
                    ? AppTheme.red.withValues(alpha: 0.1)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(15.r),
                border: (isEmergency || isCritical) && !isUser
                    ? Border.all(
                        color: AppTheme.red.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.black.withValues(alpha: 0.05),
                    blurRadius: 5.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: widget.message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser ? AppTheme.white : null,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUser ? AppTheme.white : null,
                      ),
                      listBullet: TextStyle(
                        color: isUser ? AppTheme.white : null,
                      ),
                    ),
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final uri = Uri.parse(href);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                  ),

                  if (!isUser && widget.message.helplines.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    ...widget.message.helplines
                        .take(5)
                        .map(
                          (helpline) => _buildHelplineButton(theme, helpline),
                        ),
                  ],
                  if (!isUser &&
                      widget.message.suggestedActions.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: widget.message.suggestedActions.take(4).map((
                        action,
                      ) {
                        return GestureDetector(
                          onTap: () => _chatController.sendMessage(action),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              action,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(widget.message.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 10.sp,
                    ),
                  ),
                  if (!isUser && !isSystem) ...[
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () => _submitFeedback(widget.message.id, true),
                      child: Icon(
                        Icons.thumb_up_outlined,
                        size: 14.sp,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _submitFeedback(widget.message.id, false),
                      child: Icon(
                        Icons.thumb_down_outlined,
                        size: 14.sp,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineButton(ThemeData theme, HelplineInfo helpline) {
    return GestureDetector(
      onTap: () => _callHelpline(helpline.number),
      child: Container(
        margin: EdgeInsets.only(bottom: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppTheme.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone, size: 14.sp, color: AppTheme.green),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          helpline.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (helpline.available24x7) ...[
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.green,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '24/7',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    helpline.number,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.green.withValues(alpha: 0.8),
                    ),
                  ),
                  if (helpline.description != null &&
                      helpline.description!.isNotEmpty)
                    Text(
                      helpline.description!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 9.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Icon(Icons.call, size: 18.sp, color: AppTheme.green),
          ],
        ),
      ),
    );
  }
}
