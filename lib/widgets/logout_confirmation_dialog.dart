import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/logout_service.dart';

class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _clearAllDevices = false;
  bool _isLoggingOut = false;

  void _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await LogoutService.logout(clearAll: _clearAllDevices);
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('logout_confirmation'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logout from other devices option
            RadioListTile<bool>(
              title: Text('logout_from_other_devices'.tr),
              subtitle: Text(
                'logout_from_other_devices_description'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              value: true,
              groupValue: _clearAllDevices,
              onChanged: _isLoggingOut ? null : (value) {
                setState(() {
                  _clearAllDevices = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 8),
            
            // Logout from current device only option
            RadioListTile<bool>(
              title: Text('logout_current_device_only'.tr),
              subtitle: Text(
                'logout_current_device_only_description'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              value: false,
              groupValue: _clearAllDevices,
              onChanged: _isLoggingOut ? null : (value) {
                setState(() {
                  _clearAllDevices = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoggingOut ? null : () {
            Get.back();
          },
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          onPressed: _isLoggingOut ? null : _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoggingOut
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('confirm_logout'.tr),
        ),
      ],
    );
  }
}
