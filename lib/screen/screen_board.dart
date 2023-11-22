// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hot_deal_generation/screen/screen_post_detail.dart';
// import 'package:google_fonts/google_fonts.dart';

import 'package:hot_deal_generation/screen/screen_product_detail.dart';
import 'package:intl/intl.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");

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
  List<String> productImages = [];

  void getBestseller() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Product')
          .orderBy('recommendCount', descending: true)
          .limit(10)
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
      productImages.clear();

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

          List<dynamic>? imageUrls = document.get('imageUrls');

          String image =
              imageUrls != null && imageUrls.isNotEmpty ? imageUrls[0] : '';
          productImages.add(image);
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
    print(productImages);
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
        .limit(10)
        .get();
    int documentCount = querySnapshot.docs.length;

    return documentCount;
  }

  // 클릭한 게시물의 Firestore 문서 ID 가져오기
  void _navigateToPostDetail(BuildContext context, int postIndex) async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('Product')
        .orderBy('recommendCount', descending: true)
        .limit(5)
        .get()
        .then((querySnapshot) => querySnapshot.docs[postIndex]);

    if (document.exists) {
      String documentId = document.id;

      // Firestore에서 해당 문서를 가져옵니다.
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Product').doc(documentId);
      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        print("여기 문제인가");

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

  String _truncateText(String category, String title) {
    const int maxLength = 22;
    String combinedText = '[$category] $title';

    if (combinedText.length <= maxLength) {
      return combinedText;
    } else {
      return '${combinedText.substring(0, maxLength)}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<int>(
                future: getDocumentCountInCollection(),
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
                    );
                  } else {
                    if (snapshot.hasError) {
                      return Text('에러 발생: ${snapshot.error}');
                    } else {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_chart_sharp,
                                  size: 28,
                                ),
                                Text(
                                  " 베스트셀러",
                                  style: GoogleFonts.doHyeon(fontSize: 28),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('Product')
                                        .orderBy('postNum', descending: true)
                                        .get();
                                print('타일 개수:  ${querySnapshot.docs.length}');
                                print(productImages.isNotEmpty);
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
                                                vertical: 5,
                                                horizontal: 15,
                                              ),
                                              title: Stack(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            _truncateText(
                                                                categorys[
                                                                    index],
                                                                recommendTitle[
                                                                    index]),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.03,
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            "가격 ",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          Text(
                                                            '₩${currencyFormat.format(int.parse(prices[index]))}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.cyan,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          const Text(
                                                            '배송비 ',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          Text(
                                                            deliveryFees[
                                                                        index] ==
                                                                    '0'
                                                                ? "무료"
                                                                : '₩${currencyFormat.format(int.parse((deliveryFees[index])))}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              // color:
                                                              //     Colors.black,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            userNames[index],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.01,
                                                          ),
                                                          Text(
                                                            dates[index],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.01,
                                                          ),
                                                          Text(
                                                            times[index],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.01,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .remove_red_eye_outlined,
                                                                size: height *
                                                                    0.02,
                                                              ),
                                                              Text(
                                                                viewCounts[
                                                                    index],
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.02,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .chat_bubble_2,
                                                                size: height *
                                                                    0.02,
                                                              ),
                                                              Text(
                                                                commentCounts[
                                                                    index],
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: width * 0.02,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .thumb_up_alt_outlined,
                                                                size: height *
                                                                    0.02,
                                                              ),
                                                              Text(
                                                                recommendCount[
                                                                    index],
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: productImages[index]
                                                            .isNotEmpty
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                Image.network(
                                                              productImages[
                                                                  index],
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              width:
                                                                  width * 0.15,
                                                              height:
                                                                  width * 0.15,
                                                            ),
                                                          )
                                                        : Container(),
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
                          ),
                        ],
                      );
                    }
                  }
                },
              ),
      ),
    );
  }
}
