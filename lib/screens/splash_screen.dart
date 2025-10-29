import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart'; 

class MySplashScreen extends StatelessWidget {
  const MySplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 250,
      splash: Center( 
        child: Lottie.asset(
          'assets/animations/Pokeball.json',
          fit: BoxFit.contain,
        ),
      ),
      nextScreen: const HomeScreen(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.black,
      duration: 2000,
    );
  }
}