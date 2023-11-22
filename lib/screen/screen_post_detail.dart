// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

  bool isButtonDisabled = false;

  void enableButton() {
    isButtonDisabled = false;
  }

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  final String documentId;
  static String result = "1";
  double fontSize = 15.0;
  double minSize = 12.0;
  double maxSize = 35.0;

  bool isRecommend = false;

  TextEditingController commentTextController = TextEditingController();

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
  List<String> imageUrls = [];

  String commentText = '';
  DocumentSnapshot? document;
  List<String> commentList = [];

  int numberOfDocument = 0;

  @override
  void initState() {
    super.initState();
    // 게시물 정보를 가져오는 비동기 함수 호출
    getPostDetails();
    getCurrentUser();
    getCommentData();
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
    final mainCollectionRef = FirebaseFirestore.instance
        .collection('BulletinBoard')
        .doc(widget.documentId);

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
          .collection('BulletinBoard')
          .doc(widget.documentId) // documentId 사용
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

          imageUrls = List<String>.from(document!['imageUrls'] ?? []);

          print(imageUrls.length);
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

  addComment() async {
    final currentDocument = FirebaseFirestore.instance
        .collection('BulletinBoard')
        .doc(widget.documentId);

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('BulletinBoard').doc(documentId);
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

  void removePost() async {
    // 현재 사용자 정보 불러오기
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();

    Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;
    String currentUserName = userDataMap['userName'];

    try {
      if (currentUserName == userName) {
        CollectionReference subCollectionRef = FirebaseFirestore.instance
            .collection('BulletinBoard')
            .doc(documentId)
            .collection('comments');

        QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();

        for (QueryDocumentSnapshot doc in subCollectionSnapshot.docs) {
          await subCollectionRef.doc(doc.id).delete();
        }

        await FirebaseFirestore.instance
            .collection('BulletinBoard')
            .doc(documentId)
            .delete()
            .then((value) {
          Fluttertoast.showToast(
            msg: '삭제가 완료됐습니다.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
          Navigator.pop(context, result);
        }).catchError((error) {
          print(error);
        });
      } else {
        Fluttertoast.showToast(
          msg: "본인의 게시물만 삭제할 수 있습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } on FirebaseException catch (e) {
      print(e);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              removePost();
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
                      const PopupMenuItem(
                        child: Text('Item1'),
                      ),
                      const PopupMenuItem(
                        child: Text('Item1'),
                      ),
                      const PopupMenuItem(
                        child: Text('Item1'),
                      ),
                    ]),
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
                            Text(
                              '댓글 $numberOfDocument',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Text(
                              '추천 ${recommendInfo.length}',
                              style: const TextStyle(
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
                                  size: width * 0.055,
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
                                  size: width * 0.055,
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
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.03,
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
                      .collection('BulletinBoard')
                      .doc(widget.documentId);

                  try {
                    if (loggedUser != null) {
                      final user = FirebaseAuth.instance.currentUser;
                      final userData = await FirebaseFirestore.instance
                          .collection('user')
                          .doc(user!.uid)
                          .get();

                      if (userData.exists) {
                        if (!recommendInfo.contains(loggedUser?.email)) {
                          currentDocument.update({
                            'recommendInfo':
                                FieldValue.arrayUnion([loggedUser?.email]),
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
                                        '이미 추천한 글입니다.',
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
                        msg: '로그인 후 추천기능을 이용할 수 있습니다.',
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
                      width: width * 0.01,
                    ),
                    !recommendInfo.contains(loggedUser?.email)
                        ? const Text(
                            '추천',
                            style: TextStyle(fontSize: 15),
                          )
                        : const Text(
                            "추천완료!",
                            style: TextStyle(fontSize: 15),
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
                  color: isDarkMode(context) ? Colors.white : Colors.black,
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
                            color: isDarkMode(context)
                                ? Colors.black
                                : Colors.white,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
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
                child: Column(
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
                        Color textColor = index.isOdd && isDarkMode(context)
                            ? Colors.white
                            : Colors.black;
                        return Container(
                          decoration: BoxDecoration(
                              color: itemColor,
                              border: itemBorder,
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      userNameArr[index],
                                      style: TextStyle(color: textColor),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        String documentIdToDelete =
                                            commentDocIds[index];
                                        try {
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          final currentUserData =
                                              await FirebaseFirestore.instance
                                                  .collection('user')
                                                  .doc(user!.uid)
                                                  .get();

                                          Map<String, dynamic> userDataMap =
                                              currentUserData.data()
                                                  as Map<String, dynamic>;

                                          String currentUserName =
                                              userDataMap['userName'];

                                          CollectionReference mainCollection =
                                              FirebaseFirestore.instance
                                                  .collection('BulletinBoard');

                                          CollectionReference subCollection =
                                              mainCollection
                                                  .doc(documentId)
                                                  .collection('comments');

                                          FirebaseFirestore.instance
                                              .collection('BulletinBoard')
                                              .doc(documentId)
                                              .collection('comments')
                                              .doc(documentIdToDelete)
                                              .get()
                                              .then((DocumentSnapshot doc) {
                                            if (doc.exists) {
                                              Map<String, dynamic> data =
                                                  doc.data()
                                                      as Map<String, dynamic>;
                                              String commentUserName =
                                                  data['userName'];
                                              print(commentUserName);

                                              if (currentUserName ==
                                                  commentUserName) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            const Text(
                                                              '안내',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 19,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  height * 0.03,
                                                            ),
                                                            const Text(
                                                              '댓글을 삭제하시겠습니까?',
                                                              style: TextStyle(
                                                                  fontSize: 17),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    subCollection
                                                                        .doc(
                                                                            documentIdToDelete)
                                                                        .delete()
                                                                        .then(
                                                                            (value) async {
                                                                      Fluttertoast
                                                                          .showToast(
                                                                        msg:
                                                                            '댓글이 삭제됐습니다.',
                                                                        toastLength:
                                                                            Toast.LENGTH_LONG,
                                                                        gravity:
                                                                            ToastGravity.BOTTOM,
                                                                        backgroundColor:
                                                                            Colors.black,
                                                                      );
                                                                      await getCommentData();

                                                                      DocumentReference documentReference = FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'BulletinBoard')
                                                                          .doc(
                                                                              documentId);
                                                                      DocumentSnapshot
                                                                          documentSnapshot =
                                                                          await documentReference
                                                                              .get();

                                                                      int commentCount =
                                                                          documentSnapshot
                                                                              .get('commentCount');
                                                                      int newCommentCount =
                                                                          commentCount -
                                                                              1;

                                                                      await documentReference
                                                                          .update({
                                                                        'commentCount':
                                                                            newCommentCount
                                                                      });

                                                                      setState(
                                                                          () {});
                                                                    }).catchError(
                                                                            (error) {
                                                                      print(
                                                                          '문서 삭제 실패 : $error');
                                                                    });
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    '삭제',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          '닫기'),
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
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Colors.red,
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
                                Text(
                                  commentArr[index],
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
