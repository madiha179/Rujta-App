import 'package:Rujta/features/on_Boarding/presentation/widgets/custom_indicator.dart';
import 'package:Rujta/core/utils/size_config.dart';
import 'package:Rujta/core/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:Rujta/features/on_Boarding/presentation/widgets/custom_page_view.dart';
import 'package:Rujta/Screens/login_screen.dart';
import 'package:get/get.dart';

class OnBoardinViewBody extends StatefulWidget {
  const OnBoardinViewBody({super.key});

  @override
  _OnBoardingViewBodyState createState() => _OnBoardingViewBodyState();
}

class _OnBoardingViewBodyState extends State<OnBoardinViewBody> {
  PageController? pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: 0)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  void _handleButtonPress() {
    final currentPage = pageController?.page?.round() ?? 0;
    if (currentPage == 2) {
      // آخر صفحة — روح للـ Login
      Get.off(() => LoginScreen(), transition: Transition.fade);
    } else {
      // انتقل للصفحة الجاية
      pageController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPageView(
          pageController: pageController,
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: SizeConfig.defaultSize! * 18,
          child: CustomIndicator(
            dotIndex: pageController!.hasClients
                ? (pageController?.page ?? 0)
                : 0,
          ),
        ),

        Positioned(
          left: SizeConfig.defaultSize! * 10,
          right: SizeConfig.defaultSize! * 10,
          bottom: SizeConfig.defaultSize! * 10,
          child: CustomGeneralButton(
            text: pageController!.hasClients
                ? (pageController?.page?.round() == 2 ? 'Get started' : 'Next')
                : 'Next',
            onPressed: _handleButtonPress, // ✅
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }
}