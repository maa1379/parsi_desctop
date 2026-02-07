import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:parsi/core/utils.dart'; // فرض بر این است که neuShape و neuShadow اینجا هستند

import '../core/nav_helper.dart';
import '../generated/assets.dart';
import '../provider/notification_provider.dart';
import '../models/notification_model.dart'; // برای دسترسی به NotificationItem

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late Size size;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);

    // گوش دادن به تغییر تب برای خواندن پیام‌ها
    tabController.addListener(_handleTabSelection);

    // دریافت اطلاعات به محض ورود
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndMarkRead();
    });
  }

  void _fetchAndMarkRead() async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.initData();
    // بعد از اینکه دیتا آمد، تب جاری را خوانده شده کن
    _markCurrentTabAsRead();
  }

  void _handleTabSelection() {
    // اگر تب عوض شد، لیست تب جدید را بخوان
    if (!tabController.indexIsChanging) { // وقتی انیمیشن تمام شد
      _markCurrentTabAsRead();
    }
  }

  void _markCurrentTabAsRead() {
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    // اگر دیتا هنوز لود نشده یا نال است کاری نکن
    if (provider.loading && provider.notificationModel != null) {
      if (tabController.index == 0) {
        provider.markListAsRead(provider.notificationModel!.localNotification);
      } else {
        provider.markListAsRead(provider.notificationModel!.myNotification);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF18191D),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              const Gap(20), // --- Header ---
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
                      "اعلانات",
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
              const Gap(20),
              // --- Tabs ---
              SizedBox(
                height: size.height * .06,
                width: size.width,
                child: Consumer<NotificationProvider>(
                    builder: (context, provider, child) {
                      return TabBar(
                        controller: tabController,
                        tabs: [
                          _buildTabItem(
                              "اعلانات عمومی",
                              provider.notificationModel?.localNotification ?? [],
                              provider),
                          _buildTabItem(
                              "اعلانات من",
                              provider.notificationModel?.myNotification ?? [],
                              provider),
                        ],
                      );
                    }),
              ),

              // --- Tab Views ---
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // Tab 1: Local
                    Consumer<NotificationProvider>(
                      builder: (context, controller, child) {
                        if (controller.firstTimeOfflineError) {
                          return const Center(
                              child: Text(
                                "برای دریافت اعلانات، بار اول به اینترنت متصل شوید.",
                                style: TextStyle(color: Colors.white70),
                              ));
                        }
                        if (controller.loading == false || controller.notificationModel == null) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (controller.notificationModel!.localNotification.isEmpty) {
                          return const Center(
                              child: Text("هیچ اعلان عمومی یافت نشد.",
                                  style: TextStyle(color: Colors.grey)));
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            await controller.getAllNotification();
                            _markCurrentTabAsRead();
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * .05,
                                vertical: size.height * .025),
                            itemCount: controller.notificationModel!.localNotification.length,
                            itemBuilder: (context, index) => itemBuilder(
                                context,
                                index,
                                controller.notificationModel!.localNotification[index]),
                          ),
                        );
                      },
                    ),

                    // Tab 2: My Notifications
                    Consumer<NotificationProvider>(
                        builder: (context, controller, child) {
                          if (controller.firstTimeOfflineError) {
                            // ... (Error Text)
                            return const Center(child: Text("خطای اتصال", style: TextStyle(color: Colors.white)));
                          }
                          if (controller.loading == false || controller.notificationModel == null) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (controller.notificationModel!.myNotification.isEmpty) {
                            return const Center(
                                child: Text("شما هیچ اعلان شخصی ندارید.",
                                    style: TextStyle(color: Colors.grey)));
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              await controller.getAllNotification();
                              _markCurrentTabAsRead();
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * .05,
                                  vertical: size.height * .025),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: controller.notificationModel!.myNotification.length,
                              itemBuilder: (context, index) => itemBuilder(
                                  context,
                                  index,
                                  controller.notificationModel!.myNotification[index]),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabItem(String title, List items, NotificationProvider provider) {
    int unread = provider.getUnreadCountForList(items);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        if (unread > 0) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              "$unread",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          )
        ]
      ],
    );
  }

  Widget itemBuilder(BuildContext context, int index, NotificationItem item) {
    var provider = context.watch<NotificationProvider>();
    bool isRead = provider.isRead(item.id.toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.all(15),
        constraints: BoxConstraints(minHeight: size.height * .08, minWidth: size.width),
        width: size.width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: isRead ? const Color(0xff353A40) : const Color(0xff454A50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "موضوع: ${item.title}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                if (!isRead)
                  const Icon(Icons.circle, color: Colors.red, size: 8),
              ],
            ),
            const Gap(10),
            Text(
              "متن اعلان: ${item.body}",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const Gap(10),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                item.createdAt.toString().split('.')[0], // نمایش ساده تاریخ
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            )
          ],
        ),
      ).neuShadow,
    );
  }
}