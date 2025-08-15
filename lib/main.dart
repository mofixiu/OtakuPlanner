import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/shared/quote_service.dart';
import 'package:otakuplanner/widgets/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Hive
  await Hive.initFlutter();
  await initRequestService(); 
  
  // Initialize UserProvider early
  final userProvider = UserProvider();
  await userProvider.initHive();
  
  // Initialize app services
  final notificationService = NotificationService();
  notificationService.registerAsGlobal();
  QuoteService.initializeQuotes();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NotificationService()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,  
      title: 'OtakuPlanner',
      theme: OtakuPlannerTheme.lightTheme,
      darkTheme: OtakuPlannerTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: SplashScreen(), // Simplified - splash handles everything
      routes: {
        '/dashboard': (context) => Dashboard(),
        '/login': (context) => Login(),
      },
    );
  }
}