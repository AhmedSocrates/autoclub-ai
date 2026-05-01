import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        shape: BoxShape.circle,

      ),
      child: Center(
        child: Image(image: AssetImage(
          "assets/images/teknomarin_logo.png",
        ),
        // height: 80,
        width: 70,
        ),
      ),
    );
  }
}