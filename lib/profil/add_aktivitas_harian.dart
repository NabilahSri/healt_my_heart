import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddAktivitasHarian extends StatefulWidget {
  const AddAktivitasHarian({super.key});

  @override
  State<AddAktivitasHarian> createState() => _AddAktivitasHarianState();
}

class _AddAktivitasHarianState extends State<AddAktivitasHarian> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final TextEditingController _tekanandarah = TextEditingController();
  final TextEditingController _beratbadan = TextEditingController();
  final TextEditingController _cairanyangmasuk = TextEditingController();
  final TextEditingController _aktivitasharian = TextEditingController();
  final TextEditingController _intakemakananharian = TextEditingController();
  Future<void> _addAktivitasHarian() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final response =
        await http.post(Uri.parse(Koneksi().baseUrl + 'activity'), headers: {
      'Authorization': 'Bearer $access_token'
    }, body: {
      'tekanan_darah': _tekanandarah.text,
      'berat_badan': _beratbadan.text,
      'jml_cairan': _cairanyangmasuk.text,
      'aktivitas': _aktivitasharian.text,
      'makanan': _intakemakananharian.text,
      'users_id': iduser,
    });
    if (response.statusCode == 200) {
      _btnController.success();
      Timer(const Duration(seconds: 1), () {
        Navigator.pop(context);
        _btnController.reset();
      });
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 1), () {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Gagal Menambahkan Aktivitas Harian',
        );
        _btnController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => Scaffold(
              appBar: AppBar(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFFF5A5F),
                title: Text(
                  'Tambah Aktivitas',
                  style: TextStyle(fontSize: 12.sp),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
                  child: Column(
                    children: [
                      Text('Tekanan Darah Harian (Contoh: 100/70)'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 194, 196),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14.0),
                          child: TextFormField(
                            controller: _tekanandarah,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: '100/70',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text('Berat Badan per 3 Hari (Contoh: 60Kg)'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 194, 196),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14.0),
                          child: TextFormField(
                            controller: _beratbadan,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: '60Kg',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text('Cairan yang Masuk ke Tubuh (Contoh: 1000 cc)'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 194, 196),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14.0),
                          child: TextFormField(
                            controller: _cairanyangmasuk,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: '1000 cc',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text(
                          'Aktivitas Harian (Contoh: Olahraga, Jalan Pagi, dll)'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 194, 196),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14.0),
                          child: TextFormField(
                            controller: _aktivitasharian,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Jalan Pagi',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text('Intake Makanan Harian'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 194, 196),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14.0),
                          child: TextFormField(
                            controller: _intakemakananharian,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Sayur, Daging, Nasi',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
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
                          _addAktivitasHarian();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
