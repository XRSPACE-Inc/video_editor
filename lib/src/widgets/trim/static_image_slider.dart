import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_editor/src/controller.dart';
import 'package:video_editor/src/utils/helpers.dart';
import 'package:video_editor/src/widgets/image_viewer.dart';
import 'package:image/image.dart' as dart_image;

class StaticImageSlider extends StatefulWidget {
  const StaticImageSlider({
    super.key,
    required this.controller,
    required this.imagePath,
    this.height = 60,
  });

  /// The [height] param specifies the height of the generated thumbnails
  final double height;

  /// The [imagePath] param specified the path of the image to be filled in repeatedly inside the timeline body
  final String imagePath;

  final VideoEditorController controller;

  @override
  State<StaticImageSlider> createState() => _StaticImageSliderState();
}

class _StaticImageSliderState extends State<StaticImageSlider> {
  // The width, height of the image's original dimensions
  int imageWidth = 0;
  int imageHeight = 0;

  final _spaceWidth = 4.0;

  @override
  void initState() {
    super.initState();
    getImageDimensions(widget.imagePath);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getImageDimensions(String imagePath) async {
    final byteData = await rootBundle.load(imagePath);
    final img = dart_image.decodeImage(byteData.buffer.asUint8List());
    setState(() {
      imageWidth = img?.width ?? widget.height.toInt();
      imageHeight = img?.height ?? widget.height.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageWidth == 0 || imageHeight == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final int imageCount = (screenWidth / imageWidth).floor();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          imageCount,
          (index) => Image(
            image: AssetImage(widget.imagePath),
            width: imageWidth.toDouble(),
            height: imageHeight.toDouble(),
          ),
        ).fold<List<Widget>>(
            [], (acc, img) => acc..addAll([img, SizedBox(width: _spaceWidth)])),
      ),
    );
  }
}
