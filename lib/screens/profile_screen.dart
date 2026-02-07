import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:parsi/screens/main_screen.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/image_picker_helper.dart';
import '../core/view_helper.dart';
import '../models/account_info_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<UserProvider>(context, listen: false).getAccountInfo();
    });
  }

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.rTo(MainScreen());
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFF18191D), // رنگ پس‌زمینه اصلی تیره
          body: SafeArea(
            child: Column(
              children: [
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => context.rTo(MainScreen()),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF26282E),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 18, color: Colors.grey),
                        ),
                      ),
                      const Text(
                        "مدیریت اشتراک",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 45),
                      // برای وسط‌چین ماندن متن
                    ],
                  ),
                ),

                const Gap(20),

                // --- محتوای اصلی ---
                Consumer<UserProvider>(
                  builder: (context, controller, child) {
                    if (controller.firstTimeOfflineError) {
                      return const Expanded(
                        child: Center(
                          child: Text(
                            "برای بار اول به اینترنت متصل شوید.",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      );
                    }

                    if (controller.accountInfoModel == null ||
                        controller.accountInfoLoading == false) {
                      return const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (controller.accountInfoModel!.sub.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: Text(
                            "شما خریدی نداشتید!",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: controller.accountInfoModel!.sub.length,
                        itemBuilder: (context, index) {
                          return _buildSubscriptionCard(
                              controller.accountInfoModel!.sub[index], context);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Sub item, BuildContext context) {
    final userProvider = context.read<UserProvider>();

    // محاسبه ترافیک‌ها
    String totalTraffic =  (int.tryParse(item.traffic) ?? 0) >= 10000000000
        ? "نامحدود"
        : formatBytes(item.period.traffic * 1024 * 1024);

    int usedBytes = item.download != null ? int.parse(item.download) : 0;
    String usedTraffic = formatBytes(usedBytes);

    int totalBytes =
        (double.parse(item.traffic).toInt() * 1024 * 1024).toInt();

    String remainingTraffic = (int.tryParse(item.traffic) ?? 0) >= 10000000000
        ? "نامحدود"
        : formatBytes(totalBytes - usedBytes);

    String displayName = item.period.periodName;
    if (displayName.contains("-")) {
      List<String> parts = displayName.split("-");
      if (parts.length > 1) {
        displayName =
            displayName.substring(displayName.indexOf("-") + 1).trim();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF202125),
        // رنگ کارت تیره (خاکستری/سرمه‌ای خیلی تیره)
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          const Gap(15),

          // ردیف کد اشتراک (با دکمه کپی)
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: item.subCode));
              ViewHelper.showSuccessDialog("کپی شد", context);
            },
            child: _buildRowItem(
              label: "کد اشتراک سرویس:",
              valueWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.subCode,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(
                          ClipboardData(text: item.subCode));
                      ViewHelper.showSuccessDialog("کپی شد", context);
                    },
                    child: const Icon(Icons.copy,
                        color: Colors.redAccent, size: 14),
                  ),
                  const Text(" (کپی)",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
          _buildDivider(),
          _buildRowItem(
              label: "وضعیت:",
              value: item.trafficEnd || item.isExpired ? "غیرفعال" : "فعال",
              valueColor: item.trafficEnd || item.isExpired
                  ? Colors.red
                  : Colors.green),
          _buildDivider(),

          // نوع پلن

          _buildRowItem(label: "نوع پلن:", value: displayName),
          _buildDivider(),

          // مبلغ پرداخت
          _buildRowItem(
              label: "مبلغ پرداخت:",
              value: item.period.isFree
                  ? "رایگان"
                  : "${item.period.periodPrice.priceString} تومان"),
          _buildDivider(),

          // وضعیت پرداخت
          _buildRowItem(
            label: "وضعیت پرداخت:",
            value: item.isPaid ? "پرداخت شده" : "پرداخت نشده",
            valueColor: item.isPaid
                ? const Color(0xFF00C853)
                : Colors.red, // سبز یا قرمز
          ),
          _buildDivider(),

          // زمان باقی‌مانده
          _buildRowItem(
            label: "زمان باقیمانده سرویس:",
            value: userProvider.checkDate(
                item.subDay, item.subPeriodDay, item.period.isFree),
          ),
          _buildDivider(),

          // ترافیک مصرف شده
          _buildRowItem(
              label: "ترافیک مصرف شده:", value: usedTraffic, isLtr: true),
          _buildDivider(),

          // ترافیک باقیمانده
          _buildRowItem(
              label: "ترافیک باقیمانده:", value: remainingTraffic, isLtr: true),
          _buildDivider(),

          // تعداد کاربران مجاز
          _buildRowItem(
              label: "تعداد کاربران مجاز:",
              value: "${item.period.subCount}",
              isLtr: true),
          _buildDivider(),

          // تعداد کاربران آنلاین
          _buildRowItem(
              label: "تعداد کاربران آنلاین:",
              value: "${item.activeSubCount}",
              isLtr: true),
          _buildDivider(),
          _buildRowItem(
              label: "تاریخ خرید:",
              value: item.createdAt
                  .toLocal()
                  .toPersianDate(
                      showTime: true,
                      showTimeSecond: false,
                      changeDirectionShowTimw: true)
                  .toString(),
              isLtr: true),
          _buildDivider(),
          Visibility(
            visible: !item.updatedAt.toLocal().isAfter(DateTime(
                item.createdAt.year, item.createdAt.month, item.createdAt.day)),
            child: _buildRowItem(
                label: "تاریخ تمدید:",
                value: item.updatedAt
                    .toPersianDate(
                        showTime: true,
                        showTimeSecond: false,
                        changeDirectionShowTimw: true)
                    .toString(),
                isLtr: true),
          ),
          _buildDivider(),
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              String displayNote = item.note; // پیش‌فرض: نوت سرور

              // اگر دیتا از کش خوانده شده بود:
              if (snapshot.hasData) {
                final prefs = snapshot.data!;
                // کلید ذخیره سازی ترکیبی از کلمه note و کد اشتراک است تا برای هر اشتراک جدا باشد
                String? localNote = prefs.getString('note_${item.subCode}');
                if (localNote != null && localNote.isNotEmpty) {
                  displayNote = localNote;
                }
              }

              return _buildRowItem(
                label: "توضیحات:",
                // استفاده از valueWidget برای قرار دادن آیکون کنار متن
                valueWidget: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // چینش به سمت چپ (یا راست بسته به دایرکشن)
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(right: 50),
                          child: Text(
                            displayNote,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection:
                                TextDirection.rtl, // یا LTR بسته به نیاز
                          ),
                        ),
                      ),
                      const Gap(8), // دکمه ویرایش (مداد)
                      InkWell(
                        onTap: () {
                          _showEditNoteDialog(
                              context, item.subCode, displayNote);
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 14, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                isLtr: true,
              );
            },
          ),
          const Gap(25),
          Visibility(
            visible: !item.period.isFree,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // --- دکمه تمدید اشتراک (سبز) ---
                  // Expanded(
                  //   child: InkWell(
                  //     onTap: () {
                  //       showRenewalPlanSelection(context, item.subCode);
                  //     },
                  //     borderRadius: BorderRadius.circular(12),
                  //     child: Container(
                  //       padding: const EdgeInsets.symmetric(vertical: 12),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(
                  //             color: const Color(0xFF00C853), width: 1.5),
                  //         borderRadius: BorderRadius.circular(12),
                  //         color: Colors.white.withOpacity(0.05),
                  //       ),
                  //       alignment: Alignment.center,
                  //       child: const Text(
                  //         "تمدید",
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 14, // کمی کوچک‌تر برای جا شدن
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // const Gap(10), // فاصله بین دو دکمه

                  // --- دکمه قطع اتصال دیگران (قرمز) ---
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showDisconnectConfirmDialog(context, item.subCode);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.redAccent, width: 1.5), // قرمز
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.05),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "قطع اتصال دیگران",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }

  void _showEditNoteDialog(
      BuildContext context, String subCode, String currentNote) {
    TextEditingController noteController =
        TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF26282E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "ویرایش توضیحات",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "توضیحات مورد نظر خود را برای این اشتراک بنویسید:",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Gap(15),
                TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "مثلا: گوشی آیفون خودم...",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    filled: true,
                    fillColor: const Color(0xFF18191D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("انصراف", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  // ذخیره در Shared Preferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('note_$subCode', noteController.text);

                  if (context.mounted) {
                    Navigator.pop(context); // بستن دیالوگ
                    setState(() {}); // رفرش کردن صفحه برای نمایش متن جدید
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child:
                    const Text("ذخیره", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDisconnectConfirmDialog(BuildContext context, String subCode) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF26282E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("قطع اتصال دیگران",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text(
            "آیا مطمئن هستید؟ با این کار کد اشتراک شما تغییر می‌کند و تمام دستگاه‌های متصل دیگر قطع خواهند شد. شما به صورت خودکار به اشتراک جدید متصل می‌مانید.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("انصراف", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // بستن دیالوگ
                // فراخوانی متد پرووایدر
                context.read<UserProvider>().disconnectOthers(subCode, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("قطع اتصال",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem({
    required String label,
    String? value,
    Widget? valueWidget,
    Color valueColor = Colors.white,
    bool isLtr = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (valueWidget != null)
            valueWidget
          else
            Text(
              value ?? "",
              style: TextStyle(
                  color: valueColor, fontSize: 13, fontWeight: FontWeight.bold),
              textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Colors.white10, thickness: 1, height: 1);
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return "0 MB";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return "${d.toStringAsFixed(1)} ${suffixes[i]}";
  }

  void checkOutDialog(
      BuildContext context, String subCode, int price, String periodId) {
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18191D),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: size.height * .5,
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: size.width * .05),
            decoration: const BoxDecoration(
                color: Color(0xFF18191D),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: ListView(
              children: [
                const Gap(20),
                const Text("نهایی کردن تمدید",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),

                // ... (کدهای تخفیف و نمایش قیمت نهایی بدون تغییر) ...
                // فقط بخش دکمه‌ها را برای ارسال periodId اصلاح می‌کنیم:

                const Gap(30),
                const Text("نحوه پرداخت",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Gap(15),

                _buildPaymentButton("کارت به کارت", Icons.credit_card, () {
                  int finalPrice =
                      price; // اینجا اگر لاجیک تخفیف دارید اعمال کنید
                  Navigator.pop(context);
                  showCardToCardModal(context, finalPrice, subCode, periodId);
                }),

                Visibility(
                  visible: userProvider.isActivePayment,
                  child: _buildPaymentButton("پرداخت آنلاین", Icons.credit_card,
                      () {
                    int finalPrice = price;
                    Navigator.pop(context);
                    userProvider.accountRenewal(subCode, context);
                  }),
                ),

                _buildPaymentButton("پرداخت با کیف پول", Icons.wallet, () {
                  Navigator.pop(context);
                  // پاس دادن periodId به متد کیف پول
                  userProvider.payRenewalWithWallet(
                      subCode, periodId, this.context);
                }),
                const Gap(30),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- اصلاح مودال کارت به کارت ---
  void showCardToCardModal(
      BuildContext context, int price, String subCode, String periodId) {
    final userProvider = context.read<UserProvider>();
    // استایل باتم شیت
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        // متغیر لوکال برای نگه داشتن مسیر عکس
        String? selectedImagePath;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: size.height * 0.85,
              width: size.width,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: const BoxDecoration(
                  color: Color(0xFF18191D),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Column(
                children: [
                  const Gap(15), // --- هدر ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF26282E),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                size: 18, color: Colors.grey),
                          ),
                        ),
                        const Text("کارت به کارت",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  const Gap(20),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // --- 1. مبلغ و کپی ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "مبلغ پرداخت : ${price.priceString} تومان",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Gap(10),
                            _buildCopyButton("کپی مبلغ", price.toString()),
                          ],
                        ),
                        const Gap(20),

                        // --- 2. کارت بانکی (گرادینت) ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF005C97), // آبی تیره
                                Color(0xFF363795), // بنفش/آبی
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF363795).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildCardRow(userProvider.cardNumber,
                                  userProvider.cardName),
                              Visibility(
                                visible: userProvider.cardNumber2 != "",
                                child: _buildCardRow(userProvider.cardNumber2,
                                    userProvider.cardName2),
                              ),
                              Visibility(
                                visible: userProvider.cardNumber3 != "",
                                child: _buildCardRow(userProvider.cardNumber3,
                                    userProvider.cardName3),
                              ),
                              Visibility(
                                visible: userProvider.cardNumber4 != "",
                                child: _buildCardRow(userProvider.cardNumber4,
                                    userProvider.cardName4),
                              ),
                            ],
                          ),
                        ),

                        const Gap(25),

                        // --- 3. زمان انتظار ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.access_time,
                                color: Colors.white, size: 18),
                            Gap(8),
                            Text("زمان انتظار برای تأیید : ۱ تا ۱۵ دقیقه",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),

                        const Gap(25),

                        // --- 4. باکس آپلود عکس ---
                        GestureDetector(
                          onTap: () async {
                            ImagePickerHelper picker = ImagePickerHelper();
                            String path = await picker.select();
                            if (path.isNotEmpty) {
                              setState(() {
                                selectedImagePath = path;
                              });
                            }
                          },
                          child: Center(
                            child: Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFF202125),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1),
                                image: selectedImagePath != null
                                    ? DecorationImage(
                                        image:
                                            FileImage(File(selectedImagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: selectedImagePath == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.attach_file,
                                            color: Colors.white, size: 30),
                                        Gap(10),
                                        Text("انتخاب فیش واریزی",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                      ],
                                    )
                                  : Container(
                                      alignment: Alignment.topRight,
                                      padding: const EdgeInsets.all(5),
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 12,
                                        child: Icon(Icons.edit,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const Gap(25),

                        // --- 5. توضیحات متنی ---
                        const Text(
                          "لطفا پس از انجام کارت به کارت عکس فیش واریزی را ارسال کنید. پس از بررسی فیش توسط تیم پشتیبانی، موجودی کیف پول شما به مقدار مبلغ پرداختی شارژ شده و نتیجه از بخش اعلانات و پیامک به شما اعلام می شود.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey, height: 1.6, fontSize: 12),
                        ),
                        const Gap(15),
                        const Text(
                          "(اسکرین شات رسید فیش واریزی برنامه بانک یا عکس واضح و خوانا از رسید چاپی)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFEF5350), // قرمز
                              height: 1.5,
                              fontSize: 12),
                        ),

                        const Gap(30),
                      ],
                    ),
                  ),

                  // --- دکمه ارسال رسید ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedImagePath != null &&
                              selectedImagePath!.isNotEmpty) {
                            // فراخوانی متد مخصوص تمدید اشتراک
                            userProvider.reNewalPaymentReceipt(
                                context, selectedImagePath!, subCode, periodId);
                          } else {
                            ViewHelper.showErrorDialog(
                                "لطفا تصویر فیش واریزی را انتخاب کنید",
                                context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: Colors.red.withOpacity(0.4),
                        ),
                        child: const Text(
                          "ارسال رسید",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- ویجت‌های کمکی (مشابه صفحه PaymentScreen) ---

  Widget _buildCopyButton(String label, String dataToCopy) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: dataToCopy));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$label کپی شد"),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.copy, color: Colors.grey, size: 14),
            const Gap(5),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRow(String cardNumber, String cardName) {
    // فرمت کردن شماره کارت 4 رقم 4 رقم
    String formattedCardNumber = cardNumber.replaceAllMapped(
        RegExp(r".{4}"), (match) => "${match.group(0)} ");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // اطلاعات کارت
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedCardNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              const Gap(5),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cardName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: cardNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("شماره کارت کپی شد"),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red)),
                        child: Row(
                          children: const [
                            Text("کپی شماره کارت",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                            Gap(5),
                            Icon(Icons.copy, color: Colors.red, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        filled: true,
        fillColor: const Color(0xFF26282E),
      ),
    );
  }

  Widget _buildPaymentButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        tileColor: const Color(0xFF26282E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  void showRenewalPlanSelection(BuildContext context, String subCode) {
    // دریافت لیست پلن‌ها
    final provider = context.read<UserProvider>();
    provider.getAllSubPeriod();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18191D),
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Consumer<UserProvider>(
              builder: (context, paymentProvider, child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      const Gap(10),
                      const Text(
                        "انتخاب پلن تمدید",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Gap(20),

                      // --- Tab Bar (کپی شده از PaymentScreen) ---
                      if (!paymentProvider.paymentPeriodsLoading ||
                          paymentProvider.periodList == null)
                        const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()))
                      else
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount:
                                paymentProvider.availableDurations.length,
                            itemBuilder: (context, index) {
                              String duration =
                                  paymentProvider.availableDurations[index];
                              bool isSelected = duration ==
                                  paymentProvider.selectedDurationTab;

                              String label = duration;
                              if (int.tryParse(duration) != null) {
                                if ((int.tryParse(duration) ?? 0) >= 10000000000) {
                                  label = "نامحدود";
                                } else {
                                  label = "$duration ماهه";
                                }
                              }

                              return GestureDetector(
                                onTap: () {
                                  paymentProvider.changeDurationTab(duration);
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  alignment: Alignment.center,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF00C853)
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const Gap(15),

                      // --- List View (کپی شده از PaymentScreen) ---
                      Expanded(
                        child: (paymentProvider.paymentPeriodsLoading ==
                                    false ||
                                paymentProvider.periodList == null)
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                itemCount:
                                    paymentProvider.filteredPeriods.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      paymentProvider.filteredPeriods[index];
                                  return _itemBuilderPlan(context, item);
                                },
                              ),
                      ),

                      // --- دکمه ادامه ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: const Color(0xFF18191D),
                        child: ElevatedButton(
                          onPressed: () {
                            if (paymentProvider.periodList == null ||
                                paymentProvider.periodList!.period.every(
                                    (element) => element.isSelected == false)) {
                              ViewHelper.showErrorDialog(
                                  "لطفا یک پلن را انتخاب کنید", context);
                            } else {
                              // بستن شیت انتخاب پلن
                              Navigator.pop(context);
                              // باز کردن دیالوگ پرداخت با اطلاعات جدید
                              checkOutDialog(
                                  context,
                                  subCode,
                                  paymentProvider.periodPrice,
                                  paymentProvider.periodId // ارسال ID جدید
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text(
                            "ادامه و پرداخت",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ویجت آیتم لیست پلن (کپی شده و ساده شده برای این صفحه)
  Widget _itemBuilderPlan(BuildContext context, var item) {
    String formatPrice(int price) {
      return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }

    String displayName = item.periodName;
    if (displayName.contains("-")) {
      List<String> parts = displayName.split("-");
      if (parts.length > 1) {
        displayName =
            displayName.substring(displayName.indexOf("-") + 1).trim();
      }
    }

    final Color selectedColor = const Color(0xFF00C853);

    return GestureDetector(
      onTap: () {
        context.read<UserProvider>().changeSelectedItem(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
            color: const Color(0xFF202125),
            borderRadius: BorderRadius.circular(30),
            border: item.isSelected
                ? Border.all(color: selectedColor.withOpacity(0.5), width: 1)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ]),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${formatPrice(item.periodPrice)} تومان",
                style: TextStyle(
                  color: const Color(0xFFEF5350),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// اکستنشن برای فرمت قیمت
extension on int {
  String get priceString {
    final numberString = toString();
    final numberDigits = List.from(numberString.split(''));
    int index = numberDigits.length - 3;
    while (index > 0) {
      numberDigits.insert(index, ',');
      index -= 3;
    }
    return numberDigits.join();
  }
}
