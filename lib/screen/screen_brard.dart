import 'package:flutter/material.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return ListView.builder(
      itemCount: 20, // 게시물 개수에 맞게 조정
      itemBuilder: (context, index) {
        // 각 게시물을 표시하는 ListTile을 생성하여 반환
        return Card(
          margin: const EdgeInsets.all(3.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: SizedBox(
              width: width * 0.15, // 사진의 고정된 가로 너비
              height: height * 0.15, // 사진의 고정된 세로 너비
              child: Image.asset(
                'images/fifalogo.png', // 게시물 이미지
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              '게시물 제목 $index', // 게시물 제목
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '게시물 내용 $index', // 게시물 내용
            ),
          ),
        );
      },
    );
  }
}
