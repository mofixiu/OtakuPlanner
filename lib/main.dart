import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otakuplanner/entryScreens/loginPage.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:splash_view/splash_view.dart';
import 'package:otakuplanner/shared/notifications.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), // Add ThemeProvider
        ChangeNotifierProvider(create: (context) => NotificationService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        canvasColor: Color(0xFF121212),
        primaryColor: Color(0xFFBB86FC),
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        fontFamily: "Poppins",
      ),
      themeMode: themeProvider.themeMode, // Use themeMode from ThemeProvider

      home: SplashView(
        logo: Image.asset("assets/images/otaku.jpg"),
        done: Done(Login()),
      ),
      routes: {'/dashboard': (context) => Dashboard()},
    );
  }
}
