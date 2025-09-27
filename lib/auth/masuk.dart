import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/auth/daftar.dart';
import 'package:health_my_heart/auth/lupa_kata_sandi.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Masuk extends StatefulWidget {
  const Masuk({super.key});

  @override
  State<Masuk> createState() => _MasukState();
}

class _MasukState extends State<Masuk> {
  bool _isObscure = true;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  Future<void> masuk() async {
    if (_email.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Email Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }

    if (_password.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Kata Sandi Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
      final request =
          await http.post(Uri.parse(Koneksi().baseUrl + 'auth'), body: {
        'email': _email.text,
        'password': _password.text,
      });
      if (request.statusCode == 200) {
        final response = jsonDecode(request.body);
        _btnController.success();

        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigationCustom(
                        id: 0,
                      )),
              (context) => false);
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response['access_token']);
        await prefs.setString('iduser', response['data']['id'].toString());
        final currentTime =
            DateTime.now().millisecondsSinceEpoch; // Waktu saat ini
        await prefs.setBool('isLoggedIn', true); // Simpan status login
        await prefs.setInt('loginTimestamp', currentTime);
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Email atau Kata Sandi Salah !',
        );
        _btnController.reset();
        log(request.body);
      }
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
                  "Selamat Datang",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "MyHeart App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Masuk",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
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
                // TextFormField untuk password
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _password,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        hintText: 'Masukan Kata Sandi',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LupaKataSandi()),
                              (context) => false);
                        },
                        child: const Text(
                          "Lupa Kata Sandi?",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
                // Tombol Masuk
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
                        "MASUK",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  controller: _btnController,
                  onPressed: () {
                    masuk();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum Punya Akun?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Daftar()),
                              (context) => false);
                        },
                        child: Text(
                          'Daftar Disini',
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
