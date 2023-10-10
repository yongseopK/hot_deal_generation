import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool showSpinner = false;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImgs = [];

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

  String postTitle = '';
  String postText = '';

  @override
  Widget build(BuildContext context) {
    List<Widget> boxContents = [
      IconButton(
        onPressed: () {
          _pickImg();
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
    // 사용자의 화면 크기에 따른 높이 너비 설정
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // ignore: unused_local_variable
    double height = screenSize.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.black,
          title: Row(
            children: [
              Text(
                "글 작성",
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 30.0),
              ),
            ],
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: TextFormField(
                          validator: (val) => val == "" ? "제목을 입력해주세요" : null,
                          onSaved: (value) {
                            postTitle = value!;
                          },
                          onChanged: (value) {
                            postTitle = value;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "제목을 입력해주세요",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                            postText = value!;
                          },
                          onChanged: (value) {
                            postText = value;
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "사진 첨부",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "* 사진은 4장까지 첨부 가능합니다.",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              "* HDR이 적용된 이미지는 삽입할 수 없습니다.",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )
                          ],
                        )
                      ],
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
                    onTap: () async {
                      setState(() {
                        showSpinner = true;
                      });
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
      ),
    );
  }
}
