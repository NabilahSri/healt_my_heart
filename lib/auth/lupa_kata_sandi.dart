import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/auth/masuk.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LupaKataSandi extends StatefulWidget {
  const LupaKataSandi({super.key});

  @override
  State<LupaKataSandi> createState() => _LupaKataSandiState();
}

class _LupaKataSandiState extends State<LupaKataSandi> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _email = TextEditingController();

  void _doSomething() async {
    Timer(Duration(seconds: 3), () {
      _btnController.success();
    });
  }

  Future<void> _resetPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final request =
        await http.post(Uri.parse(Koneksi().baseUrl + 'password/email'), body: {
      'email': _email.text,
    }, headers: {
      'Authorization': 'Bearer $access_token'
    });
    if (request.statusCode == 200) {
      _btnController.success();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Silahkan Cek Email Anda',
          onConfirmBtnTap: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Masuk()),
                (route) => false);
          },
        );
      });
      log(request.body);
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Terjadi Kesalahan!',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => Scaffold(
        backgroundColor: const Color(0xFFFF5A5F),
        body: Container(
          decoration: const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Reset Kata Sandi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Jika anda lupa dengan kata sandi anda, anda dapat melakukan reset kata sandi dengan mengisi form dibawah.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // TextFormField untuk email
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: 'Masukan Email Anda',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                RoundedLoadingButton(
                  valueColor: Colors.black38,
                  successColor: Colors.green,
                  height: 40.h,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login, color: Colors.black),
                      SizedBox(width: 10.w),
                      const Text(
                        "KIRIM",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  controller: _btnController,
                  onPressed: () {
                    _resetPassword();
                  },
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Masuk()),
                          (context) => false);
                    },
                    child: Text(
                      'Kembali ke halaman login',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
