import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const String fileName = "test8.jpg";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await downloadImage(
    "https://docs.flutter.dev/assets/images/dash/Dash.png",
    fileName,
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
        child: ElevatedButton(
          child: const Text("Share"),
          onPressed: () async {
            Directory cacheDir = await getTemporaryDirectory();
            print((await Share.shareFilesWithResult([
                  "${cacheDir.path}/$fileName",
                  "${cacheDir.path}/$fileName",
                  "${cacheDir.path}/$fileName"
                ]))
                    .status ==
                ShareResultStatus.success);
          },
        ),
      ),
    );
  }
}

Future<File> downloadImage(String url, String filename) async {
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
