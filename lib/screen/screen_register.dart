import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

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

  dynamic findUserName;

  String result = "1";

  bool isDarkMode(BuildContext context1) {
    return Theme.of(context1).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            '회원가입',
            style: GoogleFonts.doHyeon(fontSize: 25.0),
          ),
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        backgroundColor:
            isDarkMode(context) ? Colors.grey[800] : Colors.grey[300],
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      size: width * 0.4,
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Text(
                      "회원정보를 입력해주세요!",
                      style: GoogleFonts.doHyeon(fontSize: 30),
                    ),
                    SizedBox(
                      height: height * 0.04,
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
                                color: isDarkMode(context)
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  validator: (val) => val == ""
                                      ? "Please enter username "
                                      : null,
                                  onSaved: (value) {
                                    userName = value!;
                                  },
                                  onChanged: (value) {
                                    userName = value;
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '닉네임',
                                  ),
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
                                color: isDarkMode(context)
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode(context)
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkMode(context)
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  validator: (val) => val == ""
                                      ? "Please enter password"
                                      : null,
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
                        final QuerySnapshot userSnapshot =
                            await FirebaseFirestore.instance
                                .collection('user')
                                .where('userName', isEqualTo: userName)
                                .get();

                        if (userSnapshot.docs.isNotEmpty) {
                          for (final doc in userSnapshot.docs) {
                            findUserName = (doc.data()
                                as Map<String, dynamic>)['userName'];
                          }
                        }

                        setState(() {
                          showSpinner = true;
                        });
                        if (confirmPassword == userPassword) {
                          if (formKey.currentState!.validate()) {
                            // 폼이 유효한지 확인
                            try {
                              if (findUserName != userName) {
                                UserCredential newUser = await FirebaseAuth
                                    .instance
                                    .createUserWithEmailAndPassword(
                                  email: userEmail,
                                  password: userPassword,
                                );

                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(newUser.user!.uid)
                                    .set({
                                  'userName': userName,
                                  'email': userEmail,
                                  'goodDealList': [],
                                });

                                if (newUser.user != null) {
                                  Fluttertoast.showToast(
                                    msg: "회원가입이 완료됐습니다.",
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context, result);
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg: "중복된 이름입니다.",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor: Colors.red,
                                );
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
                              } else if (e.code == "email-already-in-use") {
                                errorMessage = '중복 이메일입니다.';
                              } else {
                                errorMessage = '알 수 없는 이유로 회원가입에 실패했습니다.';
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
                            color: isDarkMode(context)
                                ? Colors.red[900]
                                : Colors.red,
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
      ),
    );
  }
}
