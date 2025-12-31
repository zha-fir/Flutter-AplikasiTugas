import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

import 'task_model.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // --- SETUP DATABASE (MULAI) ---
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(SubTaskAdapter());

  await Hive.openBox<Task>('tasksBox');
  // --- SETUP DATABASE (SELESAI) ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Utama
    const seedColor = Colors.indigo;

    // Konfigurasi TextTheme (Font: Poppins)
    final textTheme = GoogleFonts.poppinsTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Tugasku',

      // --- TEMA TERANG (LIGHT MODE) ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        textTheme: textTheme,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent, // Modern Look
        ),
        scaffoldBackgroundColor:
            Colors.grey[50], // Sedikit abu-abu biar tidak silau
        // NOTE: Fixed error by using CardThemeData if available, specifically for this environment
        // If CardThemeData is not found, it means the error was misleading, but let's try to follow the error.
        // However, standard Flutter uses CardTheme.
        // Let's try explicitly casting or just CardTheme() but checking if 'CardThemeData' is the class.
        // I will stick with CardTheme but if it fails I will try to remove it temporarily to verify.
        // Wait, I will use CardThemeData as the error suggested.
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),

      // --- TEMA GELAP (DARK MODE) ---
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E2C), // Warna kartu gelap
          // Removed deprecated 'background'
        ),
        textTheme: textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          color: Color(0xFF1E1E2C), // Warna kartu di dark mode
        ),
      ),

      // Mengikuti pengaturan sistem (Otomatis)
      themeMode: ThemeMode.system,

      home: const MainScreen(),
    );
  }
}
