import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/register_screen.dart';
import 'screens/manage_genres_screen.dart';
import 'providers/game_provider.dart';
import 'providers/review_provider.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(GamesTrackerApp());
}

class GamesTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Games Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/register': (context) => RegisterScreen(),
          '/manage_genres': (context) => ManageGenresScreen(),
        },
      ),
    );
  }
}
