import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/auth/masuk.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UbahKataSandi extends StatefulWidget {
  const UbahKataSandi({super.key});

  @override
  State<UbahKataSandi> createState() => _UbahKataSandiState();
}

class _UbahKataSandiState extends State<UbahKataSandi> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  bool _isObscure = true;
  bool _isObscureConfirm = true;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  Future<void> _ubahKataSandi() async {
    if (_password.text.isNotEmpty &&
        _passwordConfirm.text.isNotEmpty &&
        _password.text == _passwordConfirm.text) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');
      String? iduser = prefs.getString('iduser');
      final request = await http.put(
        Uri.parse(Koneksi().baseUrl + 'users/password/' + iduser!),
        body: {'password': _password.text},
        headers: {'Authorization': 'Bearer $access_token'},
      );
      if (request.statusCode == 200) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Masuk()), (route) => false);
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Terjadi Kesalahan!',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFF5A5F),
          foregroundColor: Colors.white,
          title: Text('Ubah Kata Sandi', style: TextStyle(fontSize: 12.sp)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 12.0, right: 12.0),
            child: Column(
              children: [
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
                        hintText: 'Kata Sandi Baru',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _passwordConfirm,
                      obscureText: _isObscureConfirm,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscureConfirm = !_isObscureConfirm;
                            });
                          },
                        ),
                        hintText: 'Ulang Kata Sandi',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                // Tombol Masuk
                RoundedLoadingButton(
                  valueColor: Colors.black38,
                  successColor: Colors.green,
                  height: 40.h,
                  color: const Color(0xFFFF5A5F),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.black,
                        size: 20.w,
                      ),
                      SizedBox(width: 10.w),
                      const Text(
                        "SIMPAN",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  controller: _btnController,
                  onPressed: () {
                    if (_password.text.isEmpty) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        text: 'Kata Sandi Tidak Boleh Kosong',
                      );
                      _btnController.reset();
                      return;
                    }
                    if (_passwordConfirm.text.isEmpty) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        text: 'Kata Sandi Tidak Boleh Kosong',
                      );
                      _btnController.reset();

                      return;
                    }
                    if (_password.text != _passwordConfirm.text) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        text: 'Kata Sandi Tidak Sama',
                      );
                      _btnController.reset();

                      return;
                    }

                    QuickAlert.show(
                        context: context,
                        type: QuickAlertType.confirm,
                        title: 'Konfirmasi',
                        text:
                            'Jka anda mengubah kata sandi, anda harus login kembali',
                        confirmBtnText: 'Ya',
                        cancelBtnText: 'Tidak',
                        onConfirmBtnTap: () {
                          _ubahKataSandi();
                          Navigator.pop(context);
                        });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
