// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key, this.data}) : super(key: key);

  final dynamic data;

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
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  static String result = "1";

  String _selectedValue = "";
  String productTitle = '';
  String productText = '';
  String productLink = '';
  int? productPrice;
  int? productDeliveryFee;

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
  }

  bool showSpinner = false;
  bool isToastVisible = false;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImgs = [];

  Future<void> checkAndRequestGalleryPermission() async {
    var status = await Permission.photos.status;

    if (status.isGranted) {
      _pickImg();
    } else if (status.isDenied) {
      var result = await Permission.photos.request();

      if (!result.isGranted) {
        _pickImg();
      } else {
        Fluttertoast.showToast(
          msg: "환경설정에서 직접 권한을 허용해주세요",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<int> _getLatestPostNum(String product) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(product)
        .orderBy('postNum', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      int latestPostNum = querySnapshot.docs.first['postNum'];
      return latestPostNum;
    } else {
      return 0; // 컬렉션에 문서가 없을 경우 0 반환
    }
  }

  Future<void> _pickImg() async {
    try {
      List<XFile>? images = await _picker.pickMultiImage();
      // ignore: unnecessary_null_comparison
      if (images != null) {
        setState(() {
          _pickedImgs = images;
        });
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "HDR 이미지는 사용할 수 없습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  void showUploadToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      gravity: ToastGravity.CENTER,
    );
  }

  void showValidateToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
    );
    setState(() {
      showSpinner = false;
    });
  }

  Future<String> _uploadImageToFirebaseStorage(XFile image) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("images/${loggedUser!.uid} ${DateTime.now()}.jpg");
      await storageReference.putFile(File(image.path));
      String imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print("Firebase Storage에 이미지를 업로드하는 동안 오류 발생: $e");
      // 오류를 적절하게 처리하세요.
      return '';
    }
  }

  void uploadPost(String? product) async {
    if (productTitle.isNotEmpty &&
        productText.isNotEmpty &&
        _selectedValue.isNotEmpty &&
        productPrice != 0 &&
        productPrice != null &&
        productDeliveryFee != 0 &&
        productDeliveryFee != null &&
        productLink.isNotEmpty) {
      setState(() {
        showSpinner = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        final userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user!.uid)
            .get();

        List<String> imageUrls = [];

        // 이미지 업로드 및 URL 가져오기
        for (var image in _pickedImgs) {
          String imageUrl = await _uploadImageToFirebaseStorage(image);
          imageUrls.add(imageUrl); // 이미지 URL을 목록에 추가
        }

        // 가장 큰 postNum 값을 가져와서 1을 더한 후 새로운 문서에 부여
        int latestPostNum = await _getLatestPostNum("Product");
        int newPostNum = latestPostNum + 1;

        DateTime dt = DateTime.now();

        // Firestore에 게시물 데이터 추가
        await FirebaseFirestore.instance
            .collection("Product")
            .add({
              'deliveryFee': productDeliveryFee,
              'category': product,
              'platform': _selectedValue,
              'postNum': newPostNum,
              'title': productTitle,
              'text': productText,
              'price': productPrice,
              'link': productLink,
              'userName': userData.data()!['userName'],
              'imageUrls': imageUrls, // 이미지 URL 목록을 추가
              'date': DateFormat('yyyy-MM-dd').format(dt),
              'time': DateFormat('HH:mm').format(dt),
              'viewCount': 0,
              'recommendInfo': [],
              'commentCount': 0
            })
            .then((value) => print("업로드 성공"))
            .catchError((error) => print("알 수 없는 오류 발생"));

        // 이미지 업로드가 완료된 후에만 Toast 메시지를 표시
        if (productTitle.isNotEmpty && !isToastVisible) {
          showUploadToastMessage("게시물 작성이 완료되었습니다.");
          isToastVisible = true;
          // ignore: use_build_context_synchronously
          Navigator.pop(context, result);
        }
      } on FirebaseException catch (e) {
        print(e);
      }
    } else {
      if (productTitle.isEmpty && productText.isEmpty) {
        showValidateToastMessage("제목과 내용을 입력해주세요.");
      } else if (productTitle.isEmpty) {
        showValidateToastMessage("제목을 입력해주세요.");
      } else if (productText.isEmpty) {
        showValidateToastMessage("내용을 입력해주세요.");
      } else if (_selectedValue.isEmpty) {
        showValidateToastMessage("판매처를 선택해주세요.");
      } else if (productPrice == 0 || productPrice == null) {
        showValidateToastMessage("가격을 입력해주세요.");
      } else if (productDeliveryFee == 0 || productDeliveryFee == null) {
        showValidateToastMessage("배송비를 입력해주세요.");
      } else if (productLink.isEmpty) {
        showValidateToastMessage("링크를 입력해주세요.");
      }
      return;
    }
  }

  TextEditingController textController = TextEditingController();
  int maxLength = 500;
  bool isMaxLengthExceeded = false;

  final _valueList = [
    "쿠팡",
    "11번가",
    "G마켓",
    "공식브랜드 홈",
    "티몬",
    "위메프",
    "SSG",
    "Amazon",
    "AliExpress",
    "그 외",
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> boxContents = [
      IconButton(
        onPressed: () {
          checkAndRequestGalleryPermission();
        },
        icon: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
          child: Icon(
            CupertinoIcons.camera,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      Container(),
      Container(),
      _pickedImgs.length <= 4
          ? Container()
          : FittedBox(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle),
                child: Text(
                  '+${(_pickedImgs.length - 4).toString()}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
    ];
    Size screenSize = MediaQuery.of(context).size;
    double height = screenSize.height;
    double width = screenSize.width;
    final title = AddProduct.dataToTitle[widget.data];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.black,
          title: title != null ? Text("$title 게시물 작성") : const Text("값이 없음"),
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: DropdownButton(
                            hint: const Text("판매처"),
                            value: _selectedValue.isNotEmpty
                                ? _selectedValue
                                : null,
                            items: _valueList.map(
                              (value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextFormField(
                        validator: (val) =>
                            val!.trim() == "" ? "제목을 입력해주세요" : null,
                        onSaved: (value) {
                          productTitle = value!;
                        },
                        onChanged: (value) {
                          productTitle = value;
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "제목 또는 상품명을 입력해주세요",
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, width * 0.4, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim() == "" ? "가격을 입력해주세요" : null,
                        onSaved: (value) {
                          productPrice = int.parse(value!);
                        },
                        onChanged: (value) {
                          productPrice = int.parse(value);
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "가격을 입력해주세요 (₩)",
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, width * 0.4, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          productDeliveryFee = int.parse(value!);
                        },
                        onChanged: (value) {
                          productDeliveryFee = int.parse(value);
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "배송비를 입력해주세요 (₩)",
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    height: height * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextFormField(
                        controller: textController,
                        validator: (val) => val == "" ? "내용을 입력해주세요" : null,
                        onSaved: (value) {
                          productText = value!;
                        },
                        onChanged: (value) {
                          productText = value;
                          if (value.length <= maxLength) {
                            setState(() {
                              isMaxLengthExceeded = false;
                            });
                          } else {
                            setState(() {
                              isMaxLengthExceeded = true;
                            });
                          }
                        },
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "내용을 입력해주세요",
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextFormField(
                        validator: (val) => val == "" ? "링크를 입력해주세요" : null,
                        onSaved: (value) {
                          productLink = value!;
                        },
                        onChanged: (value) {
                          productLink = value;
                        },
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "링크를 입력해주세요",
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.115,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    crossAxisCount: 4,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    children: List.generate(
                      4,
                      (index) => DottedBorder(
                        color: Colors.grey,
                        dashPattern: const [3, 3],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        child: Container(
                          decoration: index <= _pickedImgs.length - 1
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(
                                      File(_pickedImgs[index].path),
                                    ),
                                  ),
                                )
                              : null,
                          child: Center(child: boxContents[index]),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showSpinner = true;
                    });
                    switch (title) {
                      case "컴퓨터":
                      case "노트북":
                      case "스마트폰":
                      case "태블릿":
                      case "웨어러블":
                      case "마우스":
                      case "키보드":
                      case "음향기기":
                      case "CPU":
                      case "그래픽 카드":
                      case "램":
                      case "저장장치":
                      case "파워":
                      case "케이스":
                        uploadPost(title);
                        break;
                      default:
                        Fluttertoast.showToast(
                          msg: "잘못된 접근입니다.",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                        );
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text(
                          '게시물 등록',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
}
