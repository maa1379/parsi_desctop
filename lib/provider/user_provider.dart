import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/core/number_formatters.dart';
import 'package:parsi/provider/v2ray_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/PrefHelper/PrefHelpers.dart';
import '../core/network/ApiHelper.dart';
import '../core/network/api_service.dart';
import '../core/view_helper.dart';
import '../main.dart';
import '../models/account_info_model.dart';
import '../models/period_model.dart' as p;
import '../models/wallet_model.dart';
import '../screens/widgets/showCooperationDialog.dart';
import 'check_internet_connection.dart';

enum AccountStatus {
  none,
  isConnect, // اشتراک دارد و فعال است
  isTrafficEndOrIsExpired, // ترافیک تمام شده یا منقضی شده
  error, // خطایی رخ داده
}

class UserProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  List<String> availableDurations = []; // لیست دسته‌ها (مثلا: 1، 2، 3)
  String selectedDurationTab = "";
  String? _lastProcessedLink;
  // --- وضعیت‌های Loading ---
  bool initialUserLoading = false;
  bool paymentPeriodsLoading = false;
  bool walletLoading = false;
  bool accountInfoLoading = false;

  // --- New Flag ---
  bool firstTimeOfflineError = false;

  // --- UserProvider (Original) ---
  AccountStatus accountStatus = AccountStatus.none;
  String? errorMessage;
  final TextEditingController subCode = TextEditingController();
  Sub? subModel;

  // --- ProfileProvider ---
  AccountInfoModel? accountInfoModel;

  // --- PaymentProvider ---
  final PageController pageController = PageController(viewportFraction: 0.7);
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController note = TextEditingController();
  TextEditingController offerCode = TextEditingController();
  int currentIndex = 1;
  p.PeriodModel? periodList;
  String cardNumber = "";
  String cardName = "";
  String cardNumber2 = "";
  String cardName2 = "";
  String cardNumber3 = "";
  String cardName3 = "";
  String cardNumber4 = "";
  String cardName4 = "";
  String path = "";
  String periodId = "";
  int periodPrice = 0;
  bool isActivePayment = false;
  bool is_cart_active = false;
  bool forOthers = false;
  bool isConfirmOffer = false;
  bool isPercent = false;
  String percent = "0";

  // --- WalletProvider ---
  WalletModel? walletModel;
  TextEditingController walletPriceController = TextEditingController();
  List<PriceModel> listOfPrice = [
    PriceModel(price: 100000, selected: true),
    PriceModel(price: 200000, selected: false),
    PriceModel(price: 300000, selected: false),
    PriceModel(price: 400000, selected: false),
    PriceModel(price: 500000, selected: false),
    PriceModel(price: 1000000, selected: false),
  ];


  // --- متد Init جامع (تغییر یافته) ---
  Future initializeApp(BuildContext context) async {
    firstTimeOfflineError = false;

    // ۱. بارگذاری داده‌های کش
    subModel = await Sub.getDB();
    periodList = await p.PeriodModel.getDB();
    accountInfoModel = await AccountInfoModel.getDB();

    // اگر کش موجود بود، سریعا لودینگ را فالس کن تا کاربر معطل نشود (Optimistic UI)
    if (subModel != null) {
      initialUserLoading = true;
    }

    _validateCachedSub();
    notifyListeners();

    // ۲. بررسی اتصال اینترنت
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      debugPrint("--- OFFLINE MODE ---");
      // فقط اگر هیچ دیتایی نداشتیم ارور آفلاین بده
      if (subModel == null && periodList == null && accountInfoModel == null) {
        firstTimeOfflineError = true;
        // حتی در حالت آفلاین هم باید لودینگ تمام شود
        initialUserLoading = true;
        notifyListeners();
      }
    } else {
      debugPrint("--- ONLINE MODE ---");
      await _setDeviceInfo();
      await _getUserInfo();
      await Future.wait([
        getAllSubPeriod(),
        getWallet(),
        getPayInfo(),
        getAccountInfo(),
      ]);

      await getActiveSubAccount(isBackgroundCheck: false);
      try {} catch (e) {
        debugPrint("Error in initializeApp: $e");
      } finally {
        initialUserLoading = true;
        notifyListeners();
      }
    }

    _initDeepLinks(context);
  }

  Future initializeApp2(BuildContext context) async {
    firstTimeOfflineError = false;

    // ۱. بارگذاری داده‌های کش
    subModel = await Sub.getDB();
    periodList = await p.PeriodModel.getDB();
    accountInfoModel = await AccountInfoModel.getDB();

    // اگر کش موجود بود، سریعا لودینگ را فالس کن تا کاربر معطل نشود (Optimistic UI)
    if (subModel != null) {
      initialUserLoading = true;
    }

    _validateCachedSub();
    notifyListeners();

    // ۲. بررسی اتصال اینترنت
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      debugPrint("--- OFFLINE MODE ---");
      // فقط اگر هیچ دیتایی نداشتیم ارور آفلاین بده
      if (subModel == null && periodList == null && accountInfoModel == null) {
        firstTimeOfflineError = true;
        // حتی در حالت آفلاین هم باید لودینگ تمام شود
        initialUserLoading = true;
        notifyListeners();
      }
    } else {
      debugPrint("--- ONLINE MODE ---");
      try {
        await _setDeviceInfo();
        await _getUserInfo();
        await Future.wait([
          // getAllSubPeriod(),
          getWallet(), // getPayInfo(),
          getAccountInfo(), // _initFCM(),
        ]);

        await getActiveSubAccount(isBackgroundCheck: false);
      } catch (e) {
        debugPrint("Error in initializeApp: $e");
      } finally {
        initialUserLoading = true;
        notifyListeners();
      }
    }

    _initDeepLinks(context);
  }

  void _validateCachedSub() async {
    if (subModel == null) {
      accountStatus = AccountStatus.none;
    } else {
      // اینجا چک می‌کنیم اگر قبلاً ذخیره شده که ترافیک تمام شده، وضعیت را قرمز کند
      if (subModel!.isExpired == false && subModel!.trafficEnd == false) {
        accountStatus = AccountStatus.isConnect;
      } else {
        accountStatus = AccountStatus.isTrafficEndOrIsExpired;
      }
    }
    if (subModel != null) {
      initialUserLoading = true;
    }
  }

  bool checkAccountStatus() {
    if (accountStatus == AccountStatus.isConnect) {
      return true;
    }
    return false;
  }

  Future<void> getActiveSubAccount({bool isBackgroundCheck = false}) async {
    final res = await api.getActiveAccount(
        await PrefHelpers.getSubCode(), await PrefHelpers.getDeviceId());
    if (res.statusCode == 200) {
      if (res.data['data']['sub'] != null) {
        final fetchedSub = Sub.fromJson(res.data['data']['sub']);
        await _updateLocalCache(fetchedSub);
        errorMessage = null;
      } else {
        // اگر کاربر اشتراک ندارد
        accountStatus = AccountStatus.none;
        // اگر لازم است دیتای قبلی را پاک کنید یا subModel را نال کنید
      }
    }
    try {} catch (e) {
      debugPrint("Error getActiveSubAccount: $e");
      if (!isBackgroundCheck) errorMessage = "خطای شبکه";
    }

    notifyListeners();
  }

  Future<void> _updateLocalCache(Sub newSubData) async {
    subModel = newSubData;
    await Sub.saveToDB(subModel!);
    await PrefHelpers.setLastSubCheckTimestamp(
        DateTime.now().toIso8601String());

    if (subModel?.isExpired == false && subModel?.trafficEnd == false) {
      accountStatus = AccountStatus.isConnect;
    } else {
      accountStatus = AccountStatus.isTrafficEndOrIsExpired;
    }
    notifyListeners();
  }

  Future<void> updateTrafficAccount(int traffic) async {
    try {
      final res = await api.updateTrafficAccount(
          await PrefHelpers.getSubCode(), traffic);
      await PrefHelpers.setTraffic(traffic.toString());
      if (res.statusCode == 200) {
        await PrefHelpers.removeTraffic();
        subModel = Sub.fromJson(res.data['data']['sub']);
        await Sub.saveToDB(subModel!);

        if (subModel?.isExpired == false && subModel?.trafficEnd == false) {
          // OK
        } else {
          accountStatus = AccountStatus.isTrafficEndOrIsExpired;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updateTrafficAccount: $e");
    }
  }

  // --- بقیه متدها بدون تغییر عمده ---
  void checkSubNumber(String code, bool isBack, BuildContext context) async {
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    final res = await api.checkSubNumber(code, await PrefHelpers.getUserId());
    // Navigator.of(context, rootNavigator: true)
    //     .pop();
    print(res.statusCode);
    print(res.data);
    if (res.statusCode == 200) {
      subModel = Sub.fromJson(res.data['data']['sub']);
      subCode.clear();
      await PrefHelpers.setSubCode(code);
      await Sub.saveToDB(subModel!);
      await _updateLocalCache(subModel!); // آپدیت وضعیت
      if (isBack) {
        context.pop();
      }
      bool status = res.data['data']['status'];
      if (status) {
        ViewHelper.showSuccessDialog("اشتراک شما با موفقیت فعال شد", context);
      } else {
        ViewHelper.showErrorDialog(
            "کد اشتراک، به حداکثر تعداد کاربر متصل رسیده است.", context);
      }
    } else if (res.statusCode == 500) {
      ViewHelper.showErrorDialog(
          "کد اشتراک، به حداکثر تعداد کاربر متصل رسیده است.", context);
    } else {
      ViewHelper.showErrorDialog(
          "کد اشتراک وارد شده، صحیح نمی باشد‌.", context);
    }
    notifyListeners();
  }

  String calculateTraffic() {
    if (subModel == null) return "0 GB";
    int traffic = double.parse(subModel!.traffic).toInt() * 1024 * 1024;
    int download = int.parse(subModel!.download);
    return (traffic - download).size().replaceAll("i", "");
  }

  Future<void> _setDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String fcmToken = "";
    try {
      fcmToken = "";
    } catch (e) {
      fcmToken = "";
    }
    if (await PrefHelpers.getDeviceId() == null) {
      String? udid;
      if(Platform.isWindows){
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        udid = windowsInfo.deviceId;
      }
      if(Platform.isLinux){
        LinuxDeviceInfo windowsInfo = await deviceInfo.linuxInfo;
        udid = windowsInfo.machineId;
      }
      if(Platform.isMacOS){
        MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        udid = macInfo.systemGUID;
      }
      await PrefHelpers.setDeviceId(udid ?? "");
    }
    final res =
    await api.setUserDeviceInfo(await PrefHelpers.getDeviceId(), fcmToken);
    if (res.statusCode == 200) {
      if (res.data['data']['sub_code'] != null) {
        await PrefHelpers.setSubCode(res.data['data']['sub_code']);
      }
      await PrefHelpers.removeToken();
      await PrefHelpers.setToken(res.data['data']['token']);
    }
    try {} catch (e) {
      debugPrint("Error setDeviceInfo: $e");
    }
    // نکته: اینجا دیگر _getUserInfo را صدا نمی‌زنیم چون در initializeApp صدا زده می‌شود
  }

  Future<void> _getUserInfo() async {
    final res = await api.getUserInfo(await PrefHelpers.getDeviceId());
    if (res.statusCode == 200) {
      await PrefHelpers.removeToken();
      await PrefHelpers.setToken(res.data['data']['token']);
      await PrefHelpers.setUserId(res.data['data']['info']['_id']);

      // چک کردن نال بودن مقادیر قبل از ذخیره
      if (res.data['data']['info']['default_sub'] != null) {
        await PrefHelpers.setSubCode(res.data['data']['info']['default_sub']);
      }
      if (res.data['data']['info']['wallet'] != null) {
        await PrefHelpers.setWalletId(res.data['data']['info']['wallet']);
      }
    }
    try {} catch (e) {
      debugPrint("Error getUserInfo: $e");
    }
    // نکته: اینجا دیگر getActiveSubAccount را صدا نمی‌زنیم
  }

  String checkDate(DateTime d, int periodDay, bool isFree) {
    final now = DateTime.now();
    final difference = d.difference(now);
    if (difference.isNegative) return "منقضی شده";
    final days = difference.inDays;
    return "$days روز";
  }

  void accountRenewal(subCode, BuildContext context) async {
    // Internet Check Guard
    await context.read<VpnProvider>().disconnect();
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    final res = await api.accountRenewal(subCode);
    if (res.statusCode == 200) {
      await launchUrl(
        Uri.parse(res.data['data']['url']),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ViewHelper.showErrorDialog(
          "مشکلی بوجود آماده است مجددا تلاش کنید", context);
    }
  }

  Future<void> getAccountInfo() async {
    // accountInfoLoading = false;
    // notifyListeners();
    try {
      final res = await api.getAccountInfo(await PrefHelpers.getUserId());
      if (res.statusCode == 200) {
        if (res.data['data']['sub'] != null) {
          accountInfoModel = AccountInfoModel.fromJson(res.data['data']);
          await AccountInfoModel.saveToDB(accountInfoModel!.sub);
        } else {
          accountInfoModel?.sub = [];
        }
      }
    } catch (e) {
      debugPrint("Error getAccountInfo: $e");
    }
    accountInfoLoading = true;
    notifyListeners();
  }

  void removeDevice(String subCode, BuildContext context) async {
    // Internet Check Guard
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    ViewHelper.showLoading(context);
    final res = await api.removeDevice(subCode);
    Navigator.of(context, rootNavigator: true).pop();
    if (res.statusCode == 200) {
      ViewHelper.showSuccessDialog(
          "با موفقیت از دستگاه های دیگر حذف شد", context);
      getAccountInfo();
    } else {
      ViewHelper.showErrorDialog(
          "مشکلی بوجود آمده است مجدد تلاش کنید", context);
    }
  }

  // ===================================================================
  // --- بخش PaymentProvider ---
  // ===================================================================

  Future<void> getAllSubPeriod() async {
    // paymentPeriodsLoading = false;
    // notifyListeners();
    try {
      final res = await api.getAllSubPeriod();
      if (res.statusCode == 200) {
        periodList = p.PeriodModel.fromJson(res.data['data']);
        periodList?.period.removeWhere(
              (element) => element.isFree == true,
        );
        periodList?.period.removeWhere(
              (element) => element.visible == false,
        );
        await p.PeriodModel.saveToDB(periodList!.period);

        _extractDurations(); // <--- فراخوانی متد استخراج دسته‌ها
      }
    } catch (e) {
      debugPrint("Error getAllSubPeriod: $e");
    }

    paymentPeriodsLoading = true;
    notifyListeners();
  }

  void _extractDurations() {
    if (periodList == null) return;

    Set<String> durationSet = {};
    for (var item in periodList!.period) {
      // فرض بر این است که فرمت "1-نام پلن" است
      if (item.periodName.contains("-")) {
        String prefix = item.periodName.split("-")[0].trim();
        durationSet.add(prefix);
      } else {
        // اگر خط فاصله نداشت، میره تو دسته سایر
        durationSet.add("جشنواره");
      }
    }

    // تبدیل به لیست و مرتب‌سازی عددی
    availableDurations = durationSet.toList();
    availableDurations.sort((a, b) {
      if (int.tryParse(a) != null && int.tryParse(b) != null) {
        return int.parse(a).compareTo(int.parse(b));
      }
      return a.compareTo(b);
    });

    // انتخاب پیش‌فرض اولین تب
    if (availableDurations.isNotEmpty) {
      selectedDurationTab = availableDurations.first;
    }
  }

  void changeDurationTab(String tab) {
    selectedDurationTab = tab;
    notifyListeners();
  }

  // متد جدید: گرفتن لیست فیلتر شده بر اساس تب انتخاب شده
  List<p.Period> get filteredPeriods {
    if (periodList == null) return [];
    if (selectedDurationTab.isEmpty) return periodList!.period;

    return periodList!.period.where((element) {
      if (selectedDurationTab == "جشنواره") {
        return !element.periodName.contains("-");
      }
      return element.periodName.startsWith("$selectedDurationTab-");
    }).toList();
  }

  void gotoPayment(id, BuildContext context) async {
    // Internet Check Guard
    await context.read<VpnProvider>().disconnect();
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    final res = await api.createAccountSub(id, await PrefHelpers.getUserId(),
        phoneNumber.text, note.text, forOthers, offerCode.text);
    if (res.statusCode == 200) {
      Navigator.pop(context);
      await launchUrl(
        Uri.parse(res.data['data']['url']),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ViewHelper.showErrorDialog(
          "مشکلی بوجود آماده است مجددا تلاش کنید", context);
    }
  }

  void payWithWallet(String id, BuildContext context) async {
    // Internet Check Guard
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    final res = await api.createAccountWithWallet(
      id,
      await PrefHelpers.getUserId(),
      phoneNumber.text,
      note.text,
      forOthers,
      offerCode.text,
    );
    if (res.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      checkSubNumber(res.data['data']['sub']['sub_code'], false, context);
      getWallet();
    } else {
      ViewHelper.showErrorDialog("موجودی کیف پول شما کافی نیست", context);
    }
  }

  void payRenewalWithWallet(
      String subCodeValue, String periodId, BuildContext context) async {
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    // فرض بر این است که شما متد api.accountRenewalWithWallet را هم در فایل api_service خود آپدیت کرده‌اید
    // که پارامتر periodId را هم بگیرد. اگر نکردید، حتما آنجا هم اضافه کنید.
    final res = await api.accountRenewalWithWallet(
      subCodeValue,
      offerCode.text,
      periodId,
    );

    if (res.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      getActiveSubAccount();
      getWallet();
      ViewHelper.showSuccessDialog("باموفقیت تمدید شد", context);
    } else {
      ViewHelper.showErrorDialog("موجودی کیف پول شما کافی نیست", context);
    }
  }

  Future<void> getPayInfo() async {
    try {
      final res = await api.getPayInfo();
      if (res.statusCode == 200) {
        cardNumber = res.data['data'][0]['card_number'] ?? "";
        cardName = res.data['data'][0]['card_Name'] ?? "";
        cardNumber2 = res.data['data'][0]['card_number2'] ?? "";
        cardName2 = res.data['data'][0]['card_Name2'] ?? "";
        cardNumber3 = res.data['data'][0]['card_number3'] ?? "";
        cardName3 = res.data['data'][0]['card_Name3'] ?? "";
        cardNumber4 = res.data['data'][0]['card_number4'] ?? "";
        cardName4 = res.data['data'][0]['card_Name4'] ?? "";
        isActivePayment = res.data['data'][0]['is_payment_active'];
        is_cart_active = res.data['data'][0]['is_cart_active'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error getPayInfo: $e");
    }
  }

  void createSubscriptionReceipt(
      context, String path, periodId, phone_number) async {
    // Internet Check Guard
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    ViewHelper.showLoading(context);
    var headers = {'Authorization': 'bearer ${await PrefHelpers.getToken()}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiHelper.baseUrl}accounts/createPaymentReceipt/"),
    );
    request.fields.addAll({
      "periodId": periodId,
      "phone_number": phone_number,
      "user_id": await PrefHelpers.getUserId(),
      "for_others": forOthers.toString(),
      "note": note.text,
    });
    request.files.add(await http.MultipartFile.fromPath('file', path));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 201) {
        Navigator.pop(context);
        path = "";
        showCooperationDialog6(navigatorKey.currentContext ?? context);
      } else {
        ViewHelper.showErrorDialog(
            "مشکلی بوجود آمده است مجدد تلاش کنید!", context);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ViewHelper.showErrorDialog("خطای شبکه: $e", context);
    }
  }

  void reNewalPaymentReceipt(
      context, String path, subCode, String periodId) async {
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    ViewHelper.showLoading(context);
    var headers = {'Authorization': 'bearer ${await PrefHelpers.getToken()}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiHelper.baseUrl}accounts/reNewalPaymentReceipt/"),
    );

    request.fields.addAll({
      "subCode": subCode,
      "periodId": periodId,
      // <--- ارسال شناسه پلن جدید به فیلدها
    });

    request.files.add(await http.MultipartFile.fromPath('file', path));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 201) {
        Navigator.pop(context);
        path = "";
        ViewHelper.showSuccessDialog(
            "با موفقیت ثبت شد. در انتظار بررسی میباشد", context);
      } else {
        ViewHelper.showErrorDialog(
            "مشکلی بوجود آمده است مجدد تلاش کنید!", context);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ViewHelper.showErrorDialog("خطای شبکه: $e", context);
    }
  }

  Future<void> checkOfferCode(String code, BuildContext context) async {
    // 1. گارد اینترنت
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      if (!context.mounted) return; // چک کردن اینکه صفحه هنوز باز است
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    // نمایش لودینگ
    ViewHelper.showLoading(context);

    // 2. درخواست به سرور
    final res = await api.checkOfferCode(code);

    // 3. بستن لودینگ (با چک کردن mounted)
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    // 4. بررسی نتیجه
    if (res.statusCode == 200) {
      final data = res.data['data'];

      // طبق کد بک‌اند، اگر status ترو باشد یعنی همه چیز درست است
      if (data['status'] == true) {
        isConfirmOffer = true;
        isPercent = data['is_percent'];
        percent = data['percent'];

        ViewHelper.showSuccessDialog("کد تخفیف با موفقیت اعمال شد", context);
      } else {
        // اگر status فالس بود (چه تاریخ گذشته، چه غیرفعال)
        _resetOfferData();

        // اگر بک‌اند مسیج می‌فرستد آن را نمایش بده، وگرنه متن پیش‌فرض
        String errorMsg = data['message'] ?? "کد تخفیف نامعتبر است";
        ViewHelper.showErrorDialog(errorMsg, context);
      }

      notifyListeners();
    } else {
      // خطای سرور
      _resetOfferData();
      notifyListeners();
      ViewHelper.showErrorDialog(
          "خطا در بررسی کد تخفیف (Status: ${res.statusCode})", context);
    }
  }

// یک متد کمکی برای ریست کردن دیتا
  void _resetOfferData() {
    isConfirmOffer = false;
    percent = "0"; // یا مقدار پیش‌فرض شما
    isPercent = false;
  }

  void changeSelectedItem(p.Period item) {
    periodList?.period.forEach((element) {
      element.isSelected = false;
    });
    item.isSelected = true;
    periodId = item.id;
    periodPrice = item.periodPrice;
    notifyListeners();
  }

  // ===================================================================
  // --- بخش WalletProvider ---
  // ===================================================================

  Future<void> getWallet() async {
    // walletLoading = false;
    // notifyListeners();
    try {
      final res = await api.getWallet(await PrefHelpers.getWalletId());
      if (res.statusCode == 200) {
        walletModel = WalletModel.fromJson(res.data['data']);
      }
    } catch (e) {
      debugPrint("Error getWallet: $e");
    }
    walletLoading = true;
    notifyListeners();
  }

  void chargeWallet(BuildContext context) async {
    // Internet Check Guard
    await context.read<VpnProvider>().disconnect();
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    final res = await api.chargeWallet(
        true, walletPriceController.text, walletModel!.id);
    if (res.statusCode == 200) {
      Navigator.pop(context);
      await launchUrl(
        Uri.parse(res.data['data']['url']),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ViewHelper.showErrorDialog(
          "مشکلی بوجود آمده است مجددا تلاش کنید", context);
    }
  }

  void createWalletChargeReceipt(BuildContext context, String path) async {
    // Internet Check Guard
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    ViewHelper.showLoading(context);
    var headers = {'Authorization': 'bearer ${await PrefHelpers.getToken()}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiHelper.baseUrl}wallets/chargeWalletReceipt/"),
    );
    request.fields.addAll({
      "amount": walletPriceController.text,
      "walletId": walletModel!.id,
    });
    request.files.add(await http.MultipartFile.fromPath('file', path));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      Navigator.of(context, rootNavigator: true).pop();
      if (response.statusCode == 201) {
        Navigator.pop(context);
        path = "";
        ViewHelper.showSuccessDialog(
            "با موفقیت ثبت شد. در انتظار بررسی میباشد", context);
      } else {
        ViewHelper.showErrorDialog(
            "مشکلی بوجود آمده است مجدد تلاش کنید!", context);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ViewHelper.showErrorDialog("خطای شبکه: $e", context);
    }
  }

  void selectPrice(PriceModel priceModel) {
    listOfPrice.forEach((element) {
      element.selected = false;
    });
    priceModel.selected = true;
    walletPriceController.text = priceModel.price.toString();
    notifyListeners();
  }

  // ===================================================================
  // --- بخش FcmController ---
  // ===================================================================

  // Future<void> _initFCM() async {
  //   await _fcm.requestPermission(
  //     alert: false,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: false,
  //   );
  // }

  // ===================================================================
  // --- بخش DeepLink (ادغام شده) ---
  // ===================================================================

  void _initDeepLinks(BuildContext context) {
    // 3. اگر لیسنر قبلی وجود دارد، آن را کنسل کن تا دوتا نشود
    _linkSubscription?.cancel();

    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) {
        if (uri.toString() == _lastProcessedLink) return;

        _lastProcessedLink = uri.toString();

        Future.delayed(const Duration(seconds: 3), () {
          _lastProcessedLink = null;
        });

        debugPrint("DeepLink Received: $uri");
        final status = uri.queryParameters['status'];

        if (status == "500") {
          // هندل کردن خطا
        } else if (status == "100") {
          // رفرش همه‌چیز
          getAllSubPeriod();
          getPayInfo();
          getWallet();
          getAccountInfo();

          if (uri.queryParameters['for_others'] == "true") {
            // لاژیک مربوطه
          } else if (uri.path.contains("wallets")) {
            getWallet();
            _showDialogSafe(context, "کیف پول با موفقیت شارژ شد");

          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final subCodeParam = uri.queryParameters['subCode'];
              if (subCodeParam != null && subCodeParam.isNotEmpty) {
                checkSubNumber(subCodeParam, false, context);
              } else {
                _getUserInfo();
              }
            });
          }
        } else {
          _showDialogSafe(context, "پرداخت ناموفق بود یا لغو شد");
        }
      },
      onError: (err) {
        debugPrint("DeepLink Error: $err");
      },
    );
  }
  void disposed() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _showDialogSafe(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ViewHelper.showSuccessDialog(message, context);
      } catch(e) {
        print("Context error: $e");
      }
    });
  }


  void disconnectOthers(String subCode, BuildContext context) async {
    // بررسی اینترنت
    if (await CheckInternetConnection.checkInternetConnection() == false) {
      ViewHelper.showErrorDialog("نیاز به اتصال به اینترنت هستش", context);
      return;
    }

    ViewHelper.showLoading(context);

    try {
      // فرض بر این است که متد api.disconnectOthers را ساخته‌اید
      // اگر نساختید، پایین‌تر توضیح داده شده
      final res = await api.disconnectOtherUsers(
          subCode, await PrefHelpers.getUserId());

      Navigator.of(context, rootNavigator: true).pop(); // بستن لودینگ

      if (res.statusCode == 200) {
        // دریافت کد اشتراک جدید از پاسخ سرور
        String newSubCode = res.data['data']['new_sub_code'].toString();

        // ذخیره کد جدید به عنوان کد پیش‌فرض در موبایل کاربر
        await PrefHelpers.setSubCode(newSubCode);

        // رفرش کردن اطلاعات اکانت برای نمایش کد جدید
        initializeApp(context);
        ViewHelper.showSuccessDialog(
            "اتصال سایر کاربران با موفقیت قطع شد", context);
      } else {
        ViewHelper.showErrorDialog(
            res.data['message'] ?? "خطایی رخ داد", context);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // بستن لودینگ
      ViewHelper.showErrorDialog("خطای شبکه: $e", context);
    }
  }
}

// مدل کمکی برای لیست قیمت‌های کیف پول
class PriceModel {
  int price;
  bool selected = false;
  PriceModel({required this.price, required this.selected});
}
