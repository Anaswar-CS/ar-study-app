import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ar_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Study App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ArScannerScreen(),
    );
  }
}