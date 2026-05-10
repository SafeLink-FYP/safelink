import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/chatbot/controllers/chat_controller.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:safelink/features/chatbot/presentation/widgets/helpline_button.dart';
import 'package:safelink/features/chatbot/presentation/widgets/message_action_sheet.dart';
import 'package:safelink/features/chatbot/presentation/widgets/source_citation_footer.dart';
import 'package:safelink/features/chatbot/presentation/widgets/typing_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

// Audit F12: schemes the markdown link handler is allowed to launch. Anything
// else (javascript:, data:, file:, etc.) is silently rejected.
const _allowedLinkSchemes = {'http', 'https', 'tel'};

// TODO(phase5b): replace client-side parsing with backend SuggestedAction
// schema (label + type + payload). Brittle but ships now.
//
// Suggested-action labels of the form "Call <name> <number> [...]" should
// dial instead of being re-sent as a chat prompt. Group 1 is the captured
// number, in one of three shapes (LONGEST FIRST — regex alternation is
// left-to-right preference, not longest match; if `\d{3,5}` came first
// it would gobble "021" out of "021-99213340" and lose the rest):
//   1. International:  +92 21 99213340  /  +92-21-99213340
//   2. Pakistan PSTN:  021-99213340     /  042 99205316
//   3. Short code:     115 / 1122 / 1199
// The leading `\b` was dropped because `+` is a non-word character and a
// space→`+` transition is non-word→non-word — `\b` would refuse to fire at
// e.g. "Call NDMA Helpline +92...".
@visibleForTesting
final RegExp dialActionRegex = RegExp(
  r'^Call\s+.*?(\+?\d{1,3}[-\s]\d{2,4}[-\s]\d{6,8}'  // international
  r'|0\d{2,3}[-\s]\d{6,8}'                             // Pakistan PSTN
  r'|\d{3,5})\b',                                      // short code
  caseSensitive: false,
);

/// Returns the dial-able phone number embedded in a "Call ..." suggested-
/// action label, or null when the label isn't a dial action and should be
/// dispatched as a regular chat prompt instead.
@visibleForTesting
String? tryParseDialNumber(String actionLabel) {
  return dialActionRegex.firstMatch(actionLabel)?.group(1);
}

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final ChatController _chatController = Get.find<ChatController>();

  Future<void> _callHelpline(String number, {BuildContext? context}) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open phone dialer on this device'),
        ),
      );
    }
  }

  /// Two-step confirmation before dialing. Friction is intentional —
  /// accidentally calling 115 (Edhi) ties up an emergency dispatcher.
  Future<void> _confirmAndCall(
    BuildContext context,
    String number,
    String fullLabel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Place call?'),
        content: Text(
          'This will open your phone dialer to call $number.\n\n$fullLabel',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.green),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Call'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _callHelpline(number, context: context);
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
    // Audit F5: previously the "Feedback saved locally" branch was a lie —
    // nothing was saved anywhere. The repository now enqueues to the
    // FeedbackOutboxService when offline and returns true; this toast only
    // shows the failure copy if the repo genuinely couldn't queue it (e.g.,
    // no outbox wired in tests).
    final success = await _chatController.submitFeedback(messageId, helpful);
    if (mounted) {
      final isOffline = _chatController.isOffline.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (isOffline
                      ? 'Saved — will sync when online'
                      : 'Thank you for your feedback!')
                : 'Could not save feedback. Try again later.',
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
    final isHigh = widget.message.urgencyLevel == UrgencyLevel.high;
    final isMedium = widget.message.urgencyLevel == UrgencyLevel.medium;

    if (isLoading) {
      return const TypingIndicator();
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

    final bubble = Align(
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
                    : isHigh
                    ? AppTheme.orange.withValues(alpha: 0.08)
                    : isMedium
                    ? AppTheme.orange.withValues(alpha: 0.04)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(15.r),
                // Phase 1: distinct urgency tiers for medium / high / critical.
                // Phase 4 will add the pulsing siren animation for critical.
                border: !isUser && (isEmergency || isCritical)
                    ? Border.all(
                        color: AppTheme.red.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : !isUser && isHigh
                    ? Border(
                        left: BorderSide(color: AppTheme.orange, width: 3),
                      )
                    : !isUser && isMedium
                    ? Border(
                        left: BorderSide(
                          color: AppTheme.orange.withValues(alpha: 0.5),
                          width: 2,
                        ),
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
                  if (widget.message.content.isEmpty &&
                      widget.message.isStreaming)
                    // Phase 4: stream-pre-roll. The bubble has been added
                    // but no delta has arrived yet — show the typing dots.
                    const TypingIndicator()
                  else
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        MarkdownBody(
                          data: widget.message.content,
                          shrinkWrap: true,
                          fitContent: true,
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
                            // Audit F12: only http/https/tel can be launched.
                            // Reject javascript:, data:, file:, etc. silently.
                            if (href == null) return;
                            final uri = Uri.tryParse(href);
                            if (uri == null) return;
                            if (!_allowedLinkSchemes.contains(uri.scheme)) return;
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                        if (widget.message.isStreaming) ...[
                          SizedBox(width: 4.w),
                          _StreamingCursor(
                            color:
                                isUser ? AppTheme.white : theme.hintColor,
                          ),
                        ],
                      ],
                    ),

                  if (!isUser && widget.message.helplines.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    // Audit F15: was an inline _buildHelplineButton method
                    // duplicating the orphaned HelplineButton widget. Now
                    // uses the widget directly.
                    // Phase 5a.2: tap routes through _confirmAndCall (two-step
                    // confirmation — same friction as the suggested-action
                    // chip dialer). Semantics wrapper announces the full
                    // "Call <name>, <number>" to TalkBack/VoiceOver.
                    ...widget.message.helplines.take(5).map(
                          (helpline) => Semantics(
                            button: true,
                            label:
                                'Call ${helpline.name}, ${helpline.number}',
                            child: HelplineButton(
                              helpline: helpline,
                              onTap: () => _confirmAndCall(
                                context,
                                helpline.number,
                                '${helpline.name} — ${helpline.number}',
                              ),
                            ),
                          ),
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
                          // Phase 5a.2: chips that look like "Call 115 (Edhi)"
                          // dispatch to the dialer (with confirmation) instead
                          // of being re-sent as a chat prompt. Anything that
                          // doesn't match the dial regex falls back to the
                          // legacy sendMessage path.
                          onTap: () {
                            final number = tryParseDialNumber(action);
                            if (number != null) {
                              _confirmAndCall(context, number, action);
                            } else {
                              _chatController.sendMessage(action);
                            }
                          },
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
                  if (!isUser && widget.message.sources.isNotEmpty)
                    SourceCitationFooter(sources: widget.message.sources),
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

    // Phase 4 — long-press on bot messages opens the action sheet (Copy /
    // Share / Report wrong info). User and system bubbles don't get the
    // gesture (nothing to share / report on a user message).
    if (isUser) return bubble;
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showMessageActions(context, widget.message);
      },
      child: Semantics(
        label: 'Bot message. Long-press for options.',
        child: bubble,
      ),
    );
  }

}

/// Phase 4 — small blinking cursor used during streaming. Stops blinking
/// when reduced-motion is on (steady solid block).
class _StreamingCursor extends StatefulWidget {
  final Color color;
  const _StreamingCursor({required this.color});

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final alpha = disable ? 1.0 : (0.3 + 0.7 * _ctrl.value);
        return Container(
          width: 8.w,
          height: 16.h,
          margin: EdgeInsets.only(bottom: 2.h),
          color: widget.color.withValues(alpha: alpha),
        );
      },
    );
  }
}
