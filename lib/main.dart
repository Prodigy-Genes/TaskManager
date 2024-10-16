import 'package:flutter/material.dart';
import 'package:task_manager/screens/onboarding_screen.dart';
import 'package:task_manager/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure that Flutter has finished initializing before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  bool seenOnboarding = await _checkOnboardingStatus();
  runApp(TaskManager(seenOnboarding: seenOnboarding));
}

// Function to check if the user has already seen the onboarding screen
Future<bool> _checkOnboardingStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('seenOnboarding') ?? false;
}

// ignore: camel_case_types
class TaskManager extends StatelessWidget {
  final bool seenOnboarding;

  const TaskManager({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use the onboarding screen only if it's the first time the user opens the app
      initialRoute: seenOnboarding ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
