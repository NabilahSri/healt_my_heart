import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RiwayatPenyakit extends StatefulWidget {
  const RiwayatPenyakit({super.key});

  @override
  State<RiwayatPenyakit> createState() => _RiwayatPenyakitState();
}

class _RiwayatPenyakitState extends State<RiwayatPenyakit> {
  bool isLoading = false;
  int? selectedAnswerHipertensi;
  int? selectedAnswerDiabetes;
  int? selectedAnswerHiperkolesterol;
  int? selectedAnswerkelainanJantung;
  final TextEditingController _pertamakali = TextEditingController();
  final TextEditingController _lainnya = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  List _data = [];
  Map<String, dynamic> _riwayatPenyakit = {};
  bool dataAvailable = false;

  Future<void> _updateriwayat() async {
    if (selectedAnswerHipertensi != null &&
        selectedAnswerDiabetes != null &&
        selectedAnswerHiperkolesterol != null &&
        selectedAnswerkelainanJantung != null &&
        _pertamakali.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');
      String? iduser = prefs.getString('iduser');

      final request = await http.put(
        Uri.parse(Koneksi().baseUrl + 'medicalhistory/user/' + iduser!),
        body: {
          'waktu_diagnosa_jantung': _pertamakali.text,
          'hipertensi': selectedAnswerHipertensi.toString(),
          'diabetes_melitus': selectedAnswerDiabetes.toString(),
          'hiperkolesterol': selectedAnswerHiperkolesterol.toString(),
          'kelainan_jantung_bawaan': selectedAnswerkelainanJantung.toString(),
          'keterangan_penyakit_lain': _lainnya.text.toString(),
          'users_id': iduser,
        },
        headers: {
          'Authorization': 'Bearer $access_token',
        },
      );

      if (request.statusCode == 200) {
        _btnController.success();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Berhasil memperbarui riwayat penyakit',
          );
        });
        _showdata();
      } else {
        _btnController.error();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Terjadi kesalahan',
          );
        });
      }
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            text: 'Semua field harus diisi',
            confirmBtnText: 'OK');
      });
    }
  }

  Future<void> _addriwayat() async {
    if (selectedAnswerHipertensi != null &&
        selectedAnswerDiabetes != null &&
        selectedAnswerHiperkolesterol != null &&
        selectedAnswerkelainanJantung != null &&
        _pertamakali.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');
      String? iduser = prefs.getString('iduser');

      final request = await http.post(
        Uri.parse(Koneksi().baseUrl + 'medicalhistory'),
        body: {
          'waktu_diagnosa_jantung': _pertamakali.text,
          'hipertensi': selectedAnswerHipertensi.toString(),
          'diabetes_melitus': selectedAnswerDiabetes.toString(),
          'hiperkolesterol': selectedAnswerHiperkolesterol.toString(),
          'kelainan_jantung_bawaan': selectedAnswerkelainanJantung.toString(),
          'keterangan_penyakit_lain': _lainnya.text.toString(),
          'users_id': iduser,
        },
        headers: {
          'Authorization': 'Bearer $access_token',
        },
      );

      if (request.statusCode == 200) {
        _btnController.success();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Berhasil menambahkan riwayat penyakit',
          );
        });
        _showdata();
      } else {
        _btnController.error();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Terjadi kesalahan',
          );
        });
      }
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            text: 'Semua field harus diisi',
            confirmBtnText: 'OK');
      });
    }
  }

  Future<void> _showdata() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.get(
      Uri.parse(Koneksi().baseUrl + 'medicalhistory/user/' + iduser!),
      headers: {'Authorization': 'Bearer $access_token'},
    );
    if (request.statusCode == 200) {
      final response = jsonDecode(request.body);
      if (mounted) {
        setState(() {
          _data = response;
          dataAvailable = response.isNotEmpty;
          if (dataAvailable) {
            _riwayatPenyakit = response[0];
            _pertamakali.text = _riwayatPenyakit['waktu_diagnosa_jantung'];
            _lainnya.text = _riwayatPenyakit['keterangan_penyakit_lain'];
            selectedAnswerHipertensi = _riwayatPenyakit['hipertensi'];
            selectedAnswerDiabetes = _riwayatPenyakit['diabetes_melitus'];
            selectedAnswerHiperkolesterol = _riwayatPenyakit['hiperkolesterol'];
            selectedAnswerkelainanJantung =
                _riwayatPenyakit['kelainan_jantung_bawaan'];
          } else {
            // Jika respons kosong
            _pertamakali.text = '';
            _lainnya.text = '';
            selectedAnswerHipertensi;
            selectedAnswerDiabetes;
            selectedAnswerDiabetes;
            selectedAnswerHiperkolesterol;
            selectedAnswerkelainanJantung;
          }
        });
      }
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Gagal mengambil data',
      );
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _showdata();
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
                'Riwayat Penyakit',
                style: TextStyle(fontSize: 12.sp),
              ),
              centerTitle: true,
            ),
            body: isLoading
                ? SpinKitChasingDots(color: Color(0xFFFF5A5F))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 24.0, left: 12.0, right: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Kapan pertama kali anda didiagnosis penyakit jantung?',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 250, 194, 196),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 14.0),
                              child: TextFormField(
                                controller: _pertamakali,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  hintText: 'Januari 2022',
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 16.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Apakah anda memiliki riwayat hipertensi?',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerHipertensi = 1;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerHipertensi == 1
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Iya',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerHipertensi == 1
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerHipertensi = 0;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerHipertensi == 0
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Tidak',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerHipertensi == 0
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 9.h),
                          Text(
                            'Apakah anda memiliki riwayat diabetes melitus?',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerDiabetes = 1;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerDiabetes == 1
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Iya',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerDiabetes == 1
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerDiabetes = 0;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerDiabetes == 0
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Tidak',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerDiabetes == 0
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 9.h),
                          Text(
                            'Apakah anda memiliki riwayat hiperkolesterol?',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerHiperkolesterol = 1;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerHiperkolesterol == 1
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Iya',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerHiperkolesterol == 1
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerHiperkolesterol = 0;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerHiperkolesterol == 0
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Tidak',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerHiperkolesterol == 0
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 9.h),
                          Text(
                            'Apakah anda memiliki riwayat penyakit kelainan jantung bawaan? (dari lahir)',
                            style: TextStyle(fontSize: 12.sp),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerkelainanJantung = 1;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerkelainanJantung == 1
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Iya',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerkelainanJantung == 1
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswerkelainanJantung = 0;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: selectedAnswerkelainanJantung == 0
                                        ? const Color(0xFFFF5A5F)
                                        : const Color.fromARGB(
                                            255, 250, 194, 196),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Tidak',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: selectedAnswerkelainanJantung == 0
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 9.h),
                          Text('Keterangan penyakit lainnya'),
                          Container(
                            height: 240.w,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 250, 194, 196),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 14.0),
                              child: TextFormField(
                                controller: _lainnya,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: 'Lain-lain',
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 16.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 9.h),
                          // Tombol Simpan
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
                                Text(
                                  dataAvailable ? 'Update' : 'Simpan',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            controller: _btnController,
                            onPressed: () {
                              if (dataAvailable) {
                                _updateriwayat();
                              } else {
                                _addriwayat();
                              }
                            },
                          ),
                          SizedBox(height: 9.h),
                        ],
                      ),
                    ),
                  )));
  }
}
