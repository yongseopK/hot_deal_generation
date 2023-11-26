import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void removePost(
  String userName,
  String documentId,
  BuildContext context,
  String result,
  String collectionName,
) async {
  // 현재 사용자 정보 불러오기
  final user = FirebaseAuth.instance.currentUser;
  final userData =
      await FirebaseFirestore.instance.collection('user').doc(user!.uid).get();

  Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;
  String currentUserName = userDataMap['userName'];

  try {
    if (currentUserName == userName) {
      CollectionReference subCollectionRef = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .collection('comments');

      QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();

      for (QueryDocumentSnapshot doc in subCollectionSnapshot.docs) {
        await subCollectionRef.doc(doc.id).delete();
      }

      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .delete()
          .then((value) {
        Navigator.pop(context, result);
        Fluttertoast.showToast(
          msg: '삭제가 완료됐습니다.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        Navigator.pop(context, result);
      }).catchError((error) {
        print(error);
      });
    } else {
      Fluttertoast.showToast(
        msg: "본인의 게시물만 삭제할 수 있습니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  } on FirebaseException catch (e) {
    print(e);
  }
}

Future showRemovePostDialog(
  BuildContext context,
  double height,
  String userName,
  String documentId,
  String result,
  String collectionName,
) {
  return Platform.isAndroid
      ? showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Column(
                      children: [
                        Text(
                          '안내',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    const Text(
                      '게시물을 삭제하시겠습니까?',
                      style: TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            removePost(userName, documentId, context, result,
                                collectionName);
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            '삭제',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('닫기'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        )
      : showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text("안내"),
              content: const Text("게시물을 삭제하시겠습니까?"),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    removePost(
                        userName, documentId, context, result, collectionName);
                  },
                  child: const Text(
                    "삭제",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("닫기"),
                ),
              ],
            );
          },
        );
}
