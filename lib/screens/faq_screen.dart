import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../core/nav_helper.dart';
import '../generated/assets.dart';
import '../provider/traning_provider.dart';
// ایمپورت فایل‌های مدل و پروایدر فراموش نشود

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // متغیری برای نگهداری ایندکس آیتمی که باز است.
  // مقدار -1 یعنی هیچ آیتمی باز نیست.
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainingProvider>(context, listen: false).fetchFAQs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrainingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // رنگ پس‌زمینه تیره
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 0),
              transform: Matrix4.translationValues(-35, 50 , 0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    Assets.imagesHuman,
                  ),
                  opacity: 0.04,
                  alignment: Alignment.bottomLeft,
                  scale: 3,
                ),
              ),
            ),
            Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Image.asset(Assets.imagesLogo2,height: 30,), // آیکون لوگوی کوچک پایین
                    Text("پارسی", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ],
                )
            ),
            Column(
              children: [
                const Gap(20),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
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
                          "سوالات متداول",
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
                ),
                Gap(20),

                // --- لیست سوالات ---
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Directionality(
                          textDirection:
                              TextDirection.rtl, // راست چین کردن کل لیست
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: provider.faqs.length,
                            itemBuilder: (context, index) {
                              final item = provider.faqs[index];
                              final isExpanded = _expandedIndex == index;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  // اگر باز بود کمی روشن‌تر شود، اگر بسته بود شفاف
                                  color: isExpanded
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // بخش سوال (قابل کلیک)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // اگر روی آیتم باز کلیک شد، بسته شود (-1)
                                          // در غیر این صورت ایندکس آیتم جاری ست شود
                                          _expandedIndex =
                                              isExpanded ? -1 : index;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${index + 1}- ${item.question}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontFamily: 'Vazir',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // بخش پاسخ (نمایش شرطی)
                                    if (isExpanded)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          // باکس خاکستری روشن‌تر برای جواب
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.answer,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            // رنگ متن کمی کدرتر
                                            fontSize: 13,
                                            height: 1.6,
                                            // فاصله بین خطوط برای خوانایی بهتر
                                            fontFamily: 'Vazir',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
