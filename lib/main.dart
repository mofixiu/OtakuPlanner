import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otakuplanner/entryScreens/loginPage.dart';
import 'package:splash_view/splash_view.dart';





void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thriller',

      theme: ThemeData(
        canvasColor: Colors.white,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color.fromRGBO(252, 242, 232, 1),
        fontFamily: "Poppins",
      ),

      
      home: SplashView(
        logo: Image.asset("assets/images/otaku.jpg"),
        done: Done(Login()), 
      ),
    );
  }
}
