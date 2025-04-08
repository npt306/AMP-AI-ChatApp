import 'package:flutter/material.dart';
import 'custom_notification.dart';
class CustomNotificationService {
  static OverlayEntry? _currentNotification;

  static void show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    VoidCallback? onTap,
    bool autoDismiss = true,
  }) {
    _currentNotification?.remove();
    
    OverlayState? overlayState = Overlay.of(context);
    
    _currentNotification = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 0,
        right: 0,
        child: CustomNotification(
          message: message,
          type: type,
          duration: duration,
          onDismiss: () {
            _currentNotification?.remove();
            _currentNotification = null;
            onDismiss?.call();
          },
          onTap: onTap,
          autoDismiss: autoDismiss,
        ),
      ),
    );

    overlayState.insert(_currentNotification!);
  }

  static void dismiss() {
    _currentNotification?.remove();
    _currentNotification = null;
  }
}