import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/generated/assets.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:parsi/screens/main_screen.dart';
import 'package:provider/provider.dart';

import '../core/image_picker_helper.dart';
import '../core/view_helper.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Size size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<UserProvider>(context, listen: false).getAllSubPeriod();
      Provider.of<UserProvider>(context, listen: false).getPayInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    final paymentProvider = context.watch<UserProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.rTo(MainScreen());
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFF18191D),
          body: SafeArea(
            child: Column(
              children: [
                const Gap(20), // --- Header ---
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
                        "خرید اشتراک",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 45),
                    ],
                  ),
                ),

                const Gap(30),

                // --- Features ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      _buildFeatureItem("ضمانت بازگشت وجه در صورت نارضایتی"),
                      _buildFeatureItem("دسترسی به سرورهای تانل شده و ضد فیلتر"),
                      _buildFeatureItem(
                          "مناسب برای تمام اپراتور ها و سیستم عامل ها"),
                      _buildFeatureItem(
                          "دسترسی به 10+  لوکیشن قدرتمند از دیتاسنترهای مختلف"),
                    ],
                  ),
                ),

                const Gap(20),

                // --- Custom Tab Bar ---
                if (!paymentProvider.paymentPeriodsLoading ||
                    paymentProvider.periodList == null)
                  const SizedBox()
                else
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: paymentProvider.availableDurations.length,
                      itemBuilder: (context, index) {
                        String duration =
                            paymentProvider.availableDurations[index];
                        bool isSelected =
                            duration == paymentProvider.selectedDurationTab;

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
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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

                const Gap(5), Image.asset(Assets.imagesImg), const Gap(5),

                // --- Plans List ---
                Expanded(
                  child: paymentProvider.firstTimeOfflineError
                      ? const Center(
                          child: Text("لطفا به اینترنت متصل شوید",
                              style: TextStyle(color: Colors.red)))
                      : (paymentProvider.paymentPeriodsLoading == false ||
                              paymentProvider.periodList == null)
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              itemCount: paymentProvider.filteredPeriods.length,
                              itemBuilder: (context, index) {
                                final item =
                                    paymentProvider.filteredPeriods[index];
                                return itemBuilder(context, item);
                              },
                            ),
                ),

                // --- Bottom Button ---
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: const Color(0xFF18191D),
                  child: ElevatedButton(
                    onPressed: () {
                      paymentProvider.isConfirmOffer = false;
                      if (paymentProvider.periodList == null ||
                          paymentProvider.periodList!.period
                              .every((element) => element.isSelected == false)) {
                        ViewHelper.showErrorDialog(
                            "لطفا یک پلن را انتخاب کنید", context);
                      } else {
                        // پیدا کردن آیتم انتخاب شده برای نمایش در دیالوگ
                        var selectedItem = paymentProvider.periodList!.period
                            .firstWhere((element) => element.isSelected);

                        checkOutDialog(
                          context, paymentProvider.periodId,
                          paymentProvider.periodPrice,
                          selectedItem.periodName, // پاس دادن نام پلن
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 5,
                      shadowColor: Colors.redAccent.withOpacity(0.4),
                    ),
                    child: const Text(
                      "خرید اشتراک",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 18),
        ],
      ),
    );
  }

  Widget itemBuilder(BuildContext context, var item) {
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
                offset: const Offset(0, 5),
              )
            ]),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${formatPrice(item.periodPrice)} تومان",
                style: const TextStyle(
                  color: Color(0xFFEF5350),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- متد چک‌اوت بازطراحی شده طبق عکس ---
  void checkOutDialog(
      BuildContext context, String periodId, int price, String periodName) {
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // شفاف برای دیزاین بهتر
      builder: (context) {
        // برای مدیریت استیت داخلی باتن‌ها (مثل انتخاب روش پرداخت)
        int selectedPaymentMethod = 0; // 0: Online, 1: Card, 2: Wallet

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // محاسبه قیمت نهایی
            int finalPrice = price;
            if (userProvider.isConfirmOffer) {
              if (userProvider.isPercent) {
                finalPrice = price -
                    (price * (int.parse(userProvider.percent) / 100)).toInt();
              } else {
                finalPrice = price - int.parse(userProvider.percent);
              }
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: size.height * 0.9,
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
                    const Gap(15),
                    // دکمه بستن
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF26282E),
                            ),
                            child: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const Text("پرداخت",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const Gap(20),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // --- 1. اشتراک انتخاب شده ---
                          Row(
                            children: const [
                              Icon(Icons.check_circle_outline,
                                  color: Color(0xFF00C853), size: 16),
                              Gap(5),
                              Text("اشتراک انتخاب شده :",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          const Gap(10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFF00C853)),
                              color: const Color(0xFF18191D),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _cleanName(periodName),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                    width: 1, height: 20, color: Colors.grey),
                                Gap(10),
                                Text(
                                    "${price.priceString} تومان", // قیمت سمت چپ قرمز
                                    style: const TextStyle(
                                        color: Color(0xFFEF5350),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Gap(25),

                          // --- 2. بخش فعالسازی (چک‌باکس‌ها) ---
                          // الف) فعالسازی در این دستگاه
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                userProvider.forOthers = false;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  !userProvider.forOthers
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: !userProvider.forOthers
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey,
                                ),
                                const Gap(8),
                                const Text("فعالسازی اتوماتیک در این دستگاه",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ],
                            ),
                          ),
                          if (!userProvider.forOthers) ...[
                            const Gap(10),
                            _buildTextField(userProvider.phoneNumber,
                                "وارد کردن شماره موبایل",
                                isNumber: true),
                          ],

                          const Gap(10),
                          // متن توضیحات (آیکون اطلاعات)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xFFEF5350), size: 16),
                              Gap(5),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                    children: [
                                      TextSpan(
                                        text: "شماره موبایل، جهت ارسال اطلاعات خرید و یاداوری زمان انقضا می باشد.\n",
                                      ),
                                      TextSpan(
                                        text: "(وارد کردن شماره موبایل الزامی نمی باشد)",
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(20),

                          // ب) خرید برای شخص دیگر
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                userProvider.forOthers = true;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  userProvider.forOthers
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: userProvider.forOthers
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey,
                                ),
                                const Gap(8),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * .7,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      const Text("عدم فعالسازی اتوماتیک در این دستگاه",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 14)),
                                      const Text("با انتخاب این گزینه، اشتراک خریداری شده بصورت اتوماتیک در این دستگاه فعال نمی شود و می توان آن را در دستگاه دیگر استفاده کرد.",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          if (userProvider.forOthers) ...[
                            const Gap(10),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildTextField(
                                        userProvider.note, "یادداشت")),
                                const Gap(10),
                                Expanded(
                                    child: _buildTextField(
                                        userProvider.phoneNumber,
                                        "وارد کردن شماره موبایل",
                                        isNumber: true)),
                              ],
                            ),
                          ],
                          const Gap(25),

                          // --- 3. کدهای تخفیف (طبق عکس دو فیلد، اما فقط از کد تخفیف موجود استفاده می‌کنیم) ---
                          const Text("کد تخفیف دارید؟",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          const Gap(8),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: TextField(
                                    controller: userProvider.offerCode,
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFF26282E),
                                      hintText: "کد تخفیف",
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(10),
                              SizedBox(
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                   await userProvider.checkOfferCode(
                                        userProvider.offerCode.text, context);
                                    // بعد از چک، باید UI رفرش شه
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            color: Color(0xff005796),
                                            width: 1)),
                                  ),
                                  child: const Text("ثبت",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),

                          const Gap(25),

                          // --- 4. روش پرداخت (سلکتور ۳ تایی) ---
                          Row(
                            children: const [
                              Icon(Icons.check_circle_outline,
                                  color: Color(0xFF00C853), size: 16),
                              Gap(5),
                              Text("روش پرداخت :",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          const Gap(10),
                          Row(
                            children: [
                              _buildPaymentSelectOption(
                                "پرداخت از کیف پول",
                                2,
                                selectedPaymentMethod,
                                (val) =>
                                    setState(() => selectedPaymentMethod = val),
                              ),
                              const Gap(5),
                              Visibility(
                                visible: userProvider.is_cart_active,
                                child: _buildPaymentSelectOption(
                                  "کارت به کارت",
                                  1,
                                  selectedPaymentMethod,
                                  (val) =>
                                      setState(() => selectedPaymentMethod = val),
                                ),
                              ),
                              const Gap(5),
                              Visibility(
                                visible: userProvider.isActivePayment,
                                child: _buildPaymentSelectOption(
                                  "پرداخت آنلاین",
                                  0,
                                  selectedPaymentMethod,
                                  (val) =>
                                      setState(() => selectedPaymentMethod = val),
                                ),
                              ),
                            ],
                          ),

                          const Gap(20),

                          // --- 5. سامری قیمت و دکمه پرداخت ---
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF26282E),
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                if (userProvider.isConfirmOffer)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("تخفیف",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        Text(
                                            "${(price - finalPrice).priceString}-",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("مبلغ پرداخت نهایی:",
                                        style: TextStyle(color: Colors.white)),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (price != finalPrice)
                                          Text("${price.priceString} تومان",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 12)),
                                        Text("${finalPrice.priceString} تومان",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Gap(20),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedPaymentMethod == 0) {
                                  // آنلاین
                                  if (!userProvider.isActivePayment) {
                                    ViewHelper.showErrorDialog(
                                        "درگاه غیرفعال است", context);
                                  } else {
                                    userProvider.gotoPayment(periodId, context);
                                  }
                                } else if (selectedPaymentMethod == 1) {
                                  // کارت به کارت
                                  Navigator.pop(context);
                                  showCardToCardModal(
                                      context, finalPrice, periodId);
                                } else if (selectedPaymentMethod == 2) {
                                  // کیف پول
                                  Navigator.pop(context);
                                  userProvider.payWithWallet(
                                      periodId, this.context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                side: const BorderSide(
                                    color: Color(0xFF00C853), width: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("پرداخت",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const Gap(30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // آیتم های انتخابی روش پرداخت
  Widget _buildPaymentSelectOption(
      String title, int index, int groupValue, Function(int) onTap) {
    bool isSelected = index == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF18191D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected ? const Color(0xFFD32F2F) : Color(0xff005796),
                width: isSelected ? 1.5 : 1),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black, fontSize: 13),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
        ),
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

  // تمیز کردن نام پلن (حذف خط تیره اول اگر وجود دارد)
  String _cleanName(String name) {
    if (name.contains("-")) {
      List<String> parts = name.split("-");
      if (parts.length > 1) {
        return name.substring(name.indexOf("-") + 1).trim();
      }
    }
    return name;
  }

// --- متد کارت به کارت بازطراحی شده طبق تصویر ---
  void showCardToCardModal(BuildContext context, int price, String periodId) {
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        // متغیر برای نگهداری مسیر عکس انتخاب شده درون دیالوگ
        String? selectedImagePath;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: size.height * 0.85,
              // ارتفاع بیشتر مثل طرح
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
                  const Gap(15), // --- Header ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // دکمه بازگشت (سمت چپ)
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
                        // برای بالانس شدن هدر
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
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              color: Color(0xFFEF5350), // قرمز
                              height: 1.5,
                              fontSize: 12),
                        ),

                        const Gap(30),
                      ],
                    ),
                  ),

                  // --- دکمه ارسال رسید (چسبیده به پایین) ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedImagePath != null &&
                              selectedImagePath!.isNotEmpty) {
                            userProvider.createSubscriptionReceipt(
                                context, selectedImagePath!, periodId,userProvider.phoneNumber.text);
                          } else {
                            ViewHelper.showErrorDialog(
                                "لطفا تصویر فیش واریزی را انتخاب کنید",
                                context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          // قرمز
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

  // --- ویجت‌های کمکی برای کارت به کارت ---

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
                        fontSize: 12,
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
}

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
