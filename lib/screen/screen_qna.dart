import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QnaScreen extends StatefulWidget {
  const QnaScreen({Key? key}) : super(key: key);

  @override
  State<QnaScreen> createState() => _QnaScreenState();
}

class _QnaScreenState extends State<QnaScreen> {
  final List<bool> _isExpandedList = List.generate(4, (index) => false);

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Q&A",
          style: GoogleFonts.doHyeon(fontSize: 25),
        ),
        backgroundColor: Colors.grey[700],
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            expansionTile(
                "핫딜시대는 무엇을 위한 앱인가요?",
                "우리의 핫딜시대는 정보화시대에 정보수집에 취약한 일부 계층과 알뜰하게 지출하고싶은 사람들을 위해 개발된 최저가 공유앱입니다.",
                0),
            expansionTile(
                "어떤 기능이 준비되어 있나요?",
                "가장 먼저 핫딜시대의 대표기능인 최저가 공유 게시판이 있습니다. 해당 게시판은 종류별로 제품정보를 확인하고 해당 제품을 구매할 수 있는 페이지의 링크를 통해 물품을 구매할 수 있습니다. \n\n두 번째로는 주제에 속박받지않고 유저들끼리 자유롭게 소통할 수 있는 자유게시판이 있습니다.",
                1),
            expansionTile("어떻게 사용하는 건가요?",
                "특별히 정해진 사용법은 없습니다. 설계된 인터페이스에 따라 손쉽게 앱을 사용할 수 있습니다.", 2),
            expansionTile(
                "개인정보 유출은 걱정없나요?",
                "Google의 Firebase 데이터베이스를 사용하여 강력한 수준의 보안을 유지합니다. 앱 설계자도 개인정보를 들여다볼 수 없습니다.",
                3),
          ],
        ),
      ),
    );
  }

  Widget expansionTile(String title, String description, int index) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          color: _isExpandedList[index] ? Colors.grey[700] : null,
        ),
      ),
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpandedList[index] = expanded;
        });
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            description,
            style: const TextStyle(fontSize: 15, height: 1.3),
          ),
        ),
      ],
    );
  }
}
