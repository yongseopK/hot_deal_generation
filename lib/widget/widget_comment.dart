// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

Widget commentFormField({
  required User? loggedUser,
  required dynamic widget,
  required String documentId,
  required Function() getCommentData,
  required TextEditingController commentTextController,
  required String commentText,
  required void Function(VoidCallback) setStateCallback,
  required String collectionName,
  required Function() isDarkMode,
  required BuildContext context,
  required double height,
  required bool isButtonDisabled,
  required Function() enableButton,
  required bool isLogin,
}) {
  void addComment() async {
    final currentDocument = FirebaseFirestore.instance
        .collection(collectionName)
        .doc(widget.documentId);

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(collectionName).doc(documentId);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(user!.uid)
          .get();

      Map<String, dynamic> userDataMap =
          userData.data() as Map<String, dynamic>;
      String currentUserName = userDataMap['userName'];

      DateTime dt = DateTime.now();

      String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);

      final commentData = {
        'userName': currentUserName,
        'comment': commentText,
        'dateTime': dateTime
      };

      await currentDocument.collection('comments').add(commentData);

      int commentCount = documentSnapshot.get('commentCount');
      int newCommentCount = commentCount + 1;

      await documentReference.update({'commentCount': newCommentCount});
      print('댓글 개수 : $commentCount');

      await getCommentData();

      commentTextController.clear();
      commentText = "";

      setStateCallback(() {});
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  return Padding(
    // 댓글 입력창 양옆 패딩
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Padding(
      // 댓글 입력창 밑쪽 패딩
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: height * 0.1,
              decoration: BoxDecoration(
                color: isDarkMode() ? Colors.black : Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextFormField(
                  validator: (val) => val == "" ? "댓글을 입력해주세요" : null,
                  controller: commentTextController,
                  enabled: loggedUser != null ? true : false,
                  onSaved: (value) {
                    commentText = value!;
                  },
                  onChanged: (value) {
                    commentText = value;
                  },
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: loggedUser != null
                          ? "내용을 입력해주세요"
                          : "로그인 후 댓글 이용이 가능합니다.",
                      hintStyle: const TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IgnorePointer(
            ignoring: loggedUser == null ? true : false,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (isButtonDisabled) {
                  return;
                }

                if (loggedUser == null) return;

                if (commentText.length >= 3) {
                  setStateCallback(() {
                    isButtonDisabled = true;
                  });
                  addComment();

                  Timer(const Duration(seconds: 1), enableButton);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  Fluttertoast.showToast(
                    msg: "3글자 이상 입력해주세요",
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                  );
                }
              },
              child: SizedBox(
                height: height * 0.1,
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    '댓글 등록',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget showComment({
  required List<String> commentArr,
  required int numberOfDocument,
  required Function() isDarkMode,
  required BuildContext context,
  required List<String> userNameArr,
  required List<String> commentDocIds,
  required String documentId,
  required double height,
  required Function() getCommentData,
  required void Function(VoidCallback) setStateCallback,
  required List<String> dateTimeArr,
  required String collectionName,
}) {
  String currentUserName;
  void removeComment(
      CollectionReference<Object?> subCollection, String documentIdToDelete) {
    subCollection.doc(documentIdToDelete).delete().then((value) async {
      Fluttertoast.showToast(
        msg: '댓글이 삭제됐습니다.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
      );
      await getCommentData();

      DocumentReference documentReference =
          FirebaseFirestore.instance.collection(collectionName).doc(documentId);
      DocumentSnapshot documentSnapshot = await documentReference.get();

      int commentCount = documentSnapshot.get('commentCount');
      int newCommentCount = commentCount - 1;

      await documentReference.update({'commentCount': newCommentCount});

      setStateCallback(() {});
    }).catchError((error) {
      print('문서 삭제 실패 : $error');
    });
    Navigator.of(context).pop();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: commentArr.isNotEmpty
        ? Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numberOfDocument,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 홀수 인덱스이면 회색, 짝수 인덱스이면 흰색 배경
                  Color itemColor =
                      index.isOdd ? Colors.transparent : Colors.grey.shade200;
                  Border? itemBorder = index.isOdd
                      ? Border.all(color: Colors.grey.shade200)
                      : null;
                  Color textColor =
                      index.isOdd && isDarkMode() ? Colors.white : Colors.black;

                  return Container(
                    decoration: BoxDecoration(
                        color: itemColor,
                        border: itemBorder,
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userNameArr[index],
                                style: TextStyle(color: textColor),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  String documentIdToDelete =
                                      commentDocIds[index];
                                  try {
                                    if (FirebaseAuth.instance.currentUser !=
                                        null) {
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      final currentUserData =
                                          await FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(user!.uid)
                                              .get();

                                      Map<String, dynamic> userDataMap =
                                          currentUserData.data()
                                              as Map<String, dynamic>;

                                      currentUserName = userDataMap['userName'];
                                    } else {
                                      currentUserName = "guest";
                                    }

                                    CollectionReference mainCollection =
                                        FirebaseFirestore.instance
                                            .collection(collectionName);

                                    CollectionReference subCollection =
                                        mainCollection
                                            .doc(documentId)
                                            .collection('comments');

                                    FirebaseFirestore.instance
                                        .collection(collectionName)
                                        .doc(documentId)
                                        .collection('comments')
                                        .doc(documentIdToDelete)
                                        .get()
                                        .then((DocumentSnapshot doc) {
                                      if (doc.exists) {
                                        Map<String, dynamic> data =
                                            doc.data() as Map<String, dynamic>;
                                        String commentUserName =
                                            data['userName'];
                                        print(commentUserName);

                                        if (currentUserName ==
                                            commentUserName) {
                                          Platform.isIOS
                                              ? showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return CupertinoAlertDialog(
                                                      title: const Text("안내"),
                                                      content: const Text(
                                                          "댓글을 삭제하시겠습니까?"),
                                                      actions: [
                                                        CupertinoDialogAction(
                                                          onPressed: () {
                                                            removeComment(
                                                                subCollection,
                                                                documentIdToDelete);
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
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("닫기"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                )
                                              : showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10.0,
                                                        ),
                                                      ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            const Text(
                                                              '안내',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 19,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  height * 0.03,
                                                            ),
                                                            const Text(
                                                              '댓글을 삭제하시겠습니까?',
                                                              style: TextStyle(
                                                                  fontSize: 17),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    removeComment(
                                                                        subCollection,
                                                                        documentIdToDelete);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    '삭제',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          '닫기'),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "본인이 작성한 댓글만 삭제할 수 있습니다.",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                          );
                                        }
                                      } else {
                                        print('null');
                                      }
                                    });
                                  } on FirebaseException catch (e) {
                                    print(e);
                                  }
                                },
                                child: const Icon(
                                  Icons.dangerous_outlined,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text(
                            commentArr[index],
                            style: TextStyle(color: textColor),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text(
                            dateTimeArr[index],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          )
        : SizedBox(
            height: height * 0.3,
            child: const Center(
              child: Text(
                "댓글이 없습니다.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
  );
}
