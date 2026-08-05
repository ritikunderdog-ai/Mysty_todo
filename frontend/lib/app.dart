import 'package:flutter/material.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/screens/home_screen.dart';

class CyberpunkTodoApp extends StatelessWidget {
  final String? initError;
  const CyberpunkTodoApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mysty',
      debugShowCheckedModeBanner: false,
      theme: CyberpunkTheme.darkTheme,
      home: initError != null
          ? Scaffold(
              backgroundColor: CyberpunkColors.background,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: CyberpunkColors.error, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'INITIALIZATION ERROR',
                        style: TextStyle(
                          color: CyberpunkColors.error,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CyberpunkColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: CyberpunkColors.cardBorder),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            initError!,
                            style: const TextStyle(
                              color: CyberpunkColors.textSecondary,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const HomeScreen(),
    );
  }
}
