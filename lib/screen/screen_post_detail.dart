import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postIndex});
  final int postIndex;

  @override
  Widget build(BuildContext context) {
    // 게시물 내용을 postIndex를 사용하여 가져와서 표시합니다.
    // 예: 게시물 제목과 내용을 표시하는 Text 위젯을 사용합니다.
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 상세 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('게시물 제목 $postIndex'),
            Text('게시물 내용 $postIndex'),
          ],
        ),
      ),
    );
  }
}
