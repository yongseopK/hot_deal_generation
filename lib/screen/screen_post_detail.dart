// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({Key? key, required this.documentId}) : super(key: key);
  // final int postIndex;
  final String documentId;

  @override
  State<PostDetailPage> createState() =>
      // ignore: no_logic_in_create_state
      _PostDetailPageState(documentId: documentId);
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser = FirebaseAuth.instance.currentUser;

  final String documentId;
  static String result = "1";
  double fontSize = 15.0;
  double minSize = 5.0;
  double maxSize = 35.0;

  bool isRecommend = false;

  _PostDetailPageState({required this.documentId});

  String title = '';
  String text = '';
  String image = '';
  String userName = '';
  String date = '';
  String time = '';
  int intViewCount = 0;
  String viewCount = '';
  List<String> recommendInfo = [];

  String commentText = '';

  @override
  void initState() {
    super.initState();
    // 게시물 정보를 가져오는 비동기 함수 호출
    getPostDetails();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPostDetails() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('BulletinBoard')
          .doc(widget.documentId) // documentId 사용
          .get();

      if (document.exists) {
        final dynamic rawData = document['recommendInfo'];
        recommendInfo = List<String>.from(rawData ?? []);
        setState(() {
          title = document['title'];
          text = document['text'];
          image =
              document['imageUrls'] != null && document['imageUrls'].isNotEmpty
                  ? document['imageUrls'][0]
                  : '';
          userName = document['userName'];
          date = document['date'];
          time = document['time'];
          intViewCount = document['viewCount'];
          viewCount = intViewCount.toString();
        });
      } else {
        // 게시물을 찾을 수 없을 때 처리 (예: 삭제된 게시물)
        // 필요에 따라 에러 메시지를 출력하거나 다른 작업을 수행
        print('게시물을 찾을 수 없습니다.');
      }
    } on FirebaseAuthException catch (e) {
      print('게시물 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  addComment() {
    print('어쩔티비');
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.center,
            child: Text(title),
          ),
          elevation: 0.0,
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, result);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '작성자: $userName',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '$date $time',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '조회 $viewCount',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            const Text(
                              '댓글 1',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: 30,
                              child: IconButton(
                                onPressed: () {
                                  if (fontSize < maxSize) {
                                    fontSize += 2;
                                  }
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.zoom_in_outlined,
                                  size: width * 0.05,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: IconButton(
                                onPressed: () {
                                  if (fontSize > minSize) {
                                    fontSize -= 2;
                                  }
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.zoom_out_outlined,
                                  size: width * 0.05,
                                  color: Colors.blue,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Container(
                      height: 0.7,
                      width: width,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              if (image.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.network(image),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  '내용: $text',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: !recommendInfo.contains(loggedUser!.email)
                      ? Colors.white
                      : Colors.black,
                  foregroundColor: !recommendInfo.contains(loggedUser!.email)
                      ? Colors.black
                      : Colors.white,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
                onPressed: () async {
                  final currentDocument = FirebaseFirestore.instance
                      .collection('BulletinBoard')
                      .doc(widget.documentId);

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final userData = await FirebaseFirestore.instance
                        .collection('user')
                        .doc(user!.uid)
                        .get();

                    if (userData.exists) {
                      if (!recommendInfo.contains(loggedUser!.email)) {
                        currentDocument.update({
                          'recommendInfo':
                              FieldValue.arrayUnion([loggedUser!.email])
                        });
                        isRecommend = true;

                        Fluttertoast.showToast(
                          msg: '추천하셨습니다.',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                        );
                        getPostDetails();
                      } else {
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('안내'),
                              content: const Text('이미 추천한 글입니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('닫기'),
                                )
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      print('사용자 데이터를 찾을 수 없음');
                    }
                  } on FirebaseException catch (e) {
                    print(e);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    !recommendInfo.contains(loggedUser!.email)
                        ? const Icon(
                            Icons.thumb_up_alt_outlined,
                          )
                        : const Icon(
                            Icons.thumb_up_alt_rounded,
                          ),
                    SizedBox(
                      width: width * 0.01,
                    ),
                    const Text(
                      '추천',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.chat_bubble_2,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '댓글',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Container(
                  height: 0.3,
                  color: Colors.black,
                ),
              ),
              Padding(
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
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: TextFormField(
                              enabled: loggedUser != null ? true : false,
                              validator: (val) =>
                                  val == "" ? "내용을 입력해주세요" : null,
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
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          loggedUser != null ? addComment() : null;
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // 홀수 인덱스이면 회색, 짝수 인덱스이면 흰색 배경
                        Color itemColor = index.isOdd
                            ? Colors.transparent
                            : Colors.grey.shade200;
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                                color: itemColor,
                                borderRadius: BorderRadius.circular(12)),
                            height: height * 0.11,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('닉네임'),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  const Text('내용'),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  const Text('날짜 / 시간')
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
