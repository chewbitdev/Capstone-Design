import 'package:flutter/material.dart';
import 'features/guardian/presentation/pages/caregiver_home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '아이콩',
      debugShowCheckedModeBanner: false,
      home: const CaregiverHomePage(),
    );
  }
}
