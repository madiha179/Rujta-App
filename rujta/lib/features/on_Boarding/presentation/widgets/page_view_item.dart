import 'package:flutter/material.dart';
import 'package:Rujta/core/utils/size_config.dart';
import 'package:Rujta/core/widgets/space_widget.dart';

class PageViewItem extends StatelessWidget {
  const PageViewItem({super.key, this.title, this.subTitle, this.image});

  final String? title;
  final String? subTitle;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F6F7),
      child: Column(
        children: [
          const VerticalSpace(18),

          SizedBox(
            height: SizeConfig.defaultSize! * 28,
            child: Image.asset(image!),
          ),

          const VerticalSpace(5),

          Text(
            title!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: Color(0xff2f2e41),
              fontWeight: FontWeight.w600,
            ),
          ),

          const VerticalSpace(1),

          Text(
            subTitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Color(0xff78787c),
            ),
          ),
        ],
      ),
    );
  }
}