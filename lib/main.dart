import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const String normalJPEG1 = "test_normalJPEG_1.png";
const String normalJPEG2 = "test_normalJPEG_2.jpg";
const String noExtensionJPEG = "test_noExtensionJPEG";
const String pdfDocument = "test_pdfDocument.pdf";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await downloadFile(
    "https://docs.flutter.dev/assets/images/dash/Dash.png",
    normalJPEG1,
  );
  await downloadFile(
    "https://docs.flutter.dev/assets/images/dash/early-dash-sketches2.jpg",
    normalJPEG2,
  );
  await downloadFile(
    "https://docs.flutter.dev/assets/images/dash/early-dash-sketches5.jpg",
    noExtensionJPEG,
  );
  await downloadFile(
    "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    pdfDocument,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter share tests',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Share Tests"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Share plain text"),
              onPressed: () async {
                await sharePlainText();
              },
            ),
            ElevatedButton(
              child: const Text("Share single image"),
              onPressed: () async {
                await shareSingleImage();
              },
            ),
            ElevatedButton(
              child: const Text("Share multiple images"),
              onPressed: () async {
                await shareMultipleImages();
              },
            ),
            ElevatedButton(
              child: const Text("Share without extension"),
              onPressed: () async {
                await shareNoExtension();
              },
            ),
            ElevatedButton(
              child: const Text("Share PDF document"),
              onPressed: () async {
                await sharePdfDocument();
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<File> downloadFile(String url, String filename) async {
  var httpClient = HttpClient();
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  var bytes = await consolidateHttpClientResponseBytes(response);
  String dir = (await getTemporaryDirectory()).path;
  File file = File('$dir/$filename');
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
  return file;
}

void printResult(ShareResult result) {
  print('----- RESULT -----');
  print('Status: ${result.status}');
  print('Raw:    ${result.raw}');
  print('------------------');
}

Future<void> shareFilesWithResult(List<String> paths, {List<String> mimeTypes = const []}) async {
  final res = await Share.shareFilesWithResult(paths, mimeTypes: mimeTypes);
  printResult(res);
}

//* Plaintext
Future<void> sharePlainText() async {
  final text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent eget ante molestie, euismod felis et.";
  final subject = "Vestibulum velit magna, malesuada eu. ";
  final res = await Share.shareWithResult(text, subject: subject);
  printResult(res);
}

//* Single image
Future<void> shareSingleImage() async {
  Directory cacheDir = await getTemporaryDirectory();
  await shareFilesWithResult([
    "${cacheDir.path}/$normalJPEG1",
  ]);

}

//* Multiple images
// Yes, the preview stacks the two previews - look closely
Future<void> shareMultipleImages() async {
  Directory cacheDir = await getTemporaryDirectory();
  await shareFilesWithResult([
    "${cacheDir.path}/$normalJPEG1",
    "${cacheDir.path}/$normalJPEG2",
  ]);
}

//* No Extension
// If you comment out the `mimeTypes` no preview picture will be shown
Future<void> shareNoExtension() async {
  Directory cacheDir = await getTemporaryDirectory();
  await shareFilesWithResult([
    "${cacheDir.path}/$noExtensionJPEG",
  ], mimeTypes: [
    "image/JPEG"
  ]);
}

//* PDF document (no image)
Future<void> sharePdfDocument() async {
  Directory cacheDir = await getTemporaryDirectory();
  await shareFilesWithResult([
    "${cacheDir.path}/$pdfDocument",
  ]);
}
