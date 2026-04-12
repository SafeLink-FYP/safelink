import 'package:get/get.dart';
import 'package:safelink/features/dashboard/models/notification_model.dart';
import 'package:safelink/features/dashboard/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final isLoading = false.obs;
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      notifications.value = await _notificationService.getNotifications();
      unreadCount.value = await _notificationService.getUnreadCount();
    } catch (e) {
      Get.log('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      final idx = notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !notifications[idx].isRead) {
        notifications[idx] = notifications[idx].copyWith(isRead: true);
        unreadCount.value = (unreadCount.value - 1).clamp(0, 9999);
      }
    } catch (e) {
      Get.log('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      Get.log('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
    } catch (e) {
      Get.log('Error deleting notification: $e');
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}
