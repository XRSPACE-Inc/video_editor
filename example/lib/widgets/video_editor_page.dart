import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_editor_example/widgets/crop_page.dart';

class VideoInfo {
  final Uri uri;
  final String videoName;
  final String creatorName;
  final Offset minCrop;
  final Offset maxCrop;
  final double startTimeSec; // in seconds
  final double endTimeSec; // in seconds
  final double volume;

  VideoInfo({
    required this.uri,
    required this.videoName,
    required this.creatorName,
    this.minCrop = Offset.zero,
    this.maxCrop = const Offset(1, 1),
    this.startTimeSec = 20,
    this.endTimeSec = 40,
    this.volume = 1.0,
  });
}

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.videoInfo});

  final VideoInfo videoInfo;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final double height = 60;
  final int minDuration = 5;
  final int maxDuration = 30;
  final double aspectRatio = 9 / 16;
  static const double navigationBarHeight = 70;

  late final VideoEditorController _controller = VideoEditorController.Uri(
    widget.videoInfo.uri,
    minDuration: Duration(seconds: minDuration),
    maxDuration: Duration(seconds: maxDuration),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: aspectRatio)
        .then((_) => setState(() {
              _controller.updateCrop(
                  widget.videoInfo.minCrop, widget.videoInfo.maxCrop);

              var minTrim = convertNormalizeTime(widget.videoInfo.startTimeSec);
              var maxTrim = convertNormalizeTime(widget.videoInfo.endTimeSec);
              _controller.updateTrim(minTrim, maxTrim);

              _controller.video
                  .seekTo(convertToDuration(widget.videoInfo.startTimeSec));

              _controller.video.setVolume(widget.videoInfo.volume);
            }))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await goBackCheck(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
                child: Column(
                  children: [
                    Stack(alignment: AlignmentDirectional.topCenter, children: [
                      // Use the stack to draw navgation bar on top of the video preview
                      // Because the preview page itself utilizes CustomPaint,
                      // it may draw beyond its container, overlapping other widgets.
                      preview(_controller, navigationBarHeight),
                      navgationBar(),
                      // todo: volume slider.
                    ]),
                    informationLabel(widget.videoInfo.videoName,
                        widget.videoInfo.creatorName),
                    videoSlider(),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget navgationBar() {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Leave editor',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => CropPage(controller: _controller),
              ),
            ),
            icon: const Icon(Icons.crop),
            tooltip: 'Open crop screen',
          ),
          TextButton(
            onPressed: _exportVideo,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget preview(VideoEditorController controller, double edgeInsetTopHeight) {
    return Container(
      margin: EdgeInsets.only(top: edgeInsetTopHeight), // navgation bar height
      height: 530,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CropGridViewer.preview(controller: controller),
          AnimatedBuilder(
            animation: controller.video,
            builder: (_, __) => AnimatedOpacity(
              opacity: controller.isPlaying ? 0 : 1,
              duration: kThemeAnimationDuration,
              child: GestureDetector(
                onTap: () {
                  if (controller.isPlaying) {
                    controller.video.pause();
                  } else {
                    controller.video.play();
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget informationLabel(String videoName, String creatorName) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(videoName),
          Text(creatorName),
        ],
      ),
    );
  }

  Widget videoSlider() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      height: 150,
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([
                _controller,
                _controller.video,
              ]),
              builder: (_, __) {
                final int duration = _controller.videoDuration.inSeconds;
                final double pos = _controller.trimPosition * duration;
                final int offsetPos = pos.ceil();

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: height / 4),
                  child: Row(children: [
                    Column(
                      children: [
                        Text(formatter(_controller.startTrim)),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    Text(calculateRelativeTime(
                        _controller.startTrim, Duration(seconds: offsetPos))),
                    const Expanded(child: SizedBox()),
                    Column(
                      children: [
                        Text(formatter(_controller.endTrim)),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ]),
                );
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(vertical: height / 4),
              child: TrimSlider(
                controller: _controller,
                height: height,
                horizontalMargin: height / 4,
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  String calculateRelativeTime(Duration startTime, Duration now) {
    var relativeTime = now - startTime;
    if (relativeTime <= Duration.zero) {
      return '0s';
    }

    return '${relativeTime.inSeconds.toString()}s';
  }

  double convertNormalizeTime(double timeSec) {
    if (_controller.videoDuration.inMilliseconds != 0) {
      var duration = _controller.videoDuration.inMilliseconds;
      return timeSec * 1000 / duration;
    } else {
      throw Exception("Video duration is 0");
    }
  }

  Duration convertToDuration(double timeSec) {
    var milliseconds = (timeSec * 1000).round();
    return Duration(milliseconds: milliseconds);
  }

  Future<dynamic> goBackCheck(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are you sure to leave edit?"),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
              ],
            ));
  }

  void _exportVideo() async {
    // todo : Export video to Model.Video Format.
    var startTime = _controller.startTrim;
    var endTime = _controller.endTrim;
    var minCrop = _controller.minCrop;
    var maxCrop = _controller.maxCrop;
    var videoName = widget.videoInfo.videoName;
    var creatorName = widget.videoInfo.creatorName;
    // todo: implement get volume in packages.

    print(
        "startTime : $startTime, endTime : $endTime, minCrop : $minCrop, maxCrop : $maxCrop");
  }
}
