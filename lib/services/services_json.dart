import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

Future<List<Pose>> loadPoses() async {
  final data = await rootBundle.loadString('assets/poses.json');
  final Map<String, dynamic> jsonResult = jsonDecode(data);

  final Map<String, dynamic> images = Map<String, dynamic>.from(
    jsonResult['assets']['Images'],
  );
  final Map<String, dynamic> audio = Map<String, dynamic>.from(
    jsonResult['assets']['Audio'],
  );
  final List<dynamic> sequence = jsonResult['sequence'];

  List<Pose> poses = [];

  for (var segment in sequence) {
    final String audioPath = audio[segment['audioRef']];
    final int duration = segment['durationSec'];

    // Loop through script steps for images
    for (var step in segment['script']) {
      final imagePath = images[step['imageRef']];

      poses.add(
        Pose(
          name: segment['name'],
          image: 'assets/Images/${imagePath.toLowerCase()}',
          audio: 'Audio/$audioPath',
          duration: duration,
        ),
      );
    }
  }

  return poses;
}
