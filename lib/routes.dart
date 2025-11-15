import 'package:flutter/material.dart';
import 'homepage/home_page.dart';
import 'settings/profile_page.dart';
import 'homepage/login_page.dart';
import 'screens/dashboard/dashboard_screen.dart';

class Routes {
  static const login = '/';
  static const home = '/home';
  static const profile = '/profile';
  static const dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}