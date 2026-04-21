import 'package:flutter/material.dart';
import 'package:Rujta/features/on_Boarding/presentation/widgets/page_view_item.dart';

class CustomPageView extends StatelessWidget {
  const CustomPageView({super.key,@required this.pageController});
  final PageController? pageController;
  @override
  Widget build(BuildContext context) {
    return PageView(
      
      controller:pageController ,
      children: [

        PageViewItem(
          image: 'images/onboarding1.png',
          title: 'Find Medicines Easily',
          subTitle: 'Search for medicines, compare pharmacy availability',
          
        ),
        
        PageViewItem(
          image: 'images/onboarding2.png',
          title: 'Track Your Orders',
          subTitle: 'Follow your pharmacy orders in real time',
        ),
        PageViewItem(
          image: 'images/onboarding3.png', // fixed
          title: 'Delivery ',
          subTitle: 'Order has arrived at your place',
        ),

      ],
    );
  }
}