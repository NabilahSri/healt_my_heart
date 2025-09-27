import 'dart:async';
import 'dart:developer';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/auth/masuk.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  bool _isObscure = true;
  String? _selectedGender;
  final TextEditingController _pilihTanggal = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nama = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  Future<void> daftar() async {
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
    if (_nama.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Nama Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_pilihTanggal.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Tanggal Lahir Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Jenis Kelamin Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_email.text.isNotEmpty &&
        _password.text.isNotEmpty &&
        _nama.text.isNotEmpty &&
        _pilihTanggal.text.isNotEmpty &&
        _selectedGender!.isNotEmpty &&
        _selectedGender != null) {
      final tanggalInput = DateFormat('dd-MM-yyyy').parse(_pilihTanggal.text);
      final tanggalLahir = DateFormat('yyyy-MM-dd').format(tanggalInput);
      final request = await http.post(
        Uri.parse(Koneksi().baseUrl + 'users'),
        body: {
          'email': _email.text,
          'password': _password.text,
          'name': _nama.text,
          'date_of_birth': tanggalLahir,
          'sex': _selectedGender!,
        },
      );
      if (request.statusCode == 200) {
        _btnController.success();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Masuk()),
              (context) => false);
        });
        _btnController.reset();
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Terjadi Kesalahan Saat Mendaftar',
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
                  "Daftar MyHeart App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Daftarkan diri anda untuk dapat menggunakan apliaksi MyHeart secara gratis",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Data Akun",
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
                      keyboardType: TextInputType.visiblePassword,
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
                SizedBox(height: 12.h),
                const Text(
                  "Data Diri",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 9.h),
                // TextFormField untuk nama
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _nama,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Masukan Nama Anda',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                // TextFormField untuk tanggal lahir
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDate != null) {
                          _pilihTanggal.text =
                              DateFormat('dd-MM-yyyy').format(selectedDate);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _pilihTanggal,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.date_range),
                            hintText: 'Pilih Tanggal Lahir',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 16.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 9.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RadioMenuButton(
                        value: 'L',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        child: const Text('Laki-laki')),
                    RadioMenuButton(
                        value: 'P',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        child: const Text('Perempuan')),
                  ],
                ),
                SizedBox(height: 9.h),
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
                          "DAFTAR",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    controller: _btnController,
                    onPressed: () {
                      daftar();
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah Punya Akun?',
                      style: TextStyle(color: Colors.white),
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
                          'Masuk Disini',
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
