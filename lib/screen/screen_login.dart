// import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/screen/screen_register.dart';
import 'package:hot_deal_generation/screen/screen_reset_password.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  var formKey = GlobalKey<FormState>();

  bool showSpinner = false;

  String userEmail = '';
  String userPassword = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            '로그인',
            style: GoogleFonts.doHyeon(fontSize: 25.0),
          ),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.grey[300],
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Hello',
                      style: GoogleFonts.bebasNeue(fontSize: 36.0),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextFormField(
                                  // controller: emailController,
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
                                      hintText: '이메일'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextFormField(
                                  // controller: passwordController,
                                  validator: (val) => val == ""
                                      ? "Please enter password"
                                      : null,
                                  onSaved: (value) {
                                    userPassword = value!;
                                  },
                                  onChanged: (value) {
                                    userPassword = value;
                                  },
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '비밀번호'),
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
                        if (formKey.currentState!.validate()) {
                          try {
                            final newUser = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: userEmail, password: userPassword);
                            if (newUser.user != null) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                            setState(() {
                              showSpinner = false;
                            });
                          } on FirebaseAuthException catch (e) {
                            String errorMessage = '';
                            if (e.code == "wrong-password" ||
                                e.code == "user-not-found") {
                              errorMessage = '이메일 혹은 비밀번호가 잘못됐습니다.';
                            } else if (e.code == "network-request-failed") {
                              errorMessage = '네트워크 연결에 실패하였습니다.';
                            } else if (e.code == "invalid-email") {
                              errorMessage = '잘못된 이메일 형식입니다.';
                            } else if (e.code == "internal-error") {
                              errorMessage = '잘못된 요청입니다.';
                            } else {
                              errorMessage = '로그인에 실패했습니다.';
                            }
                            Fluttertoast.showToast(
                              msg: errorMessage,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Text(
                              '로그인',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() => const RegisterScreen()),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () =>
                              Get.to(() => const ResetPasswordScreen()),
                          child: const Text(
                            '비밀번호 재설정',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
