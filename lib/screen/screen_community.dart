import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          String title = document.get('title');
          String text = document.get('text');
          List<dynamic>? imageUrls = document.get('imageUrls');
          String image = imageUrls != null && imageUrls.isNotEmpty
              ? imageUrls[0]
              : '빈 이미지 URL';

          documentTitles.add(title);
          documentTexts.add(text);
          documentThumbnails.add(image);
          // documentThumbnails.add(imageUrl);
        }

        setState(() {});
        print(documentThumbnails);
      } else {
        print("컬렉션에 문서가 없음");
      }
    } catch (e) {
      print(e);
    }
  }

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
                                    leading: Image.network(
                                      documentThumbnails[index],
                                      width: width * 0.15,
                                      height: height * 0.15,
                                      fit: BoxFit.cover,
                                    ),
                                    // leading: Container(
                                    //   color: Colors.black,
                                    //   // height: height * 0.2,
                                    //   width: width * 0.15,
                                    // ),
                                    title: Text(
                                      documentTitles[index],
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(
                                      documentTexts[index],
                                      style: const TextStyle(fontSize: 15),
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
                  );
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}

void _navigateToPostDetail(BuildContext context, int postIndex) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PostDetailPage(postIndex: postIndex),
    ),
  );
}
