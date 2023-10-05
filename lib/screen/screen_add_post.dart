import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPost extends StatelessWidget {
  const AddPost({super.key});

  @override
  Widget build(BuildContext context) {
    // 사용자의 화면 크기에 따른 높이 너비 설정
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // ignore: unused_local_variable
    double height = screenSize.height;
    return Scaffold(
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
      body: SafeArea(
          child: Container(
        child: const Text(
          '제목',
        ),
      )),
    );
  }
}
