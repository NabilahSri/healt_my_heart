import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Periksa apakah access_token ada dan tidak kosong
    final accessToken = prefs.getString('access_token');
    if (accessToken == null || accessToken.isEmpty) {
      return false; // Jika access_token kosong, sesi dianggap tidak valid
    }

    if (!isLoggedIn) return false;

    final loginTimestamp = prefs.getInt('loginTimestamp') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    const sessionDuration = 3 * 60 * 60 * 1000; // 3 jam dalam milidetik
    if ((currentTime - loginTimestamp) > sessionDuration) {
      // Sesi telah kedaluwarsa
      await prefs.remove('isLoggedIn'); // Hapus status login
      await prefs.remove('loginTimestamp'); // Hapus waktu login
      await prefs.remove('access_token'); // Hapus access_token
      return false;
    }

    return true; // Sesi masih valid
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return FutureBuilder<bool>(
          future: _isSessionValid(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final isSessionValid = snapshot.data ?? false;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: isSessionValid
                  ? const BottomNavigationCustom(id: 0)
                  : const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
