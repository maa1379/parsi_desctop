import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:parsi/core/nav_helper.dart';
import 'package:parsi/provider/user_provider.dart';
import 'package:provider/provider.dart';

import '../core/image_picker_helper.dart';
import '../core/view_helper.dart';
import '../generated/assets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Size size;
  bool isOnlinePayment = true;

  // لیست مبالغ پیش‌فرض
  final List<int> _presetAmounts = [
    100000,
    200000,
    300000,
    400000,
    500000,
    1000000
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<UserProvider>(context, listen: false).getWallet();
    });
  }

  // تابعی برای برداشتن ویرگول‌ها و تبدیل به عدد خالص برای مقایسه
  String _getRawAmount(String formattedString) {
    return formattedString.replaceAll(',', '');
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    final userProvider = context.watch<UserProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF18191D),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.imagesAnims),
                    opacity: 0.04,
                    alignment: Alignment.bottomCenter,
                    scale: 7,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const Gap(20),
                    // ... (هدر و موجودی بدون تغییر) ...
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => context.pop(),
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
                            "شارژ کیف پول",
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

                    const Gap(40),

                    // --- موجودی کیف پول ---
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                          color: const Color(0xFF202125),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: const Color(0xFFEF5350), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 15,
                            )
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "موجودی کیف پول :",
                            style: TextStyle(
                                color: Color(0xFFEF5350),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                "${(userProvider.walletModel?.balance ?? "0").toPrice()} تومان",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.wallet,
                                  color: Color(0xFFEF5350)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const Gap(40),

                    // --- لیبل مبلغ مورد نیاز ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle,
                              color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "مبلغ مورد نیاز برای شارژ ( تومان )",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const Gap(15),

                    // --- گرید دکمه‌های مبلغ ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: _presetAmounts.map((amount) {
                          // چک می‌کنیم آیا مبلغ دکمه با مبلغ داخل تکست‌فیلد برابر است؟
                          // از تابع کمکی استفاده می‌کنیم تا ویرگول‌ها حذف شوند
                          final isSelected = _getRawAmount(
                              userProvider.walletPriceController.text) ==
                              amount.toString();

                          return GestureDetector(
                            onTap: () {
                              // مقدار را فرمت شده (با ویرگول) در کنترلر قرار می‌دهیم
                              final formatted = NumberFormat("#,###").format(amount);
                              userProvider.walletPriceController.text = formatted;
                              setState(() {});
                            },
                            child: Container(
                              width: (size.width - 80) / 3,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.2) // پس‌زمینه کم‌رنگ برای حالت انتخاب
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  // تغییر رنگ بوردر در صورت انتخاب
                                    color: isSelected
                                        ? Colors.blueAccent
                                        : const Color(0xFF1565C0),
                                    width: isSelected ? 2 : 1.5), // ضخامت بیشتر برای حالت انتخاب
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                amount.toPrice(),
                                style: TextStyle(
                                  color: isSelected ? Colors.blueAccent : Colors.white,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const Gap(20),
                    const Text("یا",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    const Gap(20),

                    // --- ورودی مبلغ دلخواه ---
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: userProvider.walletPriceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        // اضافه کردن فرمتر برای سه رقم سه رقم شدن
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter()
                        ],
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: "ورود مبلغ دلخواه (تومان)",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (val) {
                          setState(() {}); // برای آپدیت وضعیت دکمه‌های بالا
                        },
                      ),
                    ),

                    // ... (بقیه کدها: روش پرداخت و دکمه پرداخت بدون تغییر عمده) ...
                    const Gap(40),
                    // ... (ادامه کدها دقیقاً مشابه قبل) ...
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle,
                              color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "روش پرداخت :",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const Gap(15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Visibility(
                            visible: userProvider.is_cart_active,
                            child: Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => isOnlinePayment = false),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: !isOnlinePayment
                                        ? const Color(0xFF1565C0)
                                        .withOpacity(0.3)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: !isOnlinePayment
                                          ? Colors.blueAccent
                                          : const Color(0xFF1565C0),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text("کارت به کارت",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                          const Gap(15),
                          Visibility(
                            visible: userProvider.isActivePayment,
                            child: Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => isOnlinePayment = true),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isOnlinePayment
                                        ? const Color(0xFF1565C0)
                                        .withOpacity(0.3)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isOnlinePayment
                                          ? Colors.blueAccent
                                          : const Color(0xFF1565C0),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text("درگاه پرداخت",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(40),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          // قبل از ارسال، باید ویرگول‌ها را حذف کنیم چون سرور معمولاً عدد خالص می‌خواهد
                          // اما userProvider.walletPriceController حاوی متن فرمت شده است.
                          // بهتر است در متد chargeWallet این کار انجام شود یا اینجا تمیز شود:

                          String rawPrice = userProvider.walletPriceController.text.replaceAll(',', '');
                          if (rawPrice.isEmpty) {
                            ViewHelper.showErrorDialog(
                                "لطفا مبلغ را وارد کنید", context);
                            return;
                          }

                          // نکته: اگر متد chargeWallet مستقیماً از text کنترلر استفاده می‌کند،
                          // باید در آن متد هم replaceAll(',', '') اضافه کنید.
                          // یا اینکه اینجا مقدار کنترلر را موقتاً تغییر دهید (که UI را بهم می‌زند)
                          // راه حل بهتر: در متد chargeWallet در UserProvider تغییر دهید.

                          if (isOnlinePayment) {
                            if (!userProvider.isActivePayment) {
                              ViewHelper.showErrorDialog(
                                  "درگاه پرداخت موقتا غیرفعال است", context);
                            } else {
                              userProvider.chargeWallet(context);
                            }
                          } else {
                            _showCardToCardModal(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 5,
                          shadowColor: Colors.redAccent.withOpacity(0.4),
                        ),
                        child: const Text(
                          "پرداخت",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const Gap(30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // متدهای مودال و بقیه ویجت‌ها دقیقاً مثل قبل هستند...
  // فقط برای جلوگیری از طولانی شدن اینجا تکرار نمی‌کنم،
  // شما متد _showCardToCardModal و _buildCardRow خودتان را نگه دارید.
  void _showCardToCardModal(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18191D),
      context: context,
      builder: (context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: size.height * 0.8,
            decoration: const BoxDecoration(
                color: Color(0xFF18191D),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.credit_card, size: 50, color: Colors.white),
                const Gap(20),
                Text(
                  // اینجا هم باید برای نمایش، از حالت فرمت شده استفاده کنیم
                  // اگر کنترلر فرمت شده باشد، می‌توانیم مستقیم نمایش دهیم
                  // یا از toPrice استفاده کنیم
                  "مبلغ واریزی: ${userProvider.walletPriceController.text} تومان",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                // ... بقیه کدهای مودال بدون تغییر ...
                const Gap(10),
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
                          userProvider.cardNumber, userProvider.cardName),
                      Visibility(
                        visible: userProvider.cardNumber2 != "",
                        child: _buildCardRow(
                            userProvider.cardNumber2, userProvider.cardName2),
                      ),
                      Visibility(
                        visible: userProvider.cardNumber3 != "",
                        child: _buildCardRow(
                            userProvider.cardNumber3, userProvider.cardName3),
                      ),
                      Visibility(
                        visible: userProvider.cardNumber4 != "",
                        child: _buildCardRow(
                            userProvider.cardNumber4, userProvider.cardName4),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Text(
                  "به نام: ${userProvider.cardName}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const Gap(30),
                ElevatedButton.icon(
                  onPressed: () async {
                    ImagePickerHelper picker = ImagePickerHelper();
                    String path = await picker.select();
                    if (path.isNotEmpty) {
                      userProvider.createWalletChargeReceipt(context, path);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("آپلود فیش واریزی"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      fixedSize: Size(size.width * 0.8, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardRow(String cardNumber, String cardName) {
    String formattedCardNumber = cardNumber.replaceAllMapped(
        RegExp(r".{4}"), (match) => "${match.group(0)} ");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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

// --- کلاس فرمتر برای سه رقم سه رقم ---
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text.replaceAll(',', ''));
    final formatter = NumberFormat("#,###");
    String newText = formatter.format(value);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}

// اکستنشن قدیمی هم همچنان باشد برای جاهایی که از آبجکت استفاده می‌کنید
extension on Object {
  String toPrice() {
    String numberString = toString();
    if (numberString == "null") return "0";
    final numberDigits = List.from(numberString.split(''));
    int index = numberDigits.length - 3;
    while (index > 0) {
      numberDigits.insert(index, ',');
      index -= 3;
    }
    return numberDigits.join();
  }
}