import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveImage(
    BuildContext context, List<String> imageUrls, int index) async {
  try {
    final http.Response response = await http.get(Uri.parse(imageUrls[index]));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();

      // Use a dynamic file name based on the index
      File file = File('${directory.path}/local_image_$index.jpg');

      await file.writeAsBytes(Uint8List.fromList(response.bodyBytes));

      // Save the image to the device's gallery
      await ImageGallerySaver.saveFile(file.path);

      Fluttertoast.showToast(
        msg: "저장됐습니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } else {
      print('Failed to download image. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error saving image: $e');
  }
}

Future<void> showImageSaveDialog(
    BuildContext context, List<String> imageUrls, int index) async {
  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("이미지 저장"),
        content: const Text("해당 이미지를 저장하시겠습니까?"),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "취소",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () {
              saveImage(context, imageUrls, index);
            },
            isDefaultAction: true,
            child: const Text("저장"),
          )
        ],
      ),
    );
  } else {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("이미지 저장"),
        content: const Text("해당 이미지를 저장하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () async {
              saveImage(context, imageUrls, index);
            },
            child: const Text("저장"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "취소",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget SaveImageDialog(
    BuildContext context, List<String> imageUrls, int index) {
  return GestureDetector(
    onLongPress: () => showImageSaveDialog(context, imageUrls, index),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(imageUrls[index]),
    ),
  );
}
