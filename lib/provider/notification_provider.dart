import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parsi/provider/check_internet_connection.dart';
import '../core/PrefHelper/PrefHelpers.dart';
import '../core/utils.dart';
import '../models/notification_model.dart';
import '../core/network/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  // نال‌پذیر (Nullable) کردیم تا قبل از لود شدن دیتا ارور ندهد
  NotificationModel? notificationModel;

  bool loading = false;
  bool firstTimeOfflineError = false;
  final ApiService api = ApiService();

  // لیست آی‌دی‌های خوانده شده
  List<String> _readNotificationIds = [];
  static const String _readIdsKey = 'READ_NOTIFICATION_IDS';

  // --- Init Data ---
  Future<void> initData() async {
    // 1. لود کردن لیست خوانده‌شده‌ها از حافظه
    await _loadReadStatus();

    bool hasInternet = await CheckInternetConnection.checkInternetConnection();
    if (hasInternet) {
      await getAllNotification();
    } else {
      await _loadFromDb();
    }
  }

  // --- API Call ---
  Future<void> getAllNotification() async {
    // try {
      final res = await api.getAllNotification(await PrefHelpers.getUserId());
      if (res.statusCode == 200) {
        notificationModel = NotificationModel.fromJson(res.data['data']);
        // ذخیره در دیتابیس لوکال
        NotificationModel.saveToDB(notificationModel!);

        _sortNotifications(); // مرتب‌سازی

        loading = true;
        notifyListeners();
      } else {
        await _loadFromDb();
      }
    // } catch (e) {
    //   debugPrint("Error getAllNotification: $e");
    //   await _loadFromDb();
    // }
  }

  // --- DB Load ---
  Future<void> _loadFromDb() async {
    try {
      notificationModel = await NotificationModel.getDB();
      _sortNotifications();
      loading = true;
    } catch (e) {
      debugPrint("Error loading DB: $e");
      firstTimeOfflineError = true;
      loading = true; // لودینگ را تمام کن تا ارور نمایش داده شود
    }
    notifyListeners();
  }

  // --- Read Status Logic ---

  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _readNotificationIds = prefs.getStringList(_readIdsKey) ?? [];
    notifyListeners();
  }

  bool isRead(String id) {
    return _readNotificationIds.contains(id.toString());
  }

  // این متد وقتی وارد تب میشوید صدا زده میشود تا همه را یکجا بخواند
  Future<void> markListAsRead(List<dynamic> items) async {
    bool hasChanges = false;
    for (var item in items) {
      String id = item.id.toString();
      if (!_readNotificationIds.contains(id)) {
        _readNotificationIds.add(id);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readIdsKey, _readNotificationIds);
      // این خط باعث میشود عدد کانتر در AppBar هم آپدیت شود
      notifyListeners();
    }
  }

  // --- Unread Count Logic (برای استفاده در خارج از صفحه) ---
  int get unreadCount {
    // اگر هنوز دیتا لود نشده یا مدل نال است، 0 برگردان
    if (!loading || notificationModel == null) return 0;

    int unreadLocal = notificationModel!.localNotification
        .where((item) => !_readNotificationIds.contains(item.id.toString()))
        .length;

    int unreadMy = notificationModel!.myNotification
        .where((item) => !_readNotificationIds.contains(item.id.toString()))
        .length;

    return unreadLocal + unreadMy;
  }

  // تعداد خوانده نشده برای هر تب (برای بج داخلی)
  int getUnreadCountForList(List<dynamic> list) {
    return list
        .where((item) => !_readNotificationIds.contains(item.id.toString()))
        .length;
  }

  // --- Sorting ---
  void _sortNotifications() {
    if (notificationModel == null) return;

    notificationModel!.localNotification.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });

    notificationModel!.myNotification.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // دکمه بازگشت (کد خودتان)
  Align backIconBtn(Size size, BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            width: 55,
            height: 55,
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ).neuShape,
        ),
      ),
    );
  }
}