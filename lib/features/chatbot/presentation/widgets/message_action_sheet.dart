import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../models/chat_models.dart';

/// Long-press action sheet for a bot message: Copy / Share / Report wrong info.
///
/// Phase 4 wires this to long-press in `chat_bubble.dart`. The sheet is
/// `Semantics`-labelled per item for screen-reader accessibility.
Future<void> showMessageActions(
  BuildContext context,
  ChatMessage message,
) async {
  final controller = Get.find<ChatController>();
  final messenger = ScaffoldMessenger.of(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) {
      final theme = Theme.of(sheetCtx);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: 'Copy message text to clipboard',
              child: ListTile(
                leading: const Icon(Icons.copy_all_outlined),
                title: Text('Copy', style: theme.textTheme.bodyLarge),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: message.content));
                  if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            Semantics(
              button: true,
              label: 'Share message via system share sheet',
              child: ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text('Share', style: theme.textTheme.bodyLarge),
                onTap: () async {
                  // Phase 4 v1: copy to clipboard + flag — full
                  // platform-share will land alongside the share_plus
                  // dependency in a future cycle. The user-facing toast
                  // still confirms an action was taken.
                  await Clipboard.setData(ClipboardData(text: message.content));
                  if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Copied for sharing — paste anywhere',
                      ),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            Semantics(
              button: true,
              label: 'Report this response as incorrect',
              child: ListTile(
                leading: const Icon(
                  Icons.report_gmailerrorred_outlined,
                  color: Colors.redAccent,
                ),
                title: Text(
                  'Report wrong info',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () async {
                  final ok = await controller.reportWrongInfo(message.id);
                  if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Reported. Thanks — flagged for review.'
                            : 'Could not file report. Try again later.',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      );
    },
  );
}
