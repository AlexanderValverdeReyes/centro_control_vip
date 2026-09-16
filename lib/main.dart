import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'views/main_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const VIPControlCenterApp(),
    ),
  );
}

class VIPControlCenterApp extends StatelessWidget {
  const VIPControlCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centro de Control VIP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        canvasColor: const Color(0xFF2C3035),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0B3B6F),
          secondary: Color(0xFFD4AF37),
          error: Color(0xFF8B0000),
          surface: Color(0xFF1E1E1E),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto', // Default clean sans-serif
        ),
      ),
      home: const MainLayout(),
    );
  }
}
