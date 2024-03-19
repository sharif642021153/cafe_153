import 'package:crud_153/page/login.dart';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crud 153',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FlutterSplashScreen.scale(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 224, 183, 93)
            ],
          ),
          childWidget: SizedBox(
            height: 200,
            child: Image.asset("assets/images/tea.png"),
          ),
          duration: const Duration(milliseconds: 1500),
          animationDuration: const Duration(milliseconds: 1000),
          onAnimationEnd: () => debugPrint("On Scale End"),
          nextScreen: const LoginScreen(),
        ),
    );
  }
}
