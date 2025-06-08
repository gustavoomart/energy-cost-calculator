import 'package:flutter/material.dart';

class ShortHomePage extends StatefulWidget {
  const ShortHomePage({super.key});

  @override
  State<ShortHomePage> createState() => _ShortHomePageState();
}

class _ShortHomePageState extends State<ShortHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(onPressed: () {}, child: Icon(Icons.ad_units),),
    );
  }
}
