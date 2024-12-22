import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/auth/masuk.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Ukuran desain layar (width x height)
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            // Splash Screen Animation
            FlutterSplashScreen.scale(
              childWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 140.h, // Tinggi responsif untuk logo
                    child: Image.asset('assets/images/logo.png'),
                  ), // Jarak antara logo dan teks
                  Text(
                    "Health My Heart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp, // Responsif berdasarkan layar
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),// Jarak antara teks utama dan teks deskripsi
                  SizedBox(
                    width: 200.w,
                    child: Text(
                      "APLIKASI YANG DICIPTAKAN SEBAGAI SELF-REPORT ATAU PEMANTAUAN MANDIRI PASIEN GAGAL JANTUNG YANG TELAH MENJALANI PERAWATAN ATAUPUN YANG BELUM SUPAYA TIDAK TERJADI RAWAT BERULANG ATAU KOMPLIKASI YANG LEBIH BERAT.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF5A5F),
                  Color(0xFF4A90E2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              duration: const Duration(milliseconds: 5000),
              animationDuration: const Duration(milliseconds: 2500),
              onAnimationEnd: () => debugPrint("On Scale End"),
              nextScreen: const Masuk(),
            ),
            // SpinKit di luar FlutterSplashScreen
            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: Center(
                child: SpinKitThreeInOut(
                  color: Colors.white,
                  size: 22.sp, // Responsif berdasarkan skala
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
