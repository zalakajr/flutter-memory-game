import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:memorygame/memoryscreen.dart';

void main() {
  // For development with device preview
  // Uncomment the following lines to enable device preview
  
  runApp(
    DevicePreview(
      enabled: !bool.fromEnvironment('dart.vm.product'),
      builder: (context) => const MyApp(),
    ),
  );
  
  
  // For production without device preview
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const MemoryGamePage(),
    );
  }
}
