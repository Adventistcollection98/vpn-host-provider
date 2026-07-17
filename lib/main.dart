import 'package:flutter/material.dart';
import 'screens/host_provider_screen.dart';

void main() {
  runApp(const VPNHostProviderApp());
}

class VPNHostProviderApp extends StatelessWidget {
  const VPNHostProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPN Host Provider',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: const HostProviderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
