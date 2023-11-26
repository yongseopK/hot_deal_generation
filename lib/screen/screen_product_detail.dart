// ignore_for_file: no_logic_in_create_state, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/functions/image_save.dart';
import 'package:hot_deal_generation/functions/post_func.dart';
import 'package:hot_deal_generation/widget/widget_comment.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key, required this.documentId}) : super(key: key);

  final String documentId;
  @override
  State<ProductDetail> createState() =>
      _ProductDetailState(documentId: documentId);
}

class _ProductDetailState extends State<ProductDetail> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser = FirebaseAuth.instance.currentUser;

  final String documentId;
  static String result = "1";

  final NumberFormat currencyFormat = NumberFormat("#,##0", "en_US");

  String nonAllProperties = "https://www.";
  String nonHttp = "https://";

  bool isButtonDisabled = false;

  bool isLogin = false;

  TextEditingController commentTextController = TextEditingController();
  void enableButton() {
    isButtonDisabled = false;
  }

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  String title = '';
  String text = '';
  String image = '';
  String userName = '';
  String date = '';
  String time = '';
  String platform = '';

  int intViewCount = 0;
  String viewCount = '';
  List<String> recommendInfo = [];
  List<String> imageUrls = [];

  int intPrice = 0;
  int price = 0;

  int intdeliveryFee = 0;
  int deleveryFee = 0;

  String productLink = '';

  String commentText = '';
  DocumentSnapshot? document;
  List<String> commentList = [];

  int numberOfDocument = 0;

  bool isRecommend = false;

  _ProductDetailState({required this.documentId});

  @override
  void initState() {
    super.initState();
    getPostDetails();
    getCurrentUser();
    getCommentData();
    print(title);
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        setState(() {
          isLogin = true;
        });

        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  List<String> documentComment = [];
  List<String> documentDateTime = [];
  List<String> documentUserName = [];

  List<String> commentArr = [];
  List<String> commentDocIds = [];
  List<String> userNameArr = [];
  List<String> dateTimeArr = [];

  Future<void> getCommentData() async {
    // 메인 컬렉션의 현재 문서정보 가져오기
    final mainCollectionRef =
        FirebaseFirestore.instance.collection('Product').doc(widget.documentId);

    final commentCollectionRef = mainCollectionRef.collection('comments');

    QuerySnapshot snapshot =
        await commentCollectionRef.orderBy('dateTime', descending: false).get();

    commentArr.clear();
    commentDocIds.clear();
    userNameArr.clear();
    dateTimeArr.clear();

    for (QueryDocumentSnapshot document in snapshot.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      commentArr.add(data['comment']);
      commentDocIds.add(document.id);
      userNameArr.add(data['userName']);
      dateTimeArr.add(data['dateTime']);

      // 여기에서 필요한 데이터를 추출하여 출력하거나 처리할 수 있습니다.
    }

    numberOfDocument = snapshot.size;

    print("문서 개수 : $numberOfDocument");
  }

  Future<void> getPostDetails() async {
    try {
      document = await FirebaseFirestore.instance
          .collection('Product')
          .doc(widget.documentId)
          .get();

      if (document!.exists) {
        final dynamic rawData = document!['recommendInfo'];
        recommendInfo = List<String>.from(rawData ?? []);
        setState(() {
          title = document?['title'];
          text = document?['text'];
          image = document?['imageUrls'] != null &&
                  document!['imageUrls'].isNotEmpty
              ? document!['imageUrls'][0]
              : '';
          userName = document?['userName'];
          date = document?['date'];
          time = document?['time'];
          intViewCount = document?['viewCount'];
          viewCount = intViewCount.toString();
          platform = document?['platform'];

          price = document?['price'];
          deleveryFee = document?['deliveryFee'];

          productLink = document?['link'];

          imageUrls = List<String>.from(document!['imageUrls'] ?? []);

          print(platform);
        });
      } else {
        print('게시물을 찾을 수 없습니다.');
      }
    } on FirebaseAuthException catch (e) {
      print('게시물 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
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
          title: Text(
            title,
            style: GoogleFonts.doHyeon(fontSize: 25),
          ),
          actions: loggedUser != null
              ? [
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(
                          '게시물 삭제',
                          style: GoogleFonts.nanumGothic(fontSize: 15),
                        ),
                        onTap: () {
                          showRemovePostDialog(context, height, userName,
                              documentId, result, 'Product');
                        },
                      )
                    ],
                  ),
                ]
              : [],
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      '[$platform] $title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '작성자 : $userName',
                      style: TextStyle(
                        color: isDarkMode(context) ? null : Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            color:
                                isDarkMode(context) ? null : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          time,
                          style: TextStyle(
                            color:
                                isDarkMode(context) ? null : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '조회 $viewCount',
                      style: TextStyle(
                        color: isDarkMode(context) ? null : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '댓글 $numberOfDocument',
                      style: TextStyle(
                        color: isDarkMode(context) ? null : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '추천 ${recommendInfo.length}',
                      style: TextStyle(
                        color: isDarkMode(context) ? null : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                // const Divider(
                //   color: Colors.black,
                // ),
                buildInfoRow('판매처', platform == "공식홈" ? "공식브랜드 홈" : platform),
                Divider(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
                buildInfoRow('가격', '${currencyFormat.format(price)}원'),
                Divider(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
                buildInfoRow('배송비', '${currencyFormat.format(deleveryFee)}원'),
                Divider(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
                buildLinkRow('링크', productLink),
                Divider(
                  color: isDarkMode(context) ? Colors.white : Colors.black,
                ),
                if (imageUrls.length == 1)
                  Column(
                    children: [
                      SaveImageDialog(context, imageUrls, 0),
                    ],
                  )
                else if (imageUrls.length == 2)
                  Column(
                    children: [
                      SaveImageDialog(context, imageUrls, 0),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      SaveImageDialog(context, imageUrls, 1),
                    ],
                  )
                else if (imageUrls.length == 3)
                  Column(
                    children: [
                      SaveImageDialog(context, imageUrls, 0),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      SaveImageDialog(context, imageUrls, 1),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      SaveImageDialog(context, imageUrls, 2),
                    ],
                  )
                else if (imageUrls.length == 4)
                  Column(
                    children: [
                      SaveImageDialog(context, imageUrls, 0),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      SaveImageDialog(context, imageUrls, 1),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      SaveImageDialog(context, imageUrls, 2),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      SaveImageDialog(context, imageUrls, 3),
                    ],
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        text,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !recommendInfo.contains(loggedUser?.email)
                        ? Colors.white
                        : Colors.black,
                    foregroundColor: !recommendInfo.contains(loggedUser?.email)
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
                        .collection('Product')
                        .doc(widget.documentId);

                    DocumentSnapshot documentSnapshot =
                        await currentDocument.get();

                    try {
                      if (loggedUser != null) {
                        final user = FirebaseAuth.instance.currentUser;

                        final userData = await FirebaseFirestore.instance
                            .collection('user')
                            .doc(user!.uid)
                            .get();

                        if (userData.exists) {
                          if (!recommendInfo.contains(loggedUser?.email)) {
                            int currentRecommendCount =
                                documentSnapshot.get('recommendCount') ?? 0;
                            int newRecommendCount = currentRecommendCount + 1;

                            await currentDocument.update({
                              'recommendInfo':
                                  FieldValue.arrayUnion([loggedUser?.email]),
                              'recommendCount': newRecommendCount,
                            });

                            List<dynamic> currentGoodDealList =
                                userData['goodDealList'] ?? [];

                            currentGoodDealList.add(documentId);

                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(user.uid)
                                .update({'goodDealList': currentGoodDealList});

                            isRecommend = true;

                            Fluttertoast.showToast(
                              msg: '굿딜하셨습니다.',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                            );
                            getPostDetails();
                          } else {
                            Platform.isAndroid
                                ?
                                //ignore: use_build_context_synchronously
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        title: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text("안내"),
                                          ],
                                        ),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("이미 굿딜한 게시물입니다."),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("확인"),
                                          )
                                        ],
                                      );
                                    },
                                  )
                                // ignore: use_build_context_synchronously
                                : showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: const Text("안내"),
                                        content: const Text("이미 굿딜한 게시물입니다."),
                                        actions: [
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("닫기"),
                                          )
                                        ],
                                      );
                                    });
                          }
                        } else {
                          print('사용자 데이터를 찾을 수 없음');
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: '로그인 후 굿딜기능을 이용할 수 있습니다.',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    } on FirebaseException catch (e) {
                      print(e);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      !recommendInfo.contains(loggedUser?.email)
                          ? const Icon(
                              Icons.thumb_up_alt_outlined,
                            )
                          : const Icon(
                              Icons.thumb_up_alt_rounded,
                            ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      recommendInfo.contains(loggedUser?.email)
                          ? const Text(
                              '굿딜완료!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              '굿 딜',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Container(
                    height: 0.3,
                    color: isDarkMode(context) ? Colors.white : Colors.black,
                  ),
                ),
                commentFormField(
                  isLogin: isLogin,
                  loggedUser: loggedUser,
                  widget: widget,
                  documentId: documentId,
                  getCommentData: () => getCommentData(),
                  commentTextController: commentTextController,
                  commentText: commentText,
                  setStateCallback: (VoidCallback callback) {
                    setState(() {});
                  },
                  collectionName: 'Product',
                  isDarkMode: () => isDarkMode(context),
                  context: context,
                  height: height,
                  isButtonDisabled: isButtonDisabled,
                  enableButton: () => enableButton(),
                ),
                showComment(
                  commentArr: commentArr,
                  numberOfDocument: numberOfDocument,
                  isDarkMode: () => isDarkMode(context),
                  context: context,
                  userNameArr: userNameArr,
                  commentDocIds: commentDocIds,
                  documentId: documentId,
                  height: height,
                  getCommentData: getCommentData,
                  setStateCallback: (VoidCallback callback) {
                    setState(() {});
                  },
                  dateTimeArr: dateTimeArr,
                  collectionName: 'Product',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    Size screenSize = MediaQuery.of(context).size;
    double height = screenSize.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.001),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value == '0원' ? '무료배송' : value,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLinkRow(String label, String link) {
    Size screenSize = MediaQuery.of(context).size;
    double height = screenSize.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.001),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                tooltip(),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              child: Text(
                link,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () async {
                print(link);
                final url = Uri.parse(link);
                if (await canLaunchUrl(url)) {
                  launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget tooltip() {
  return const Tooltip(
    message: "도메인을 꼭 확인하고 접속해주세요",
    child: Icon(
      Icons.warning_amber_rounded,
      size: 20,
      color: Colors.red,
    ),
  );
}
