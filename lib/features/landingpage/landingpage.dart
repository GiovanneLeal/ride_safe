import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/wallpaper_5.jpg',
              fit: BoxFit.cover,
            ),
          ),

        Positioned.fill(
          child: Container(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.5),
          ),
        ),


          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logos/logotransp2.png',
                  width: 500,
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}