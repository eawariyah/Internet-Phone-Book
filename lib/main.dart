import 'package:contactmanagementsystem/subpageone.dart';
import 'package:contactmanagementsystem/subpagetwo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LandingPage());
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routing the pages',
      initialRoute: '/',
      routes: {
        '/': (context) => const SubPageOne(),
        '/second': (context) => const SubPageTwo(),
      },
    );
  }
}
