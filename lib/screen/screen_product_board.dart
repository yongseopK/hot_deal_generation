// ignore_for_file: avoid_print, unnecessary_string_interpolations

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hot_deal_generation/screen/screen_add_product.dart';
import 'package:hot_deal_generation/screen/screen_product_detail.dart';
import 'package:intl/intl.dart';

class ProductBoard extends StatefulWidget {
  const ProductBoard({Key? key, this.data, this.title}) : super(key: key);

  final String? data;
  final String? title;

  static const Map<String, String> dataToTitle = {
    "computer": "컴퓨터",
    "labtop": "노트북",
    "mobile": "스마트폰",
    "tablet": "태블릿",
    "wearable": "웨어러블",
    "mouse": "마우스",
    "keyboard": "키보드",
    "soundSystem": "음향기기",
    "cpu": "CPU",
    "gpu": "그래픽 카드",
    "ram": "램",
    "storage": "저장장치",
    "power": "파워",
    "case": "케이스",
  };

  @override
  State<ProductBoard> createState() => _ProductBoardState();
}

class _ProductBoardState extends State<ProductBoard> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? title;

  bool isLoading = false;

  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    title = ProductBoard.dataToTitle[widget.data];
    getDocumentData(title);
  }

  void navigateToAddProduct(String data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProduct(data: data),
      ),
    ).then((result) async {
      if (result == "1") {
        // await getCommentCounts();
        await getDocumentData(title);
        setState(() {});
      }
    });
  }

  int recommendLength = 0;

  bool isNavigatingToDetail = false;

  List<String> productPlatform = [];
  List<String> productTitles = [];
  List<String> productTexts = [];
  List<String> productThumbnails = [];
  List<String> productUserName = [];
  List<String> productTime = [];
  List<String> productDate = [];
  List<String> productViewCount = [];
  List<String> productRecomendCount = [];
  List<String> productCommentCount = [];
  List<String> productLinks = [];
  List<String> productDeliveryFees = [];
  List<String> productPrices = [];
  List<String> productImages = [];

  Future<void> getDocumentData(String? title) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Product')
          .where('category', isEqualTo: title)
          .orderBy('postNum', descending: true)
          .get();

      productImages.clear();
      productPrices.clear();
      productPlatform.clear();
      productTitles.clear();
      productTexts.clear();
      productThumbnails.clear();
      productUserName.clear();
      productTime.clear();
      productDate.clear();
      productViewCount.clear();
      productRecomendCount.clear();
      productCommentCount.clear();
      productLinks.clear();
      productDeliveryFees.clear();
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          String platform = document.get('platform');
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
          String link = document.get('link');
          int deliveryFees = document.get('deliveryFee');
          String parseDeliveryFees = deliveryFees.toString();
          int productPrice = document.get('price');
          String parseProductPrice = productPrice.toString();

          recommendLength = recommend!.length;
          String recommendCount =
              recommend.isNotEmpty ? recommendLength.toString() : "0";

          String image =
              imageUrls != null && imageUrls.isNotEmpty ? imageUrls[0] : '';

          productImages.add(image);
          productPlatform.add(platform);
          productTitles.add(title);
          productTexts.add(text);
          productThumbnails.add(image);
          productUserName.add(userName);
          productTime.add(time);
          productDate.add(date);
          productViewCount.add(parseViewCount);
          productRecomendCount.add(recommendCount);
          productCommentCount.add(parseCommentCount);
          productLinks.add(link);
          productDeliveryFees.add(parseDeliveryFees);
          productPrices.add(parseProductPrice);
        }
      } else {
        print("컬렉션에 문서가 없음");
      }
    } catch (e) {
      print(e);
    }
  }

  // 클릭한 게시물의 Firestore 문서 ID 가져오기
  void _navigateToPostDetail(
      BuildContext context, int postIndex, String? title) async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('Product')
        .where('category', isEqualTo: title)
        .orderBy('postNum', descending: true)
        .get()
        .then((querySnapshot) => querySnapshot.docs[postIndex]);

    if (document.exists) {
      String documentId = document.id;

      // Firestore에서 해당 문서를 가져옵니다.
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Product').doc(documentId);
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
            await getDocumentData(title);
            setState(() {});
          }
        });
      }
    }
  }

  Future<int> getDocumentCountInCollection(String? title) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('Product');

    QuerySnapshot querySnapshot =
        await collectionRef.where("category", isEqualTo: title).get();
    int documentCount = querySnapshot.docs.length;

    return documentCount;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    final title = ProductBoard.dataToTitle[widget.data];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: title != null ? Text(title) : null,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder<int>(
              future:
                  getDocumentCountInCollection(title), // 문서 개수를 가져오는 비동기 함수 호출
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
                          getDocumentData(title);
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: productTitles.isNotEmpty
                            ? ListView.builder(
                                itemCount: productTitles.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      print('인덱스 : $index');
                                      if (!isNavigatingToDetail) {
                                        isNavigatingToDetail = true;
                                        _navigateToPostDetail(
                                            context, index, title);

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
                                                vertical: 5, horizontal: 15),
                                        title: Stack(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '[${productPlatform[index]}]',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: width * 0.01,
                                                        ),
                                                        Text(
                                                          productTitles[index]
                                                                          .length +
                                                                      productPlatform[
                                                                              index]
                                                                          .length >
                                                                  16
                                                              ? '${productTitles[index].substring(0, 16 - productPlatform[index].length)}...'
                                                              : productTitles[
                                                                  index],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.003,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '가격 ',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            isDarkMode(context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
                                                      ),
                                                    ),
                                                    Text(
                                                      '₩${currencyFormat.format(int.parse(productPrices[index]))}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.cyan,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.01,
                                                    ),
                                                    Text(
                                                      '배송비 ',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            isDarkMode(context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
                                                      ),
                                                    ),
                                                    Text(
                                                      productDeliveryFees[
                                                                  index] ==
                                                              '0'
                                                          ? "무료"
                                                          : '₩${currencyFormat.format(int.parse((productDeliveryFees[index])))}',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.003,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      productUserName[index],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            isDarkMode(context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.01,
                                                    ),
                                                    Text(
                                                      productDate[index],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            isDarkMode(context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.01,
                                                    ),
                                                    Text(
                                                      productTime[index],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color:
                                                            isDarkMode(context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.03,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                          size: height * 0.02,
                                                        ),
                                                        Text(
                                                          productViewCount[
                                                              index],
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: isDarkMode(
                                                                    context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
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
                                                          size: height * 0.02,
                                                        ),
                                                        Text(
                                                          productCommentCount[
                                                              index],
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: isDarkMode(
                                                                    context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
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
                                                          size: height * 0.02,
                                                        ),
                                                        Text(
                                                          productRecomendCount[
                                                              index],
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: isDarkMode(
                                                                    context)
                                                                ? null
                                                                : Colors
                                                                    .grey[500],
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
                                              child: productThumbnails[index]
                                                      .isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.network(
                                                        productThumbnails[
                                                            index],
                                                        fit: BoxFit.fitHeight,
                                                        width: width * 0.165,
                                                        height: width * 0.165,
                                                      ),
                                                    )
                                                  : Container(),
                                              // child: Container(
                                              //   color: Colors.black,
                                              //   width: width * 0.17,
                                              //   height: width * 0.17,
                                              // ),
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
                                // child: IconButton(
                                //     onPressed: () async {
                                //       print(title);
                                //       await getDocumentData(title);
                                //       setState(() {});
                                //     },
                                //     icon: const Icon(Icons.abc)),
                              ),
                      ),
                    );
                  }
                }
              },
            ),
      floatingActionButton:
          loggedUser != null ? buildFloatingActionButton(widget.data) : null,
    );
  }

  FloatingActionButton buildFloatingActionButton(String? data) {
    if (data != null) {
      final title = ProductBoard.dataToTitle[data];
      return FloatingActionButton(
        elevation: 0.0,
        onPressed: () {
          if (title != null) {
            navigateToAddProduct(data);
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      );
    }
    return const FloatingActionButton(onPressed: null);
  }
}
