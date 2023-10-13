import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: duplicate_import
import 'package:google_fonts/google_fonts.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hot_deal_generation/add_image/add_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key, this.addImageFunc}) : super(key: key);

  final Function(File pickedImage)? addImageFunc;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var formKey = GlobalKey<FormState>();

  bool showSpinner = false;

  String userName = '';
  String userEmail = '';
  String userPassword = '';
  String confirmPassword = '';

  File? pickedImage;

  void _pickImage() async {
    final imagePicker = ImagePicker();
    try {
      final pickedImageFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 150,
      );
      setState(() {
        if (pickedImageFile != null) {
          pickedImage = File(pickedImageFile.path);
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "HDR 이미지는 사용할 수 없습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
    widget.addImageFunc?.call(pickedImage!);
  }

  Future<void> _editImage() async {
    final imagePicker = ImagePicker();
    try {
      final pickedImageFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 150,
      );
      setState(() {
        if (pickedImageFile != null) {
          pickedImage = File(pickedImageFile.path);
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "HDR 이미지는 사용할 수 없습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
    widget.addImageFunc?.call(pickedImage!);
  }

  void _showEditImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              '프로필 사진 수정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('사진을 수정하겠습니까?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _editImage();
                },
                child: const Text('수정'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // double height = screenSize.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            '회원가입',
            style: GoogleFonts.doHyeon(fontSize: 25.0),
          ),
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        backgroundColor: Colors.grey[300],
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(color: Colors.black, width: 3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100))),
                    child: GestureDetector(
                      onTap: () {
                        if (pickedImage == null) {
                          _pickImage();
                        } else {
                          _showEditImageDialog();
                        }
                      },
                      child: pickedImage == null
                          ? Icon(
                              Icons.supervisor_account,
                              size: width * 0.35,
                            )
                          : CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.blue,
                              backgroundImage: pickedImage != null
                                  ? FileImage(pickedImage!)
                                  : null,
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '프로필 이미지를 선택해주세요',
                    style: GoogleFonts.notoSans(fontSize: 28),
                  ),
                  const Text('* HDR이 적용된 이미지는 사용할 수 없습니다.'),
                  const SizedBox(
                    height: 50,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextFormField(
                                validator: (val) =>
                                    val == "" ? "Please enter username " : null,
                                onSaved: (value) {
                                  userName = value!;
                                },
                                onChanged: (value) {
                                  userName = value;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '이름',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextFormField(
                                validator: (val) =>
                                    val == "" ? "Please enter email" : null,
                                onSaved: (value) {
                                  userEmail = value!;
                                },
                                onChanged: (value) {
                                  userEmail = value;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '이메일',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextFormField(
                                validator: (val) =>
                                    val == "" ? "Please enter password" : null,
                                onSaved: (value) {
                                  userPassword = value!;
                                },
                                onChanged: (value) {
                                  userPassword = value;
                                },
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '비밀번호',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextFormField(
                                validator: (val) =>
                                    val == "" ? "Please enter password" : null,
                                onSaved: (value) {
                                  confirmPassword = value!;
                                },
                                onChanged: (value) {
                                  confirmPassword = value;
                                },
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '비밀번호 확인',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      if (confirmPassword == userPassword) {
                        if (formKey.currentState!.validate()) {
                          if (pickedImage == null) {
                            setState(() {
                              showSpinner = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('please pick your image'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                            return;
                          }
                          // 폼이 유효한지 확인
                          try {
                            UserCredential newUser = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: userEmail,
                              password: userPassword,
                            );

                            final refImage = FirebaseStorage.instance
                                .ref()
                                .child('picked_imaged')
                                .child('${newUser.user!.uid}.png');

                            await refImage.putFile(pickedImage!);
                            final url = await refImage.getDownloadURL();

                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(newUser.user!.uid)
                                .set({
                              'userName': userName,
                              'email': userEmail,
                              'picked_image': url,
                            });
                            if (newUser.user != null) {
                              // ignore: use_build_context_synchronously
                              for (var i = 0; i < 2; i++) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              }
                            }
                            setState(() {
                              showSpinner = false;
                            });
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              showSpinner = false;
                            });
                            String errorMessage = '';
                            if (e.code == "weak-password") {
                              errorMessage = '비밀번호는 6글자 이상으로 설정해주세요.';
                            } else if (e.code == "network-request-failed") {
                              errorMessage = '네트워크 연결에 실패하였습니다.';
                            } else if (e.code == "invalid-email") {
                              errorMessage = '잘못된 이메일 형식입니다.';
                            } else if (e.code == "internal-error") {
                              errorMessage = '잘못된 요청입니다.';
                            } else {
                              errorMessage = '회원가입에 실패했습니다.';
                            }
                            Fluttertoast.showToast(
                              msg: errorMessage,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "비밀번호를 확인해주세요",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '회원가입',
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
