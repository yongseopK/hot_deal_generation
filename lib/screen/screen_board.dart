import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hot_deal_generation/screen/screen_post_detail.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;

import 'package:hot_deal_generation/screen/screen_product_detail.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  List<String> recommendTitle = [];
  List<String> recommendCount = [];
  List<String> categorys = [];
  List<String> commentCounts = [];
  List<String> dates = [];
  List<String> times = [];
  List<String> deliveryFees = [];
  List<String> platforms = [];
  List<String> prices = [];
  List<String> userNames = [];
  List<String> viewCounts = [];

  void getBestseller() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Product')
          .orderBy('recommendCount', descending: true)
          .limit(5)
          .get();

      recommendTitle.clear();
      recommendCount.clear();
      categorys.clear();
      commentCounts.clear();
      dates.clear();
      times.clear();
      deliveryFees.clear();
      platforms.clear();
      prices.clear();
      userNames.clear();
      viewCounts.clear();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          String title = document.get('title');
          recommendTitle.add(title);

          int count = document.get('recommendCount');
          String parseCount = count.toString();
          recommendCount.add(parseCount);

          String category = document.get('category');
          categorys.add(category);

          int intCommnetCount = document.get('commentCount');
          String commentCount = intCommnetCount.toString();
          commentCounts.add(commentCount);

          String date = document.get('date');
          dates.add(date);

          String time = document.get('time');
          times.add(time);

          int intDeliveryFee = document.get('deliveryFee');
          String deliveryFee = intDeliveryFee.toString();
          deliveryFees.add(deliveryFee);

          String platform = document.get('platform');
          platforms.add(platform);

          int intPrice = document.get('price');
          String price = intPrice.toString();
          prices.add(price);

          String userName = document.get('userName');
          userNames.add(userName);

          int intViewCount = document.get('viewCount');
          String viewCount = intViewCount.toString();
          viewCounts.add(viewCount);
        }
      }
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    loadDataInBackground();
    print("안녕");
  }

  bool isLoading = true;
  bool isNavigatingToDetail = false;
  Future<int> getDocumentCountInCollection() async {
    // Firestore 컬렉션에 대한 참조를 얻습니다.
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('Product');

    // 컬렉션 내의 모든 문서를 가져와서 길이를 반환합니다.
    QuerySnapshot querySnapshot = await collectionRef
        .orderBy('recommendCount', descending: true)
        .limit(5)
        .get();
    int documentCount = querySnapshot.docs.length;

    return documentCount;
  }

  // 클릭한 게시물의 Firestore 문서 ID 가져오기
  void _navigateToPostDetail(BuildContext context, int postIndex) async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('Product')
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
            builder: (context) => ProductDetail(documentId: documentId),
          ),
        )
            .then((result) async {
          if (result == "1") {
            getBestseller();
            setState(() {});
          }
        });
      }
    }
  }

  Future<void> loadDataInBackground() async {
    try {
      // await getCommentCounts();
      getBestseller();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //     leading: IconButton(
        //   onPressed: () {
        //     print(recommendLength.length);
        //   },
        //   icon: const Icon(Icons.abc),
        // )),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<int>(
                future: getDocumentCountInCollection(), // 문서 개수를 가져오는 비동기 함수 호출
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
                                    .collection('Product')
                                    .orderBy('postNum', descending: true)
                                    .get();
                            print('타일 개수:  ${querySnapshot.docs.length}');
                            getBestseller();
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: recommendTitle.isNotEmpty
                              ? ListView.builder(
                                  itemCount: recommendTitle.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        print('인덱스 : $index');
                                        if (!isNavigatingToDetail) {
                                          isNavigatingToDetail = true;
                                          _navigateToPostDetail(context, index);

                                          Timer(const Duration(seconds: 1), () {
                                            isNavigatingToDetail = false;
                                          });
                                        }
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.all(2.0),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                                        recommendTitle[index],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.03,
                                                      ),
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
                                                        userNames[index],
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.02,
                                                      ),
                                                      Text(
                                                        '조회 ${viewCounts[index]}',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.02,
                                                      ),
                                                      Text(
                                                        dates[index],
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * 0.01,
                                                      ),
                                                      Text(
                                                        times[index],
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
                                                width: width * 0.18,
                                                padding: EdgeInsets.all(
                                                    width * 0.015),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
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
                                                        Text(commentCounts[
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
                                                        Text(recommendCount[
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
              ),
      ),
    );
  }
}

// void _navigateToPostDetail(BuildContext context, int postIndex) {
//   Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => PostDetailPage(postIndex: postIndex),
//     ),
//   );
// }
