import 'package:Rujta/features/on_Boarding/presentation/widgets/custom_indicator.dart';
import 'package:Rujta/core/utils/size_config.dart';
import 'package:Rujta/core/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:Rujta/features/on_Boarding/presentation/widgets/custom_page_view.dart';

class OnBoardingViewBody extends StatefulWidget {
  const OnBoardingViewBody({Key? key}) : super(key: key);

  @override
  _OnBoardingViewBodyState createState() => _OnBoardingViewBodyState();
}

class _OnBoardingViewBodyState extends State<OnBoardingViewBody> {
  PageController? pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: 0)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
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
            dotIndex: pageController!.hasClients ? pageController?.page : 0,
          ),
        ),

        Visibility(
          visible: true,
          child: Positioned(
            left: SizeConfig.defaultSize! * 10,
            right: SizeConfig.defaultSize! * 10,
            bottom: SizeConfig.defaultSize! * 10,
            child: CustomGeneralButton(
              text: pageController!.hasClients
                  ? (pageController?.page == 2 ? 'Get started' : 'Next')
                  : 'Next',
            ),
          ),
        ),
      ],
    );
  }
}