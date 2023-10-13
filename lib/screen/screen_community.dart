// ignore_for_file: use_build_context_synchronously, avoid_print

// import 'dart:io';

// import 'dart:ffi' as ffi;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/screen/screen_add_post.dart';
import 'package:hot_deal_generation/screen/screen_post_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  String fieldValue = '';

  List<String> documentTitles = [];
  List<String> documentTexts = [];
  List<String> documentThumbnails = [];
  List<String> documentUserName = [];
  List<String> documentTime = [];
  List<String> documentViewCount = [];

  Future<void> getDocumentData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('BulletinBoard')
          .orderBy('postNum', descending: true) // postNum 필드를 기준으로 정렬
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        documentTitles.clear(); // 목록을 초기화
        documentTexts.clear();
        documentThumbnails.clear();
        documentUserName.clear();
        documentTime.clear();
        documentViewCount.clear();

        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          String title = document.get('title');
          String text = document.get('text');
          List<dynamic>? imageUrls = document.get('imageUrls');
          String userName = document.get('userName');
          String time = document.get('time');
          int viewCount = document.get('viewCount');
          String parseViewCount = viewCount.toString();

          String image =
              imageUrls != null && imageUrls.isNotEmpty ? imageUrls[0] : '';

          documentTitles.add(title);
          documentTexts.add(text);
          documentThumbnails.add(image);
          documentUserName.add(userName);
          documentTime.add(time);
          documentViewCount.add(parseViewCount);

          print(documentViewCount);
        }
      } else {
        print("컬렉션에 문서가 없음");
      }
    } catch (e) {
      print(e);
    }
  }

  // // 게시물 업로드 정보를 전달 받은 후 처리
  // Future<void> _handleUploadSuccess(BuildContext context) async {
  //   final uploadedMessage =
  //       ModalRoute.of(context)!.settings.arguments as String?;
  //   print(uploadedMessage);
  //   if (uploadedMessage == '게시물 업로드') {
  //     // 게시물 업로드가 성공한 경우, 정보 업데이트
  //     getDocumentData();
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getDocumentData();
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

  Future<int> getDocumentCountInCollection() async {
    // Firestore 컬렉션에 대한 참조를 얻습니다.
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('BulletinBoard');

    // 컬렉션 내의 모든 문서를 가져와서 길이를 반환합니다.
    QuerySnapshot querySnapshot = await collectionRef.get();
    int documentCount = querySnapshot.docs.length;

    return documentCount;
  }

  // 클릭한 게시물의 Firestore 문서 ID 가져오기
  void _navigateToPostDetail(BuildContext context, int postIndex) async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('BulletinBoard')
        .orderBy('postNum', descending: true)
        .get()
        .then((querySnapshot) => querySnapshot.docs[postIndex]);

    if (document.exists) {
      String documentId = document.id;

      // Firestore에서 해당 문서를 가져옵니다.
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('BulletinBoard')
          .doc(documentId);
      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        // 현재 조회수를 가져와서 1 증가시킵니다.
        int currentViewCount = documentSnapshot.get('viewCount') ?? 0;
        int newViewCount = currentViewCount + 1;

        // Firestore에 업데이트된 조회수를 저장합니다.
        await documentReference.update({'viewCount': newViewCount});

        // 게시물 상세 화면으로 이동합니다.
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => PostDetailPage(documentId: documentId),
          ),
        )
            .then((result) async {
          if (result == "1") {
            await getDocumentData();
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<int>(
          future: getDocumentCountInCollection(), // 문서 개수를 가져오는 비동기 함수 호출
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 데이터가 로드되기를 기다릴 동안 로딩 표시
            } else {
              if (snapshot.hasError) {
                return Text('에러 발생: ${snapshot.error}');
              } else {
                final int documentCount = snapshot.data ?? 0; // 문서 개수 또는 0으로 설정
                return SizedBox(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await getDocumentData();
                      setState(() {});
                    },
                    child: documentCount > 0
                        ? ListView.builder(
                            itemCount:
                                documentTitles.length, // 게시물 개수에 문서 개수를 할당
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _navigateToPostDetail(context, index);
                                },
                                child: Card(
                                  margin: const EdgeInsets.all(2.0),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  documentTitles[index],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.03,
                                                ),
                                                documentThumbnails.isNotEmpty &&
                                                        documentThumbnails[
                                                                index]
                                                            .isNotEmpty
                                                    ? Image.asset(
                                                        'images/imageicon.png',
                                                        width: width * 0.04,
                                                      )
                                                    : const SizedBox(width: 10),
                                              ],
                                            ),
                                            SizedBox(
                                              height: height * 0.007,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  documentUserName[index],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.02,
                                                ),
                                                Text(
                                                  '조회 : ${documentViewCount[index]}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.02,
                                                ),
                                                Text(
                                                  documentTime[index],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsets.all(width * 0.015),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          child: const Column(
                                            children: [
                                              Text('댓글'),
                                              Text('0'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              '게시물이 없습니다.',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                );
              }
            }
          },
        ),
        floatingActionButton: loggedUser != null
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPost(),
                    ),
                  ).then((result) async {
                    if (result == "1") {
                      await getDocumentData();
                      setState(() {});
                    }
                  });
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
