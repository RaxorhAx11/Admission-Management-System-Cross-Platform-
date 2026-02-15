import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:admission_management/core/constants/app_routes.dart';
import 'package:admission_management/firebase_options.dart';
import 'package:admission_management/providers/application_provider.dart';
import 'package:admission_management/providers/auth_provider.dart';
import 'package:admission_management/providers/course_provider.dart';
import 'package:admission_management/providers/theme_provider.dart';
import 'package:admission_management/screens/admin/admin_dashboard_screen.dart';
import 'package:admission_management/screens/admin/application_detail_screen.dart';
import 'package:admission_management/screens/auth/login_register_screen.dart';
import 'package:admission_management/screens/education_news_screen.dart';
import 'package:admission_management/screens/profile_screen.dart';
import 'package:admission_management/screens/settings_screen.dart';
import 'package:admission_management/screens/splash_screen.dart';
import 'package:admission_management/screens/student/admission_form_screen.dart';
import 'package:admission_management/screens/student/application_status_screen.dart';
import 'package:admission_management/screens/student/course_detail_screen.dart';
import 'package:admission_management/screens/student/course_list_screen.dart';
import 'package:admission_management/models/course_model.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title: 'Admission Management',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (ctx) => const SplashWrapper(),
              AppRoutes.login: (ctx) => const LoginRegisterScreen(),
              AppRoutes.dashboard: (ctx) => const CourseListScreen(),
              AppRoutes.courses: (ctx) => const CourseListScreen(),
              AppRoutes.profile: (ctx) => const ProfileScreen(),
              AppRoutes.settings: (ctx) => const SettingsScreen(),
              AppRoutes.educationNews: (ctx) => const EducationNewsScreen(),
              AppRoutes.myApplications: (ctx) => const ApplicationStatusScreen(),
              AppRoutes.adminDashboard: (ctx) => const AdminDashboardScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.courseDetail) {
                final course = settings.arguments as CourseModel?;
                if (course != null) {
                  return MaterialPageRoute(
                    builder: (_) => CourseDetailScreen(course: course),
                  );
                }
              }
              if (settings.name == AppRoutes.applicationDetail) {
                final id = settings.arguments as String?;
                if (id != null) {
                  return MaterialPageRoute(
                    builder: (_) => ApplicationDetailScreen(applicationId: id),
                  );
                }
              }
              if (settings.name == AppRoutes.admissionForm) {
                final course = settings.arguments as CourseModel?;
                if (course != null) {
                  return MaterialPageRoute(
                    builder: (_) => AdmissionFormScreen(course: course),
                  );
                }
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

/// Shows splash while auth is resolving, then redirects to login or role-based home.
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
          Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        }
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
