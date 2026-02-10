import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marker_seek_bar_poc_application/components/marker_seek_bar.dart';
import 'package:video_player/video_player.dart';

import 'models/marker_model.dart';

void main() {
  runApp(const MarkerSeekBarPocApplication());
}

class MarkerSeekBarPocApplication extends StatefulWidget {
  const MarkerSeekBarPocApplication({super.key});

  @override
  State<MarkerSeekBarPocApplication> createState() => _MarkerSeekBarPocApplicationState();
}

class _MarkerSeekBarPocApplicationState extends State<MarkerSeekBarPocApplication> {

  final controller = VideoPlayerController.networkUrl(Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'));
  List<MarkerModel> markerList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final jsonString = await rootBundle.loadString('assets/video_time_stamp.json');
      markerList = (jsonDecode(jsonString) as List<dynamic>).map((e) => MarkerModel.fromJson(e)).toList();

      await controller.initialize().then((value) => setState(() {}));
      controller.addListener(() => setState(() {}));
      controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey,
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            MarkerSeekBar(
              duration: controller.value.duration,
              position: controller.value.position,
              markers: markerList,
              onSeek: (value) => controller.seekTo(value),
            )
          ],
        ),
      ),
    );
  }
}
