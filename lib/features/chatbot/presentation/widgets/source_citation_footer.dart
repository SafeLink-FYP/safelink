import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:url_launcher/url_launcher.dart';

/// Small "Based on: NDMA, PMD" footer rendered below LLM-grounded responses.
/// Tappable — expands to a full list of sources with launchable URLs (where
/// allowed; the chat bubble's URL allowlist still gates external launches).
class SourceCitationFooter extends StatefulWidget {
  final List<SourceCitation> sources;
  const SourceCitationFooter({super.key, required this.sources});

  @override
  State<SourceCitationFooter> createState() => _SourceCitationFooterState();
}

class _SourceCitationFooterState extends State<SourceCitationFooter> {
  bool _expanded = false;

  static const _allowedSchemes = {'http', 'https'};

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !_allowedSchemes.contains(uri.scheme)) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.sources.isEmpty) return const SizedBox.shrink();

    final summary = widget.sources
        .take(3)
        .map((s) => s.name)
        .join(', ');

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: 'Source citations: $summary. Tap to expand.',
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(6.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 12.sp,
                      color: theme.hintColor,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        'Based on: $summary',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      _expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 14.sp,
                      color: theme.hintColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: !_expanded
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final s in widget.sources)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: s.url == null
                                ? Text(
                                    '• ${s.name}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  )
                                : InkWell(
                                    onTap: () => _launch(s.url!),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '• ${s.name}',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppTheme.primaryColor,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(
                                          Icons.open_in_new,
                                          size: 10.sp,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
