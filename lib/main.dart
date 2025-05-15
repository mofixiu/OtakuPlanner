import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/shared/quote_service.dart';
import 'package:provider/provider.dart';
import 'package:splash_view/splash_view.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final notificationService = NotificationService();
  notificationService.registerAsGlobal();
  QuoteService.initializeQuotes();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
      
      scaffoldMessengerKey: rootScaffoldMessengerKey,  
      title: 'Thriller',
      theme: OtakuPlannerTheme.lightTheme,
      darkTheme: OtakuPlannerTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: SplashView(
        logo: Image.asset("assets/images/otaku.jpg"),
        done: Done(Login()),
      ),
      routes: {'/dashboard': (context) => Dashboard()},
    );
  }
}
