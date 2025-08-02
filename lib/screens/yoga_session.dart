import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:yoga_sessions/models/models.dart';

class YogaSessionScreen extends StatefulWidget {
  final List<Pose> poses;
  const YogaSessionScreen({super.key, required this.poses});

  @override
  State<YogaSessionScreen> createState() => _YogaSessionScreenState();
}

class _YogaSessionScreenState extends State<YogaSessionScreen> {
  int currentIndex = 0;
  int remainingTime = 0;
  Timer? timer;
  bool isPaused = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var pose in widget.poses) {
        precacheImage(AssetImage(pose.image), context);
      }
      startPose(widget.poses[currentIndex]);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void startPose(Pose pose) async {
    await _audioPlayer.stop();
    Future.microtask(() => _audioPlayer.play(AssetSource(pose.audio)));

    setState(() => remainingTime = pose.duration);

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || isPaused) return;
      if (remainingTime > 1) {
        remainingTime--;
        if (remainingTime % 1 == 0) setState(() {});
      } else {
        t.cancel();
        goToNextPose();
      }
    });
  }

  void goToNextPose() {
    if (currentIndex < widget.poses.length - 1) {
      setState(() => currentIndex++);
      startPose(widget.poses[currentIndex]);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Session Complete 🎉"),
          content: const Text("Great job! You finished your yoga session."),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void togglePause() {
    if (isPaused) {
      startTimer();
      _audioPlayer.resume();
    } else {
      timer?.cancel();
      _audioPlayer.pause();
    }
    setState(() => isPaused = !isPaused);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || isPaused) return;
      if (remainingTime > 1) {
        remainingTime--;
        if (remainingTime % 1 == 0) setState(() {});
      } else {
        t.cancel();
        goToNextPose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pose = widget.poses[currentIndex];
    final progress = (pose.duration - remainingTime) / pose.duration;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Yoga Session"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E6CF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          pose.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Image.asset(
                            pose.image,
                            key: ValueKey(pose.image),
                            height: 250,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Time left: $remainingTime s",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 80,
                  color: Colors.green.shade600,
                  icon: Icon(
                    isPaused
                        ? Icons.play_circle_fill
                        : Icons.pause_circle_filled,
                  ),
                  onPressed: togglePause,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
