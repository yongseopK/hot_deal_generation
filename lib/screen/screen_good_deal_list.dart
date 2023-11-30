// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/screen/screen_product_detail.dart';
import 'package:intl/intl.dart';

class GoodDealListScreen extends StatefulWidget {
  const GoodDealListScreen({super.key});

  @override
  State<GoodDealListScreen> createState() => _GoodDealListScreenState();
}

class _GoodDealListScreenState extends State<GoodDealListScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser = FirebaseAuth.instance.currentUser;

  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  bool isLoading = true;

  void loadData() async {
    await getDocumentIds();
    await getDocumentData(documentIds);

    setState(() {
      isLoading = false;
    });
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

  List<dynamic> documentIds = [];

  Future<void> getDocumentIds() async {
    documentIds.clear();
    if (loggedUser != null) {
      final user = FirebaseAuth.instance.currentUser;
      try {
        final DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user!.uid)
            .get();

        if (userData.exists) {
          List<dynamic> goodDealList = userData['goodDealList'] ?? [];
          documentIds.addAll(goodDealList);
        } else {
          print('문서가 없음');
        }
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    }
  }

  int recommendLength = 0;

  Future<void> getDocumentData(List<dynamic> documentIds) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Product');

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

    for (String documentId in documentIds) {
      DocumentSnapshot document = await collection.doc(documentId).get();

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
  }

  // 클릭한 게시물의 Firestore 문서 ID 가져오기
  // ignore: unused_element
  void _navigateToPostDetail(BuildContext context, int postIndex) async {
    String documentId = documentIds[postIndex];

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('Product').doc(documentId);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      int currentViewCount = documentSnapshot.get('viewCount') ?? 0;
      int newViewCount = currentViewCount + 1;

      await documentReference.update({'viewCount': newViewCount});

      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => ProductDetail(documentId: documentId),
        ),
      )
          .then((result) async {
        if (result == "1") {
          // Reload data after returning from the detail page
          loadData();
          setState(() {});
        }
      });
    }
  }

  bool isNavigatingToDetail = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "굿딜목록",
          style: GoogleFonts.doHyeon(fontSize: 25),
        ),
        elevation: 0.0,
        backgroundColor: Colors.grey[700],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : productTitles.isNotEmpty
              ? ListView.builder(
                  itemCount: productPlatform.length,
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          title: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '[${productPlatform[index]}]',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                          Text(
                                            productTitles[index].length +
                                                        productPlatform[index]
                                                            .length >
                                                    16
                                                ? '${productTitles[index].substring(0, 16 - productPlatform[index].length)}...'
                                                : productTitles[index],
                                            style: const TextStyle(
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
                                          color: isDarkMode(context)
                                              ? null
                                              : Colors.grey[500],
                                        ),
                                      ),
                                      Text(
                                        '₩${currencyFormat.format(int.parse(productPrices[index]))}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.cyan,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      Text(
                                        '배송비 ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isDarkMode(context)
                                              ? null
                                              : Colors.grey[500],
                                        ),
                                      ),
                                      Text(
                                        productDeliveryFees[index] == '0'
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
                                          color: isDarkMode(context)
                                              ? null
                                              : Colors.grey[500],
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      Text(
                                        productDate[index],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isDarkMode(context)
                                              ? null
                                              : Colors.grey[500],
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      Text(
                                        productTime[index],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isDarkMode(context)
                                              ? null
                                              : Colors.grey[500],
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.03,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: height * 0.02,
                                          ),
                                          Text(
                                            productViewCount[index],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isDarkMode(context)
                                                  ? null
                                                  : Colors.grey[500],
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
                                            CupertinoIcons.chat_bubble_2,
                                            size: height * 0.02,
                                          ),
                                          Text(
                                            productCommentCount[index],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isDarkMode(context)
                                                  ? null
                                                  : Colors.grey[500],
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
                                            Icons.thumb_up_alt_outlined,
                                            size: height * 0.02,
                                          ),
                                          Text(
                                            productRecomendCount[index],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isDarkMode(context)
                                                  ? null
                                                  : Colors.grey[500],
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
                                child: productThumbnails[index].isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          productThumbnails[index],
                                          fit: BoxFit.fitHeight,
                                          width: width * 0.165,
                                          height: width * 0.165,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          'images/no_img.jpg',
                                          fit: BoxFit.fitHeight,
                                          width: width * 0.165,
                                          height: width * 0.165,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    "굿딜 목록이 비어있습니다!",
                    style: GoogleFonts.doHyeon(fontSize: 30),
                  ),
                ),
    );
  }
}
