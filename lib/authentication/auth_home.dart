
//Rice
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crop_pest_insect_detection/routes/routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ----- DATA MODEL -----
class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

// ----- MAIN WIDGET -----
class AuthHome extends StatefulWidget {
  const AuthHome({super.key});

  @override
  State<AuthHome> createState() => _AuthHomeState();
}

class _AuthHomeState extends State<AuthHome> {
  // Refined for Cassava Disease Context
  // final List<Slide> slides = [
  //   Slide(
  //     imageUrl: 'assets/rice_appicon.jpeg',
  //     title: 'Identify Cassava\nDiseases Instantly',
  //     description:
  //         'Scan leaves to detect CBB, CBSD, CGM, or Mosaic Disease (CMD) with high-precision AI models.',
  //   ),
  //   Slide(
  //     imageUrl: 'assets/rice_auth1.jpeg',
  //     title: 'Protect Your\nCassava Yield',
  //     description:
  //         'Early detection of Brown Streak and Bacterial Blight helps you take action before the infection spreads.',
  //   ),
  //   Slide(
  //     imageUrl: 'assets/rice_auth2.jpeg',
  //     title: 'Maintain Healthy\nPlantations',
  //     description:
  //         'Get expert insights on maintaining healthy crops and managing disease outbreaks effectively.',
  //   )
  // ];
  final List<Slide> slides = [
    Slide(
      imageUrl: 'assets/rice model/rice_appicon.jpeg',
      title: 'Identify Rice\nDiseases Instantly',
      description:
          'Scan rice leaves to detect Bacterial Leaf Blight, Brown Spot, Leaf Blast, Leaf Scald, or Sheath Blight using high-precision AI.',
    ),
    Slide(
      imageUrl: 'assets/rice model/rice_auth1.jpeg',
      title: 'Protect Your\nRice Yield',
      description:
          'Early detection of Leaf Blast and Bacterial Leaf Blight helps you take action before diseases spread across your farm.',
    ),
    Slide(
      imageUrl: 'assets/rice model/rice_auth2.jpeg',
      title: 'Maintain Healthy\nRice Fields',
      description:
          'Get expert guidance on keeping your rice crops healthy and managing disease outbreaks effectively.',
    )
  ];

  late PageController _pageController;
  late Timer _timer;
  final int _slideDuration = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(Duration(seconds: _slideDuration), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage == slides.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: slides.length,
        itemBuilder: (context, index) {
          return SlideItem(
            slide: slides[index],
            pageController: _pageController,
            slideCount: slides.length,
          );
        },
      ),
    );
  }
}

class SlideItem extends StatelessWidget {
  final Slide slide;
  final PageController pageController;
  final int slideCount;

  const SlideItem({
    super.key,
    required this.slide,
    required this.pageController,
    required this.slideCount,
  });

  @override
  Widget build(BuildContext context) {
    // Intuitive Agricultural Palette
    const Color primaryGreen = Color(0xff2E7D32); // Deep Forest Green
    const Color accentGreen = Color(0xff81C784); // Fresh Leaf Green
    const Color backgroundColor = Color(0xffF1F8E9); // Very Light Green Tint

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// TOP BRAND SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryGreen, accentGreen],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded, // Leaf/Nature icon
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "RiceHealth",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: primaryGreen,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 35),

              /// IMAGE PREVIEW
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    slide.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              /// TITLE
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Color(0xff212121),
                ),
              ),

              const SizedBox(height: 16),

              /// DESCRIPTION
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),

              const Spacer(),

              /// PAGE INDICATOR
              SmoothPageIndicator(
                controller: pageController,
                count: slideCount,
                effect: ExpandingDotsEffect(
                  activeDotColor: primaryGreen,
                  dotColor: primaryGreen.withOpacity(0.2),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),

              const SizedBox(height: 30),

              // /// PRIMARY BUTTON
              // SizedBox(
              //   width: double.infinity,
              //   height: 56,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: primaryGreen,
              //       foregroundColor: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //       elevation: 2,
              //     ),
              //     onPressed: () {
              //       // Action for Sign In
              //       Navigator.pushNamed(context, Routes.login);
              //     },
              //     child: const Text(
              //       "Get Started",
              //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //     ),
              //   ),
              // ),

  

              const SizedBox(height: 10),

              /// GUEST ACCESS
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Routes.dashboard);
                },
                child: Text(
                  "Continue as Guest",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
