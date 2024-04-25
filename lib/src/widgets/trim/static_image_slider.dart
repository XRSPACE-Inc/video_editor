import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_editor/src/controller.dart';
import 'package:video_editor/src/utils/helpers.dart';

class StaticImageSlider extends StatelessWidget {
  const StaticImageSlider({
    super.key,
    required this.controller,
    required this.imagePath,
    this.height = 60,
  });

  /// The [height] param specifies the height of component
  ///
  /// Default to 60
  final double height;

  /// The [imagePath] param specified the path of the image to be filled in repeatedly inside the timeline body
  final String imagePath;

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          Container(
            child: Image.asset(
              imagePath,
              width: screenWidth,
              height: height,
              repeat: ImageRepeat.repeatX,
            ),
          )
        ],
      ),
    );
  }
}
