import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor_example/widgets/video_editor_page.dart';

void main() => runApp(
      MaterialApp(
        title: 'Flutter Video Editor Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
          brightness: Brightness.dark,
          tabBarTheme: const TabBarTheme(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          dividerColor: Colors.white,
        ),
        home: goToPage(),
      ),
    );

Widget goToPage() {
  var testUrl =
      "https://rr5---sn-p5qlsn6l.googlevideo.com/videoplayback?expire=1706531084&ei=rES3ZcuJGpWi_9EPh-qasAE&ip=54.86.50.139&id=o-AMYkqtPJFnVQlk74U8dK12ym0L83BP8xRazNAQTLlfqH&itag=22&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&mh=ON&mm=31%2C26&mn=sn-p5qlsn6l%2Csn-vgqsrnez&ms=au%2Conr&mv=u&mvi=5&pl=23&vprv=1&mime=video%2Fmp4&cnr=14&ratebypass=yes&dur=195.929&lmt=1696965019522629&mt=1706509072&fvip=5&fexp=24007246&c=TVANDROID&txp=5318224&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cvprv%2Cmime%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=AJfQdSswRQIhAMNMp4ZtRJGzHf7_utaMN8g-XBdtJZFEwaQyEmaYPkGKAiALSlq28d_a4T5WsYht-1zoGgA9zF_to5bd9fJcd9IGTg%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl&lsig=AAO5W4owRAIgULMc3dDJDFMbqjktcmdFdduFc46wVcwAGNU7W_OpReMCIGajMLAZOGnYzPT044bLHGwvAeasvrba3FgI7xK5kjg-";

  var videoInfo = VideoInfo(
    uri: Uri.parse(testUrl),
    videoName: "Video Name",
    creatorName: "Youtube Creator Name",
  );

  return VideoEditor(videoInfo: videoInfo);
}

class VideoPickerWidget extends StatefulWidget {
  const VideoPickerWidget({super.key});

  @override
  State<VideoPickerWidget> createState() => _VideoPickerWidgetState();
}

class _VideoPickerWidgetState extends State<VideoPickerWidget> {
  final ImagePicker _picker = ImagePicker();

  var testUrl = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Picker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Click on the button to select video"),
          ],
        ),
      ),
    );
  }
}
