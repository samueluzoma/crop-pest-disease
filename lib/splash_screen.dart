
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:crop_pest_insect_detection/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  double opacity = 0.0;
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers (Logic Unchanged)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Setup animations (Logic Unchanged)
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations sequence (Logic Unchanged)
    _startAnimations();

    // Navigate to home page after 5 seconds (Logic Unchanged)
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, Routes.autHomePage);
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        opacity = 1.0;
      });
    }

    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI Theme Update: Agricultural Palette
    const Color primaryGreen = Color(0xff2E7D32);
    const Color accentGreen = Color(0xff81C784);
    const Color backgroundColor = Color(0xffF1F8E9);
    const Color textDark = Color(0xff1B5E20);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffDCEDC8),
              Color(0xffF1F8E9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 800),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// LOGO SECTION (UI Updated)
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(45),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGreen.withOpacity(0.15),
                            blurRadius: 35,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.asset(
                          'assets/images/rice_appicon.jpeg', 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.eco_rounded, size: 85, color: primaryGreen),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TEXT SECTION (UI Updated)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _textAnimation,
                      child: Column(
                        children: [

                          /// APP NAME
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 12),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              "CropPestAI",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// PROJECT TITLE
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 45),
                            child: Text(
                              "Detection & Analysis Crop insect pest",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                color: textDark,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "FUOYE Farmers & Research Project",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textDark.withOpacity(0.7),
                            ),
                          ),

                          const SizedBox(height: 35),

                          /// AUTHOR
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 45),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: primaryGreen.withOpacity(0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGreen.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  "PREPARED BY:",
                                  style: TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.grey,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Omoshalewa Amidat Almoruf",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 45),

                          /// LOADING INDICATOR
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(accentGreen),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            "Initializing Neural Networks...",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: textDark.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}