import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryGroup(
                    title: '컴퓨터·노트북·전자기기',
                    categories: [
                      _buildCategory(
                        title: '컴퓨터',
                        imageUrl: 'images/computerImg.png',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '노트북',
                        imageUrl: 'images/laptopImg.jpeg',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '스마트폰',
                        imageUrl: 'images/smartPhoneImg.jpeg',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '태블릿',
                        imageUrl: 'images/dwdqImg.jpeg',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '웨어러블',
                        imageUrl: 'images/wearableImg.png',
                        width: width,
                        height: height,
                      ),
                    ],
                  ),
                  _buildCategoryGroup(
                    title: '컴퓨터 주변기기',
                    categories: [
                      _buildCategory(
                        title: '마우스',
                        imageUrl: 'images/mouse.webp',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '키보드',
                        imageUrl: 'images/keyboardImg.png',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '헤드셋',
                        imageUrl: 'images/headImg.jpeg',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '스피커',
                        imageUrl: 'images/speakerImg.jpeg',
                        width: width,
                        height: height,
                      ),
                    ],
                  ),
                  _buildCategoryGroup(
                    title: '컴퓨터 부품',
                    categories: [
                      _buildCategory(
                        title: 'CPU',
                        imageUrl: 'images/cpuImg.jpeg',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '그래픽 카드',
                        imageUrl: 'images/VGAImg.jpeg',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '램',
                        imageUrl: 'images/ramImg.webp',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '저장장치',
                        imageUrl: 'images/storageImg.webp',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '파워',
                        imageUrl: 'images/powerImg.webp',
                        width: width,
                        height: height,
                      ),
                      _buildCategory(
                        title: '케이스',
                        imageUrl: 'images/caseImg.webp',
                        width: width,
                        height: height,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGroup({
    required String title,
    required List<Widget> categories,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.doHyeon(fontSize: 23),
      ),
      children: [
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          physics: const NeverScrollableScrollPhysics(),
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: category,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategory({
    required String title,
    required String imageUrl,
    required double width,
    required double height,
  }) {
    return Stack(
      alignment: Alignment.bottomCenter, // Align the text to the bottom
      children: [
        Container(
          width: width, // Image's width
          height: height, // Image's height
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imageUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black
                  .withOpacity(0.5), // Text's background color and opacity
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.all(8), // Padding around the text
            child: Text(title,
                textAlign: TextAlign.center, // Center the text horizontally
                style: GoogleFonts.doHyeon(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
