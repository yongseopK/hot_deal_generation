// ignore_for_file: use_build_context_synchronously, avoid_print

// import 'dart:io';

// import 'dart:ffi' as ffi;

import 'dart:async';
// import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hot_deal_generation/screen/screen_add_post.dart';
import 'package:hot_deal_generation/screen/screen_post_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hot_deal_generation/theme_provider.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  String fieldValue = '';

  bool isNavigatingToDetail = false;

  int recommendLength = 0;

  int totalDocumentCount = 0;

  bool isLoading = true;

  List<String> documentTitles = [];
  List<String> documentTexts = [];
  List<String> documentThumbnails = [];
  List<String> documentUserName = [];
  List<String> documentTime = [];
  List<String> documentDate = [];
  List<String> documentViewCount = [];
  List<String> documentRecomendCount = [];
  List<String> documentCommentCount = [];

  Future<void> getDocumentData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('BulletinBoard')
          .orderBy('postNum', descending: true)
          .get();

      documentTitles.clear();
      documentTexts.clear();
      documentThumbnails.clear();
      documentUserName.clear();
      documentTime.clear();
      documentDate.clear();
      documentViewCount.clear();
      documentRecomendCount.clear();
      documentCommentCount.clear();
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          String title = document.get('title');
          String text = document.get('text');
          List<dynamic>? imageUrls = document.get('imageUrls');
          String userName = document.get('userName');
          String time = document.get('time');
          String date = document.get('date');
          int viewCount = document.get('viewCount');
          String parseViewCount = viewCount.toString();
          List<dynamic>? recommend = document['recommendInfo'];
          int commentCount = document.get('commentCount');
          String parseCommentCount = commentCount.toString();

          recommendLength = recommend!.length;
          String recommendCount =
              recommend.isNotEmpty ? recommendLength.toString() : "0";

          String image =
              imageUrls != null && imageUrls.isNotEmpty ? imageUrls[0] : '';

          documentTitles.add(title);
          documentTexts.add(text);
          documentThumbnails.add(image);
          documentUserName.add(userName);
          documentTime.add(time);
          documentDate.add(date);
          documentViewCount.add(parseViewCount);
          documentRecomendCount.add(recommendCount);
          documentCommentCount.add(parseCommentCount);
        }
      } else {
        print("컬렉션에 문서가 없음");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadDataInBackground() async {
    try {
      // await getCommentCounts();
      await getDocumentData();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    loadDataInBackground();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
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
        body: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : FutureBuilder<int>(
                    future:
                        getDocumentCountInCollection(), // 문서 개수를 가져오는 비동기 함수 호출
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                          ],
                        ); // 데이터가 로드되기를 기다릴 동안 로딩 표시
                      } else {
                        if (snapshot.hasError) {
                          return Text('에러 발생: ${snapshot.error}');
                        } else {
                          return SizedBox(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('BulletinBoard')
                                        .orderBy('postNum', descending: true)
                                        .get();
                                print('타일 개수:  ${querySnapshot.docs.length}');
                                loadDataInBackground();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: documentTitles.isNotEmpty
                                  ? ListView.builder(
                                      itemCount: documentTitles.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            print('인덱스 : $index');
                                            if (!isNavigatingToDetail) {
                                              isNavigatingToDetail = true;
                                              _navigateToPostDetail(
                                                  context, index);

                                              Timer(const Duration(seconds: 1),
                                                  () {
                                                isNavigatingToDetail = false;
                                              });
                                            }
                                          },
                                          child: Card(
                                            margin: const EdgeInsets.all(2.0),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 15),
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            documentTitles[
                                                                index],
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.03,
                                                          ),
                                                          documentThumbnails
                                                                      .isNotEmpty &&
                                                                  documentThumbnails[
                                                                          index]
                                                                      .isNotEmpty
                                                              ? Icon(
                                                                  Icons.photo,
                                                                  size: width *
                                                                      0.05,
                                                                  color: isDarkMode(
                                                                          context)
                                                                      ? null
                                                                      : Colors
                                                                          .black,
                                                                )
                                                              : const SizedBox(
                                                                  width: 10),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.007,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            documentUserName[
                                                                index],
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: isDarkMode(
                                                                      context)
                                                                  ? null
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.02,
                                                          ),
                                                          Text(
                                                            '조회 ${documentViewCount[index]}',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: isDarkMode(
                                                                      context)
                                                                  ? null
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.02,
                                                          ),
                                                          Text(
                                                            documentDate[index],
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: isDarkMode(
                                                                      context)
                                                                  ? null
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.01,
                                                          ),
                                                          Text(
                                                            documentTime[index],
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: isDarkMode(
                                                                      context)
                                                                  ? null
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    width: width * 0.18,
                                                    padding: EdgeInsets.all(
                                                      width * 0.015,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            const Icon(
                                                              CupertinoIcons
                                                                  .chat_bubble_2,
                                                            ),
                                                            Text(
                                                                documentCommentCount[
                                                                    index]),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            const Icon(Icons
                                                                .thumb_up_alt_outlined),
                                                            Text(
                                                                documentRecomendCount[
                                                                    index]),
                                                          ],
                                                        ),
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                            ),
                          );
                        }
                      }
                    },
                  );
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
                      // await getCommentCounts();
                      await getDocumentData();
                      setState(() {});
                    }
                  });
                },
                backgroundColor: Colors.black,
                elevation: 0.0,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
