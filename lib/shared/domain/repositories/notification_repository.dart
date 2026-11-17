import '../../../core/errors/result.dart';
import '../entities/app_notification.dart';

/// Stored reminder records (`notifications` collection).
abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications(String userId);

  Future<Result<void>> saveNotification(AppNotification notification);

  Future<Result<void>> markRead(String notificationId);

  Future<Result<void>> deleteNotification(String notificationId);

  Future<Result<void>> deleteAllForUser(String userId);
}
