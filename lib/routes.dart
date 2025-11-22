import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/homepage/home_page.dart';
import 'package:doctor_appointment_app/homepage/login_page.dart';
import 'package:doctor_appointment_app/homepage/appointments_page.dart';
import 'package:doctor_appointment_app/screens/dashboard/dashboard_screen.dart';
import 'package:doctor_appointment_app/screens/dashboard/graphics_page.dart';
import 'package:doctor_appointment_app/settings/profile_page.dart';
import 'package:doctor_appointment_app/settings/about_screen.dart';
import 'package:doctor_appointment_app/settings/privacy_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String appointments = '/appointments';
  static const String dashboard = '/dashboard';
  static const String graphics = '/graphics';
  static const String profile = '/profile';
  static const String about = '/about';
  static const String privacy = '/privacy';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case graphics:
        return MaterialPageRoute(builder: (_) => const GraphicsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());
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