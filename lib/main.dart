import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'providers/todo_provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_styles.dart';
import 'pages/todo_list_page.dart';
import 'package:flutter/foundation.dart';

// Only import FFI packages if needed
// ignore: uri_does_not_exist
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// ignore: uri_does_not_exist
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // ✅ Web: Use Web FFI
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // ✅ Desktop: Use FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // ✅ Mobile: Sqflite works out of the box, no extra initialization needed

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LMG TODO App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          onPrimary: AppColors.textInverse,
          onSecondary: AppColors.textInverse,
          onSurface: AppColors.textPrimary,
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppStyles.radius12)),
          ),
          color: AppColors.cardBackground,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radius8),
            ),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radius8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radius8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radius8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radius8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textTertiary),
        ),
      ),
      home: const TodoListPage(),
      initialBinding: BindingsBuilder(() {
        Get.put(TodoProvider());
      }),
    );
  }
}
