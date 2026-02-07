import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../core/nav_helper.dart';
import '../provider/traning_provider.dart';

class TrainingVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const TrainingVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _TrainingVideoPlayerState createState() => _TrainingVideoPlayerState();
}

class _TrainingVideoPlayerState extends State<TrainingVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant TrainingVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // اگر لینک ویدیو عوض شد، پلیر قبلی را نابود و جدید بساز
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposePlayer();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      fullScreenByDefault: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            "خطا در پخش ویدیو",
            style: TextStyle(color: Colors.white),
          ),
        );
      },
      // تنظیمات ظاهری کنترلرها
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.purple,
        handleColor: Colors.purpleAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white24,
      ),
    );

    if (mounted) setState(() {});
  }

  void _disposePlayer() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20), // گرد کردن گوشه‌های پلیر
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
  }
}


class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  @override
  void initState() {
    super.initState();
    // فراخوانی API هنگام لود صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainingProvider>(context, listen: false).fetchTrainings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrainingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF18191D),
      body: SafeArea(
        child: Column(
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
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.grey),
                      ),
                    ),
                    const Text(
                      "آموزش استفاده از اپلیکیشن",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 45), // برای وسط‌چین ماندن متن
                  ],
                ),
              ),
            ),
            Gap(20),
            // --- لیست آموزش‌ها ---
            Expanded(
              flex: 2, // فضای لیست
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Directionality(
                textDirection: TextDirection.rtl, // راست چین کردن لیست
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: provider.trainings.length,
                  itemBuilder: (context, index) {
                    final item = provider.trainings[index];
                    final isSelected = provider.currentTraining?.id == item.id;

                    return GestureDetector(
                      onTap: () {
                        provider.playTraining(item);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Text(
                          "${index + 1}- ${item.title}",
                          style: TextStyle(
                            color: isSelected ? Colors.amber : Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // --- ویدیو پلیر ---
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: provider.currentTraining == null
                    ? Center(
                  child: Text(
                    "لطفا یک آموزش را انتخاب کنید",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // عنوان ویدیوی در حال پخش
                    Text(
                      provider.currentTraining!.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: TrainingVideoPlayer(
                        videoUrl: provider.currentTraining!.videoLink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
