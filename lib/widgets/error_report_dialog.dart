import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../setup_files/error_logger.dart';

class ErrorReportDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final bool showContactOption;

  const ErrorReportDialog({
    Key? key,
    this.title = 'Report an Issue',
    this.message = 'Would you like to share error logs or contact support?',
    this.showContactOption = true,
  }) : super(key: key);

  static Future<void> show({
    BuildContext? context,
    String? title,
    String? message,
    bool showContactOption = true,
  }) async {
    return await showDialog<void>(
      context: context ?? Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) => ErrorReportDialog(
        title: title,
        message: message,
        showContactOption: showContactOption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AlertDialog(
      title: Text(
        title ?? 'Report an Issue',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: Text(
        message ?? 'Would you like to share error logs or contact support?',
        style: textTheme.bodyLarge,
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
        if (showContactOption)
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await ErrorLogger.contactSupportOnTelegram();
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not open Telegram. Please install it first.',
                    ),
                  ),
                );
              }
            },
            child: const Text('CONTACT SUPPORT'),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            Get.back();
            try {
              await ErrorLogger.shareErrorLogs();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Failed to share error logs. Please try again.',
                    ),
                  ),
                );
              }
            }
          },
          child: const Text('SHARE LOGS'),
        ),
      ],
    );
  }
}
