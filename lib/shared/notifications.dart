import 'package:flutter/material.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

// Add a global key for ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
// Add a global reference to the notification service
NotificationService? _globalNotificationService;

class Notification {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  Notification({
    required this.title,
    required this.message,
    this.isRead = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class NotificationService extends ChangeNotifier {
  final List<Notification> _notifications = [];

  List<Notification> get notifications => _notifications;
  int get unreadCount => _notifications.where((note) => !note.isRead).length;

  void addNotification(String title, String message) {
    _notifications.insert(
      0,
      Notification(
        title: title,
        message: message,
      ),
    );
    notifyListeners();
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      _notifications[i] = Notification(
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        isRead: true,
      );
    }
    notifyListeners();
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      final notification = _notifications[index];
      _notifications[index] = Notification(
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Register this service as the global instance
  void registerAsGlobal() {
    _globalNotificationService = this;
  }

  // Modified static method for safe access
  static void addGlobalNotification(BuildContext? context, String title, String message) {
    // Try to use the provided context first, with error handling
    if (context != null) {
      try {
        Provider.of<NotificationService>(context, listen: false)
            .addNotification(title, message);
        return;
      } catch (e) {
        // Context no longer valid, fall back to global service
      }
    }
    
    // Fall back to global reference if context fails
    _globalNotificationService?.addNotification(title, message);
  }

  /// Records the message in the notifications list and shows it briefly at
  /// the bottom. Uses the app-wide messenger, so a closed screen's context is
  /// never touched.
  static void showToast(BuildContext? context, String title, String message) {
    addGlobalNotification(context, title, message);
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$title  ', style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: message),
              ],
            ),
          ),
        ),
      );
  }
}

/// The notifications list, opened from the bell.
class NotificationDropdown extends StatelessWidget {
  const NotificationDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<NotificationService>(context);
    final notifications = service.notifications;
    final c = context.ink;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.xl),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.m, Space.m, Space.s, Space.s),
              child: Row(
                children: [
                  Expanded(child: Text('Notifications', style: context.type.titleLarge)),
                  if (service.unreadCount > 0)
                    TextButton(onPressed: service.markAllAsRead, child: const Text('Mark all read')),
                ],
              ),
            ),
            const InkRule(strong: true),
            if (notifications.isEmpty)
              const EmptyState(message: 'Nothing new. Reminders and changes show up here.', artHeight: 64)
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const InkRule(),
                  itemBuilder: (context, index) {
                    final note = notifications[index];
                    return InkWell(
                      onTap: () => service.markAsRead(index),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(Space.m, Space.gutter, Space.xs, Space.gutter),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 7, right: Space.s),
                              decoration: BoxDecoration(
                                color: note.isRead ? Colors.transparent : c.ink,
                                border: Border.all(color: c.ink, width: Strokes.hairline),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    style: context.type.titleSmall?.copyWith(
                                      fontWeight: note.isRead ? FontWeight.w500 : FontWeight.w700,
                                    ),
                                  ),
                                  Text(note.message, style: context.type.bodyMedium),
                                  const SizedBox(height: 2),
                                  Text(_formatTimestamp(note.timestamp), style: context.type.bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove',
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => service.removeNotification(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const InkRule(strong: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.xs),
              child: Row(
                children: [
                  if (notifications.isNotEmpty)
                    TextButton(onPressed: service.clearAll, child: const Text('Clear all')),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    return PlannerFormat.dayTime(timestamp, PlannerFormat.clock(timestamp.hour, timestamp.minute));
  }
}
