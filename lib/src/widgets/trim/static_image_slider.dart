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
    this.width = 60,
  });

  /// The [width, height] param specifies the width,height of component if failed to load image
  ///
  /// Default to 60
  final double height;
  final double width;

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

  @override
  void initState() {
    super.initState();
    getImageDimensions(widget.imagePath);
  }

  Future<void> getImageDimensions(String imagePath) async {
    final byteData = await rootBundle.load(imagePath);
    final img = dart_image.decodeImage(byteData.buffer.asUint8List());
    setState(() {
      imageWidth = img?.width ?? widget.width.toInt();
      imageHeight = img?.height ?? widget.height.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageWidth == 0 || imageHeight == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(
              widget.imagePath,
              width: screenWidth,
              height: imageHeight.toDouble(),
              repeat: ImageRepeat.repeatX,
            ),
          )
        ],
      ),
    );
  }
}
