import 'package:flutter/material.dart';
import 'package:hot_deal_generation/screen/screen_brard.dart';
import 'package:hot_deal_generation/screen/screen_category.dart';
import 'package:hot_deal_generation/screen/screen_chatting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 사용자의 화면 크기에 따른 높이 너비 설정
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle),
              ),
            ],
            title: Row(
              children: [
                // Add your image asset here
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'images/logo.png',
                      width: width * 0.08,
                      height: height * 0.08,
                    ),
                  ),
                ),
                const Text(
                  "Hot-Deal",
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          body: _getPage(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: '채팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded),
                label: '카테고리',
              )
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
    default:
      return const CategoryScreen();
  }
}
