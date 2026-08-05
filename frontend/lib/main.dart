// Mysty — Gamified Offline To-Do App
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysty/app.dart';
import 'package:mysty/providers/task_provider.dart';
import 'package:mysty/providers/stats_provider.dart';
import 'package:mysty/providers/category_provider.dart';
import 'package:mysty/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // Catch unhandled async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('AsyncError: $error\n$stack');
    return true;
  };

  String? initError;
  try {
    await DatabaseService().init();
  } catch (e, stack) {
    initError = '$e\n$stack';
    debugPrint('Failed to initialize database: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: CyberpunkTodoApp(initError: initError),
    ),
  );
}
