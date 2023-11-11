// ignore_for_file: no_logic_in_create_state

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  TextEditingController commentTextController = TextEditingController();
  void enableButton() {
    isButtonDisabled = false;
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

  addComment() async {
    final currentDocument =
        FirebaseFirestore.instance.collection('Product').doc(widget.documentId);

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('Product').doc(documentId);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    try {
      if (loggedUser != null) {
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

        setState(() {});
      }
    } on FirebaseException catch (e) {
      print(e);
    }
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
          title: Text(title),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(
                    '게시물 삭제',
                    style: GoogleFonts.nanumGothic(fontSize: 15),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  '안내',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                const Text(
                                  '게시물을 삭제하시겠습니까?',
                                  style: TextStyle(fontSize: 17),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // removePost();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        '삭제',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('닫기'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text('플랫폼'),
                  onTap: () {
                    print(intPrice);
                  },
                ),
                const PopupMenuItem(
                  child: Text('Item1'),
                ),
                const PopupMenuItem(
                  child: Text('Item1'),
                ),
              ],
            ),
          ],
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
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('작성자 : $userName'),
                    Row(
                      children: [
                        Text(date),
                        const SizedBox(width: 5),
                        Text(time),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('조회 $viewCount'),
                    const SizedBox(width: 10),
                    Text('댓글 $numberOfDocument'),
                    const SizedBox(width: 10),
                    Text('추천 ${recommendInfo.length}'),
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
                const Divider(
                  color: Colors.black,
                ),
                buildInfoRow('가격', '${currencyFormat.format(price)}원'),
                const Divider(
                  color: Colors.black,
                ),
                buildInfoRow('배송비', '${currencyFormat.format(deleveryFee)}원'),
                const Divider(
                  color: Colors.black,
                ),
                buildLinkRow('링크', productLink),
                const Divider(
                  color: Colors.black,
                ),
                if (imageUrls.length == 1)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[0]),
                      ),
                    ],
                  )
                else if (imageUrls.length == 2)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[0]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[1]),
                      ),
                    ],
                  )
                else if (imageUrls.length == 3)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[0]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[1]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[2]),
                      ),
                    ],
                  )
                else if (imageUrls.length == 4)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[0]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[1]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[2]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrls[3]),
                      ),
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
                            isRecommend = true;

                            Fluttertoast.showToast(
                              msg: '굿딜하셨습니다.',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                            );
                            getPostDetails();
                          } else {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Text(
                                          '안내',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.03,
                                        ),
                                        const Text(
                                          '이미 굿딜한 글입니다.',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('닫기'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
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
                      const Text(
                        '굿 딜!',
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
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: TextFormField(
                                validator: (val) =>
                                    val == "" ? "댓글을 입력해주세요" : null,
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
                            if (isButtonDisabled) {
                              return;
                            }
                            if (loggedUser != null) {
                              if (commentText.length >= 3) {
                                setState(() {
                                  isButtonDisabled = true;
                                });
                                addComment();

                                Timer(const Duration(seconds: 1), enableButton);
                              } else {
                                Fluttertoast.showToast(
                                  msg: "3글자 이상 입력해주세요",
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                );
                              }
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
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: commentArr.isNotEmpty
                      ? Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: numberOfDocument,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                // 홀수 인덱스이면 회색, 짝수 인덱스이면 흰색 배경
                                Color itemColor = index.isOdd
                                    ? Colors.transparent
                                    : Colors.grey.shade200;
                                Border? itemBorder = index.isOdd
                                    ? Border.all(color: Colors.grey.shade200)
                                    : null;
                                return Container(
                                  decoration: BoxDecoration(
                                      color: itemColor,
                                      border: itemBorder,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              userNameArr[index],
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                String documentIdToDelete =
                                                    commentDocIds[index];
                                                try {
                                                  final user = FirebaseAuth
                                                      .instance.currentUser;
                                                  final currentUserData =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('user')
                                                          .doc(user!.uid)
                                                          .get();

                                                  Map<String, dynamic>
                                                      userDataMap =
                                                      currentUserData.data()
                                                          as Map<String,
                                                              dynamic>;

                                                  String currentUserName =
                                                      userDataMap['userName'];

                                                  CollectionReference
                                                      mainCollection =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'Product');

                                                  CollectionReference
                                                      subCollection =
                                                      mainCollection
                                                          .doc(documentId)
                                                          .collection(
                                                              'comments');

                                                  FirebaseFirestore.instance
                                                      .collection('Product')
                                                      .doc(documentId)
                                                      .collection('comments')
                                                      .doc(documentIdToDelete)
                                                      .get()
                                                      .then((DocumentSnapshot
                                                          doc) {
                                                    if (doc.exists) {
                                                      Map<String, dynamic>
                                                          data = doc.data()
                                                              as Map<String,
                                                                  dynamic>;
                                                      String commentUserName =
                                                          data['userName'];
                                                      print(commentUserName);

                                                      if (currentUserName ==
                                                          commentUserName) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Dialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: <Widget>[
                                                                    const Text(
                                                                      '안내',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            19,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          height *
                                                                              0.03,
                                                                    ),
                                                                    const Text(
                                                                      '댓글을 삭제하시겠습니까?',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            16),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            subCollection.doc(documentIdToDelete).delete().then((value) async {
                                                                              Fluttertoast.showToast(
                                                                                msg: '댓글이 삭제됐습니다.',
                                                                                toastLength: Toast.LENGTH_LONG,
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                backgroundColor: Colors.black,
                                                                              );
                                                                              await getCommentData();

                                                                              DocumentReference documentReference = FirebaseFirestore.instance.collection('Product').doc(documentId);
                                                                              DocumentSnapshot documentSnapshot = await documentReference.get();

                                                                              int commentCount = documentSnapshot.get('commentCount');
                                                                              int newCommentCount = commentCount - 1;

                                                                              await documentReference.update({
                                                                                'commentCount': newCommentCount
                                                                              });

                                                                              setState(() {});
                                                                            }).catchError((error) {
                                                                              print('문서 삭제 실패 : $error');
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            '삭제',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.red,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text('닫기'),
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
                                                          msg:
                                                              "본인이 작성한 댓글만 삭제할 수 있습니다.",
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          backgroundColor:
                                                              Colors.red,
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
                                        Text(commentArr[index]),
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
                ),
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
