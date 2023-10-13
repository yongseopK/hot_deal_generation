import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hot_deal_generation/screen/screen_post_detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  const Icon(
                    Icons.add_chart,
                    size: 40,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "금주의 Hot Deal",
                    style: GoogleFonts.doHyeon(fontSize: 30),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: Platform.isIOS ? height * 0.735 : height * 0.727,
              child: ListView.builder(
                itemCount: 15, // 게시물 개수에 맞게 조정
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _navigateToPostDetail(context, index);
                    },
                    child: Card(
                      margin: const EdgeInsets.all(2.0),
                      child: ListTile(
                        leading: Image.asset(
                          'images/fifalogo.png', // 게시물 이미지
                          width: width * 0.1,
                          height: height * 0.1,
                          // fit: BoxFit.cover,
                        ),
                        title: Text(
                          '게시물 제목 $index', // 게시물 제목
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          '게시물 내용 $index', // 게시물 내용
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _navigateToPostDetail(BuildContext context, int postIndex) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PostDetailPage(postIndex: postIndex),
    ),
  );
}
