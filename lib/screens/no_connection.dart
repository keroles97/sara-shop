import 'package:app/providers/language_provider.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoConnection extends StatelessWidget {
  const NoConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/app_icons/no_internet.png',
            height: size.height * .1,
            width: size.height * .1,
          ),
          VerticalSpace(size: size, percentage: .01),
          Text(lang.get('no_connection'),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * .06)),
        ],
      ),
    );
  }
}
