import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:admission_management/core/theme/app_theme.dart';
import 'package:admission_management/firebase_options.dart';
import 'package:admission_management/providers/application_provider.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/providers/course_provider.dart';
import 'package:admission_management/screens/admin/admin_dashboard_screen.dart';
import 'package:admission_management/screens/admin/application_detail_screen.dart';
import 'package:admission_management/screens/auth/login_register_screen.dart';
import 'package:admission_management/screens/splash_screen.dart';
import 'package:admission_management/screens/student/application_status_screen.dart';
import 'package:admission_management/screens/student/course_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdmissionApp());
}

/// Root app with Provider and theme. Simple and readable.
class AdmissionApp extends StatelessWidget {
  const AdmissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
      ],
      child: MaterialApp(
        title: 'Admission Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashWrapper(),
          '/login': (ctx) => const LoginRegisterScreen(),
          '/student/courses': (ctx) => const CourseListScreen(),
          '/student/applications': (ctx) => const ApplicationStatusScreen(),
          '/admin': (ctx) => const AdminDashboardScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/admin/application') {
            final id = settings.arguments as String?;
            if (id != null) {
              return MaterialPageRoute(
                builder: (_) => ApplicationDetailScreen(applicationId: id),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}

/// Shows splash while auth is resolving, then redirects to login or role-based home.
/// Waits briefly so Firebase Auth can restore session before deciding.
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _redirectDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted || _redirectDone) return;
      _redirectDone = true;
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        if (auth.isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          Navigator.of(context).pushReplacementNamed('/student/courses');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
