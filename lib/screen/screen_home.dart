import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hot_deal_generation/screen/screen_board.dart';
import 'package:hot_deal_generation/screen/screen_category.dart';
import 'package:hot_deal_generation/screen/screen_chatting.dart';
import 'package:hot_deal_generation/screen/screen_community.dart';
import 'package:hot_deal_generation/screen/screen_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 사용자의 화면 크기에 따른 높이 너비 설정
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // ignore: unused_local_variable
    double height = screenSize.height;

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
        body: _getPage(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Add this line
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
                icon: Icon(Icons.local_post_office),
                label: '채팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded),
                label: '카테고리',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add),
                label: '커뮤니티',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: '내정보',
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
      return const ChatScreen();
    case 2:
      return const CategoryScreen();
    case 3:
      return const CommunityScreen();
    default:
      return const ProfileScreen();
  }
}
