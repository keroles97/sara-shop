import 'package:app/models/ad_model.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Carousel extends StatelessWidget {
  Carousel(
      {Key? key,
      required this.list,
      required this.size,
      required this.lang,
      required this.theme})
      : super(key: key);
  final List<AdModel> list;
  final Size size;
  final LanguageProvider lang;
  final ThemeProvider theme;

  final List<String> localList = [
    'assets/carousel_images/carousel0.jpg',
    'assets/carousel_images/carousel1.jpg',
    'assets/carousel_images/carousel2.jpg',
    'assets/carousel_images/carousel3.jpg',
    'assets/carousel_images/carousel4.jpg',
  ];

  List<dynamic> _carouselList() {
    return list.isEmpty ? localList : list;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: size.height * .25,
      floating: false,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return CarouselSlider(
          options: CarouselOptions(
              height: size.height * .3,
              autoPlay: true,
              initialPage: 0,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 1500),
              autoPlayCurve: Curves.easeInOutQuad,
              enableInfiniteScroll: true,
              disableCenter: true,
              viewportFraction: 1),
          items: _carouselList().map((i) {
            return Builder(
              builder: (BuildContext context) {
                return list.isEmpty
                    ? Image.asset(
                        i,
                        fit: BoxFit.cover,
                      )
                    : InkWell(
                        onTap: () {
                          launchUrl(Uri.parse(i.clickedLink!));
                        },
                        child: Image.network(
                          i.publicLink!,
                          fit: BoxFit.cover,
                        ));
              },
            );
          }).toList(),
        );
      }),
    );
  }
}

// FlexibleSpaceBar(
// collapseMode: CollapseMode.parallax,
// background: Image.asset(
// 'assets/app_icons/cover.jpeg',
// fit: BoxFit.cover,
// ),
// )
