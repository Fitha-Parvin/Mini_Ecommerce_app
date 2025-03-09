import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void addNotification() {
    _unreadCount++;
    notifyListeners();
  }

  void clearNotifications() {
    _unreadCount = 0;
    notifyListeners();
  }
}
