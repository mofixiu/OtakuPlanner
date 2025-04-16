import 'package:flutter/material.dart';
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

  // Modified static method for safe toast display
  static void showToast(BuildContext? context, String title, String message) {
    // Add to notification list
    addGlobalNotification(context, title, message);
    
    // Create the SnackBar
    final snackBar = SnackBar(
      content: Row(
        children: [
          title.contains('Completed') 
              ? Icon(Icons.check_circle_outline, color: Colors.white)
              : Icon(Icons.notifications_active, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(message),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: title.contains('Completed') 
          ? Colors.green 
          : Color(0xFF1E293B),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    
    // Try context first
    if (context != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } catch (e) {
        // Context no longer valid, will fall back to global key
      }
    }
    
    // Fall back to global key
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}

class NotificationDropdown extends StatelessWidget {
  const NotificationDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<NotificationService>(context).notifications;
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          notificationService.markAllAsRead();
                        },
                        child: Text("Mark all as read",
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ),
                      SizedBox(width: 8),
                      
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No notifications yet",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final note = notifications[index];
                        return ListTile(
                          tileColor: note.isRead ? null : Color(0xFFF0F9FF),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: note.title.contains('Completed')
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                note.title.contains('Completed')
                                    ? Icons.check_circle_outline
                                    : Icons.notifications_active,
                                color: note.title.contains('Completed')
                                    ? Colors.green
                                    : Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                          title: Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: note.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.message),
                              SizedBox(height: 4),
                              Text(
                                _formatTimestamp(note.timestamp),
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.close, size: 18),
                            onPressed: () {
                              notificationService.removeNotification(index);
                            },
                          ),
                          onTap: () {
                            notificationService.markAsRead(index);
                          },
                          isThreeLine: true,
                        );
                      },
                    ),
                  ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              TextButton(
                        onPressed: () {
                          notificationService.clearAll();
                        },
                        child: Text(
                          "Clear all",
                          style: TextStyle(color: Colors.red,fontSize: 12),
                        ),
                      ),
                        TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
            ],)
          
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    }
  }
}

// Badge widget to show unread notification count
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showZero;

  const NotificationBadge({
    Key? key,
    required this.child,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        final count = notificationService.unreadCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            child,
            if (count > 0 || showZero)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}