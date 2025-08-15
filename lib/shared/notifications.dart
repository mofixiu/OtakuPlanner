import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/theme.dart';
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

  // Update the static showToast method to never use context that might be disposed
  static void showToast(BuildContext? context, String title, String message) {
    // Add to notification list first (this can still use context safely)
    addGlobalNotification(context, title, message);
    
    // Get theme-aware colors if context is available
    Color snackBarColor;
    Color textColor = Colors.white;
    
    // Store context reference before any async operations
    BuildContext? safeContext = context;
    bool contextIsValid = safeContext != null;
    bool isDarkMode = false;
    
    // Try to read theme info immediately (not in a future)
    try {
      if (contextIsValid) {
        isDarkMode = Theme.of(safeContext).brightness == Brightness.dark;
        
        // Use theme-aware colors
        if (title.contains('Completed')) {
          snackBarColor = isDarkMode ? Colors.green.shade700 : Colors.green;
        } else {
          snackBarColor = OtakuPlannerTheme.getButtonColor(safeContext);
        }
      } else {
        // Fallback colors if no context
        snackBarColor = title.contains('Completed') ? Colors.green : Color(0xFF1E293B);
      }
    } catch (e) {
      // If any error occurs reading the context, use fallback colors
      contextIsValid = false;
      snackBarColor = title.contains('Completed') ? Colors.green : Color(0xFF1E293B);
    }
    
    // Create the SnackBar
    final snackBar = SnackBar(
      content: Row(
        children: [
          title.contains('Completed') 
              ? Icon(Icons.check_circle_outline, color: textColor)
              : Icon(Icons.notifications_active, color: textColor),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(message, style: TextStyle(color: textColor)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: snackBarColor,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
//     final scaffoldMessenger = rootScaffoldMessengerKey.currentState;
// if (scaffoldMessenger == null) {
//   print("ERROR: ScaffoldMessenger is null! Make sure to set scaffoldMessengerKey in MaterialApp");
  
//   // Last resort - try to find any active context to show notification
//   try {
//     // Find the most recent navigator to show our snackbar
//     final navigatorKey = GlobalKey<NavigatorState>();
//     if (navigatorKey.currentState?.overlay?.context != null) {
//       ScaffoldMessenger.of(navigatorKey.currentState!.overlay!.context)
//           .showSnackBar(snackBar);
//     }
//   } catch (e) {
//     print("Couldn't show notification: $e");
//   }
// } else {
//   // Show with our global key
//   scaffoldMessenger.showSnackBar(snackBar);
// }
    
    // IMPORTANT: Always use the global key instead of context
    // This ensures we don't use a potentially disposed context
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}

class NotificationDropdown extends StatelessWidget {
  const NotificationDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<NotificationService>(context).notifications;
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    // Get theme colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);

    return Dialog(
      backgroundColor: cardColor,
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
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          notificationService.markAllAsRead();
                        },
                        child: Text(
                          "Mark all as read",
                          style: TextStyle(
                            color: isDarkMode ? Colors.lightBlue : Colors.blue,
                            fontSize: 16
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: borderColor.withOpacity(0.5)),
            notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                            color: textColor.withOpacity(0.5),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No notifications yet",
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: borderColor.withOpacity(0.3),
                      ),
                      itemBuilder: (context, index) {
                        final note = notifications[index];
                        final isCompleted = note.title.contains('Completed');
                        
                        // Theme-aware notification item colors
                        final itemBgColor = note.isRead
                            ? null
                            : isDarkMode
                                ? buttonColor.withOpacity(0.2)
                                : Color(0xFFF0F9FF);
                        
                        final iconColor = isCompleted
                            ? isDarkMode ? Colors.lightGreen : Colors.green
                            : isDarkMode ? Colors.lightBlue : Colors.blue;
                        
                        final iconBgColor = isCompleted
                            ? (isDarkMode ? Colors.green.shade900 : Colors.green.withOpacity(0.1))
                            : (isDarkMode ? Colors.blue.shade900 : Colors.blue.withOpacity(0.1));
                            
                        return ListTile(
                          tileColor: itemBgColor,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                isCompleted
                                    ? Icons.check_circle_outline
                                    : Icons.notifications_active,
                                color: iconColor,
                                size: 20,
                              ),
                            ),
                          ),
                          title: Text(
                            note.title,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: note.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.message,
                                style: TextStyle(color: textColor.withOpacity(0.7)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatTimestamp(note.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: textColor.withOpacity(0.7),
                            ),
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
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: isDarkMode ? Colors.lightBlue : Colors.blue,
                    ),
                  ),
                ),
              ],
            )
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