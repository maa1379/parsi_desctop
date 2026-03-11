import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:provider/provider.dart';

import '../core/image_picker_helper.dart';
import '../core/view_helper.dart';



class CheckoutUtils{
  static void checkOutDialog(
      BuildContext parentContext,
      String subCode,
      int price,
      String periodId,
      String periodName, // این پارامتر جدید اضافه شد
      ) {
    final userProvider = parentContext.read<UserProvider>();
    final size = MediaQuery.sizeOf(parentContext);
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // شفاف برای دیزاین بهتر
      builder: (context) {
        int selectedPaymentMethod = 0; // 0: Online, 1: Card, 2: Wallet

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // محاسبه قیمت نهایی با تخفیف
            int finalPrice = price;
            if (userProvider.isConfirmOffer) {
              if (userProvider.isPercent) {
                finalPrice = price - (price * (int.parse(userProvider.percent) / 100)).toInt();
              } else {
                finalPrice = price - int.parse(userProvider.percent);
              }
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: size.height * 0.85,
                width: size.width,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: const BoxDecoration(
                  color: Color(0xFF18191D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
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
                            child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const Text("نهایی کردن تمدید",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const Gap(20),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // --- 1. اشتراک انتخاب شده ---
                          Row(
                            children: const [
                              Icon(Icons.check_circle_outline, color: Color(0xFF00C853), size: 16),
                              Gap(5),
                              Text("اشتراک فعلی شما :", style: TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          const Gap(10),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00C853)),
                              color: const Color(0xFF18191D),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _cleanName(periodName),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(width: 1, height: 20, color: Colors.grey),
                                Gap(10),
                                Text("${price.priceString} تومان",
                                    style: const TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Gap(25),

                          // --- 2. کدهای تخفیف ---
                          const Text("کد تخفیف دارید؟", style: TextStyle(color: Colors.white, fontSize: 12)),
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
                                      hintStyle: const TextStyle(color: Colors.grey),
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
                                    await userProvider.checkOfferCode(userProvider.offerCode.text, context);
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(color: Color(0xff005796), width: 1)),
                                  ),
                                  child: const Text("ثبت", style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                          const Gap(25),

                          // --- 3. روش پرداخت ---
                          Row(
                            children: const [
                              Icon(Icons.check_circle_outline, color: Color(0xFF00C853), size: 16),
                              Gap(5),
                              Text("روش پرداخت :", style: TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          const Gap(10),
                          Row(
                            children: [
                              _buildPaymentSelectOption(
                                "پرداخت از کیف پول",
                                2,
                                selectedPaymentMethod,
                                    (val) => setState(() => selectedPaymentMethod = val),
                              ),
                              const Gap(5),
                              Visibility(
                                visible: userProvider.is_cart_active, // اگه این پراپرتی موجوده
                                child: _buildPaymentSelectOption(
                                  "کارت به کارت",
                                  1,
                                  selectedPaymentMethod,
                                      (val) => setState(() => selectedPaymentMethod = val),
                                ),
                              ),
                              const Gap(5),
                              Visibility(
                                visible: userProvider.isActivePayment,
                                child: _buildPaymentSelectOption(
                                  "پرداخت آنلاین",
                                  0,
                                  selectedPaymentMethod,
                                      (val) => setState(() => selectedPaymentMethod = val),
                                ),
                              ),
                            ],
                          ),
                          const Gap(20),

                          // --- 4. خلاصه قیمت ---
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF26282E), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                if (userProvider.isConfirmOffer)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("تخفیف", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        Text("${(price - finalPrice).priceString}-",
                                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("مبلغ پرداخت نهایی:", style: TextStyle(color: Colors.white)),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (price != finalPrice)
                                          Text("${price.priceString} تومان",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  decoration: TextDecoration.lineThrough,
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

                          // --- 5. دکمه پرداخت ---
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedPaymentMethod == 0) {
                                  if (!userProvider.isActivePayment) {
                                    ViewHelper.showErrorDialog("درگاه غیرفعال است", context);
                                  } else {
                                    // Navigator.pop(context);
                                    userProvider.accountRenewal(subCode, context);
                                  }
                                } else if (selectedPaymentMethod == 1) {
                                  // Navigator.pop(context);
                                  showCardToCardModal(context, finalPrice, subCode, periodId);
                                } else if (selectedPaymentMethod == 2) {
                                  // Navigator.pop(context);
                                  userProvider.payRenewalWithWallet(subCode, periodId, parentContext);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                side: const BorderSide(color: Color(0xFF00C853), width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("پرداخت",
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

 static String _cleanName(String name) {
    if (name.contains("-")) {
      List<String> parts = name.split("-");
      if (parts.length > 1) {
        return name.substring(name.indexOf("-") + 1).trim();
      }
    }
    return name;
  }

  static Widget _buildPaymentSelectOption(
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
                color: isSelected ? const Color(0xFFD32F2F) : const Color(0xff005796),
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


  static   void showCardToCardModal(
      BuildContext context,
      int price,
      String subCode,
      String periodId,
      ) {
    final userProvider = context.read<UserProvider>();
    final size = MediaQuery.sizeOf(context);
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
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF18191D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
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
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const Text(
                          "کارت به کارت",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(10),
                            _buildCopyButton("کپی مبلغ", (price * 10).toString(),context),
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
                              _buildCardRow(
                                userProvider.cardNumber,
                                userProvider.cardName,context
                              ),
                              Visibility(
                                visible: userProvider.cardNumber2 != "",
                                child: _buildCardRow(
                                  userProvider.cardNumber2,
                                  userProvider.cardName2,context
                                ),
                              ),
                              Visibility(
                                visible: userProvider.cardNumber3 != "",
                                child: _buildCardRow(
                                  userProvider.cardNumber3,
                                  userProvider.cardName3,context
                                ),
                              ),
                              Visibility(
                                visible: userProvider.cardNumber4 != "",
                                child: _buildCardRow(
                                  userProvider.cardNumber4,
                                  userProvider.cardName4,context
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Gap(25),

                        // --- 3. زمان انتظار ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 18,
                            ),
                            Gap(8),
                            Text(
                              "زمان انتظار برای تأیید : ۱ تا ۱۵ دقیقه",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
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
                                  width: 1,
                                ),
                                image:
                                selectedImagePath != null
                                    ? DecorationImage(
                                  image: FileImage(
                                    File(selectedImagePath!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child:
                              selectedImagePath == null
                                  ? Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.attach_file,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  Gap(10),
                                  Text(
                                    "انتخاب فیش واریزی",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                                  : Container(
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.all(5),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 12,
                                  child: Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Gap(25),

                        // --- 5. توضیحات متنی ---
                        const Text(
                          "لطفا پس از واریز پول از طریق کارت به کارت، عکس فیش واریزی خود را ارسال کنید. پس از بررسی فیش توسط تیم پشتیبانی، اشتراک شما فعال شده و از طریق اعلانات و پیامک به شما اعلام می شود.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            height: 1.6,
                            fontSize: 12,
                          ),
                        ),
                        const Gap(15),
                        const Text(
                          "(اسکرین شات رسید فیش واریزی برنامه بانک یا عکس واضح و خوانا از رسید چاپی)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFEF5350), // قرمز
                            height: 1.5,
                            fontSize: 12,
                          ),
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
                              context,
                              selectedImagePath!,
                              subCode,
                              periodId,
                            );
                          } else {
                            ViewHelper.showErrorDialog(
                              "لطفا تصویر فیش واریزی را انتخاب کنید",
                              context,
                            );
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
                            fontWeight: FontWeight.bold,
                          ),
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


  static   Widget _buildCopyButton(String label, String dataToCopy,BuildContext context) {
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
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCardRow(String cardNumber, String cardName,BuildContext context) {
    // فرمت کردن شماره کارت 4 رقم 4 رقم
    String formattedCardNumber = cardNumber.replaceAllMapped(
      RegExp(r".{4}"),
          (match) => "${match.group(0)} ",
    );

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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              "کپی شماره کارت",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
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