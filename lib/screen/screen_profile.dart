import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/screen/screen_login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? newUser) {
      if (mounted) {
        setState(() {
          user = newUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: width * 1, // 화면 전체 너비 사용
                    height: height * 0.2, // 화면 전체 높이 사용
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: Center(
                      child: user != null
                          ? Text(
                              "안녕하세요, ${user!.email}님!",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : const Text(
                              "로그인을 해주세요.",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10), // 간격 추가
                  if (user == null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Authentication(),
                          ),
                        );
                      },
                      child: const Text("로그인"),
                    ),
                  if (user != null)
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text("로그아웃"),
                    ),
                  const SizedBox(
                    height: 50,
                  ),
                  if (user != null)
                    SingleChildScrollView(
                      child: InkWell(
                        child: Container(
                          width: width * 0.8,
                          height: height * 0.07,
                          padding: const EdgeInsets.all(12.0),
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide())),
                          child: Text(
                            '프로필 설정',
                            style: GoogleFonts.doHyeon(fontSize: 25),
                          ),
                        ),
                        onTap: () {
                          //
                        },
                      ),
                    ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  // Add more InkWell widgets based on conditions
                  if (user != null)
                    SingleChildScrollView(
                      child: InkWell(
                        child: Container(
                          width: width * 0.8,
                          height: height * 0.07,
                          padding: const EdgeInsets.all(12.0),
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide())),
                          child: Text(
                            '고객센터',
                            style: GoogleFonts.doHyeon(fontSize: 25),
                          ),
                        ),
                        onTap: () {
                          // Handle onTap for this InkWell
                        },
                      ),
                    ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  SingleChildScrollView(
                    child: InkWell(
                      child: Container(
                        width: width * 0.8,
                        height: height * 0.07,
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide())),
                        child: Text(
                          'FAQ',
                          style: GoogleFonts.doHyeon(fontSize: 25),
                        ),
                      ),
                      onTap: () {
                        // Handle onTap for this InkWell
                      },
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
