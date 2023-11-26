// import 'package:flutter/foundation.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hot_deal_generation/device_info.dart';
import 'package:hot_deal_generation/main.dart';
import 'package:hot_deal_generation/screen/screen_board.dart';
import 'package:hot_deal_generation/screen/screen_category.dart';
import 'package:hot_deal_generation/screen/screen_community.dart';
import 'package:hot_deal_generation/screen/screen_good_deal_list.dart';
import 'package:hot_deal_generation/screen/screen_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/screen/screen_qna.dart';
import 'package:hot_deal_generation/theme_provider.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged; // Callback function
  const HomeScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  late Stream<User?> authStateChanges;
  bool isDisposed = false;

  late Future<void> userInfoFuture;

  @override
  void initState() {
    super.initState();

    authStateChanges = _authentication.authStateChanges();

    authStateChanges.listen((User? user) {
      if (!isDisposed) {
        setState(() {
          loggedUser = user;
        });
      }
    });

    userInfoFuture = getCurrentUserInfo();
  }

  String currentUserName = '';
  String currentEmail = '';
  String currentUserImage = '';

  Future<void> getCurrentUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();
        if (userData.exists) {
          currentUserName = userData.data()!['userName'];
          currentEmail = userData.data()!['email'];
          currentUserImage = userData.data()!['picked_image'];
        } else {
          print("뭔가 에러가 있는듯?");
        }
      } else {
        print("뭔가 또 문제가있음");
      }
    } on FirebaseException catch (e) {
      print(e);
    }
    setState(() {});
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  int _selectedIndex = 0;

  @override
  void dispose() {
    // 자원 정리 또는 상태 변경 등을 수행
    super.dispose(); // 반드시 호출해야 합니다.
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    // 사용자의 화면 크기에 따른 높이 너비 설정
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // ignore: unused_local_variable
    double height = screenSize.height;
    // 테마에 종속된 위젯 부분을 Consumer로 래핑
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.black,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/logo.png',
                  width: 50,
                  height: 50,
                ),
              ),
              SizedBox(width: width * 0.01),
              Text(
                "Hot-Deal",
                textAlign: TextAlign.left,
                style: GoogleFonts.bebasNeue(fontSize: 30.0),
              ),
            ],
          ),
        ),
        endDrawer: Drawer(
          child: FutureBuilder(
            future: userInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    // 여기서 ThemeProvider에 액세스
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                          ),
                          accountName: currentUserName != ''
                              ? Text(currentUserName)
                              : const Text(
                                  "로그인을 해주세요",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                          accountEmail:
                              currentEmail != '' ? Text(currentEmail) : null,
                          currentAccountPicture: currentUserImage != ''
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(currentUserImage),
                                )
                              : null,
                        ),
                        currentEmail != ''
                            ? ListTile(
                                leading: const Icon(
                                  Icons.thumb_up_alt_rounded,
                                  color: Colors.grey,
                                ),
                                title: const Text(
                                  "굿딜 목록",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const GoodDealListScreen()),
                                  );
                                },
                              )
                            : Container(),
                        SwitchListTile(
                          title: const Text(
                            "다크모드",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          secondary:
                              const Icon(Icons.dark_mode, color: Colors.grey),
                          value: themeProvider.currentTheme == ThemeMode.dark,
                          onChanged: (val) {
                            themeProvider.toggleTheme();
                            widget.onThemeChanged();

                            setState(() {
                              MyApp.themeNotifier.value =
                                  val ? ThemeMode.dark : ThemeMode.light;
                            });
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.question_answer,
                            color: Colors.grey,
                          ),
                          title: const Text("Q&A"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const QnaScreen()),
                            );
                          },
                        ),
                        loggedUser != null
                            ? ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                                title: const Text(
                                  "이메일 문의",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  String body = await getEmailBody();

                                  final Email email = Email(
                                    body: body,
                                    subject: '[핫딜시대 문의]',
                                    recipients: ['kk0@kakao.com'],
                                    cc: [],
                                    bcc: [],
                                    attachmentPaths: [],
                                    isHTML: false,
                                  );

                                  try {
                                    await FlutterEmailSender.send(email);
                                  } catch (e) {
                                    String title =
                                        "기본 메일 앱을 사용할 수 없기 때문에 앱에서 바로 문의를\n\n아래 이메일로 문의주시면 친절하게 답변드리겠습니다.\n\nkk0@kakao.com";
                                    String message = "";
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: Text(title),
                                          content: Text(message),
                                          actions: [
                                            CupertinoDialogAction(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "확인",
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              )
                            : Container(),
                        loggedUser != null
                            ? ListTile(
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.grey,
                                ),
                                title: const Text(
                                  "로그아웃",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pop();
                                },
                              )
                            : ListTile(
                                leading: const Icon(
                                  Icons.login,
                                  color: Colors.grey,
                                ),
                                title: const Text(
                                  "로그인",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const Authentication()),
                                  ).then((result) async {
                                    if (result == "1") {
                                      await getCurrentUserInfo();
                                      setState(() {});
                                    }
                                  });
                                },
                              ),
                      ],
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
        body: _getPage(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            fixedColor: Colors.white,
            unselectedLabelStyle: const TextStyle(
              color: Colors.grey,
            ),
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded),
                label: '카테고리',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add),
                label: '커뮤니티',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

Widget _getPage(int index) {
  switch (index) {
    case 0:
      return const BoardScreen();
    case 1:
      return const CategoryScreen();
    case 2:
      return const CommunityScreen();
    default:
      return const BoardScreen();
  }
}
