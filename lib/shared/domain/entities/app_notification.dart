import 'map_utils.dart';

enum NotificationType {
  interview('Interview'),
  followUp('Follow-up'),
  deadline('Deadline'),
  general('General');

  const NotificationType(this.label);
  final String label;
}

/// `notifications` collection document: a stored reminder record.
class AppNotification {
  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.scheduledDate,
    this.isRead = false,
    this.type = NotificationType.general,
    this.applicationId,
  });

  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final DateTime scheduledDate;
  final bool isRead;
  final NotificationType type;
  final String? applicationId;

  AppNotification copyWith({bool? isRead, DateTime? scheduledDate}) =>
      AppNotification(
        notificationId: notificationId,
        userId: userId,
        title: title,
        message: message,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        isRead: isRead ?? this.isRead,
        type: type,
        applicationId: applicationId,
      );

  Map<String, Object?> toMap() => {
        'notificationId': notificationId,
        'userId': userId,
        'title': title,
        'message': message,
        'scheduledDate': dateToStr(scheduledDate),
        'isRead': isRead,
        'type': type.name,
        'applicationId': applicationId,
      };

  factory AppNotification.fromMap(Map<String, Object?> m) => AppNotification(
        notificationId: str(m['notificationId']),
        userId: str(m['userId']),
        title: str(m['title']),
        message: str(m['message']),
        scheduledDate: dateOf(m['scheduledDate']),
        isRead: boolOf(m['isRead']),
        type: enumOf(NotificationType.values, m['type'], NotificationType.general),
        applicationId: strOrNull(m['applicationId']),
      );
}
