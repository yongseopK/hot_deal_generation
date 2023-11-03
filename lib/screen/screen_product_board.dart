import 'package:flutter/material.dart';

class ProductBoard extends StatelessWidget {
  const ProductBoard({Key? key, this.data}) : super(key: key);

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: data == "computer"
            ? const Text("컴퓨터")
            : data == "labtop"
                ? const Text("노트북")
                : data == "mobile"
                    ? const Text("스마트폰")
                    : data == "tablet"
                        ? const Text("태블릿")
                        : data == "wearable"
                            ? const Text("웨어러블")
                            : data == "mouse"
                                ? const Text("마우스")
                                : data == "keyboard"
                                    ? const Text("키보드")
                                    : data == "soundSystem"
                                        ? const Text("음향기기")
                                        : data == "cpu"
                                            ? const Text("CPU")
                                            : data == "gpu"
                                                ? const Text("그래픽 카드")
                                                : data == "ram"
                                                    ? const Text("램")
                                                    : data == "storage"
                                                        ? const Text("저장장치")
                                                        : data == "power"
                                                            ? const Text("파워")
                                                            : data == "case "
                                                                ? const Text(
                                                                    "케이스")
                                                                : null,
      ),
    );
  }
}
