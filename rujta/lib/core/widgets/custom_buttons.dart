import 'package:flutter/material.dart';
import 'package:Rujta/core/utils/size_config.dart';
import 'package:Rujta/core/constants.dart';

class CustomGeneralButton extends StatelessWidget {
  const CustomGeneralButton({super.key, this.text, this.onPressed});

  final String? text;
  final VoidCallback? onPressed; 

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: onPressed,
      child: Container(
        height: 60,
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          color: kMainColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xffffffff),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}