
import 'package:energy_cost/src/pages/short_home_page.dart';
import 'package:energy_cost/src/pages/wide_home_page.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final homePage = width > 500 ? WideHomePage() : ShortHomePage();
    return MaterialApp(
      title: 'Energy Cost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow,
          dynamicSchemeVariant: DynamicSchemeVariant.expressive,
          contrastLevel: 1,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: homePage,
    );
  }
}
