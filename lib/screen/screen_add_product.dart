// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
  String productTitle = '';
  String productText = '';
  String productLink = '';
  int productPrice = 0;
  String _selectedValue = "";

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
        body: SingleChildScrollView(
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
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: DropdownButton(
                          hint: const Text("판매처"),
                          value:
                              _selectedValue.isNotEmpty ? _selectedValue : null,
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
                padding: EdgeInsets.fromLTRB(10, 0, width * 0.45, 10),
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
                        productTitle = value!;
                      },
                      onChanged: (value) {
                        productTitle = value;
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
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Container(
                  height: height * 0.3,
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
                  print(
                      "\n판매 : $_selectedValue \n제목 : $productTitle \n내용 : $productText\n링크 : $productLink\n가격 : $productPrice");
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
    );
  }
}
