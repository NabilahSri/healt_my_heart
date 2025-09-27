import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddRiwayatPerawatanKesehatan extends StatefulWidget {
  const AddRiwayatPerawatanKesehatan({super.key});

  @override
  State<AddRiwayatPerawatanKesehatan> createState() =>
      _AddRiwayatPerawatanKesehatanState();
}

class _AddRiwayatPerawatanKesehatanState
    extends State<AddRiwayatPerawatanKesehatan> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _pilihTanggal = TextEditingController();
  final TextEditingController _namaRs = TextEditingController();
  final TextEditingController _namaDokter = TextEditingController();
  final TextEditingController _hasilAnalisis = TextEditingController();

  Future<void> addPemeriksaan() async {
    if (_pilihTanggal.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Tanggal Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }

    if (_namaRs.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Nama Rumah Sakit Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_namaDokter.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Nama Dokter Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_hasilAnalisis.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Hasil Analisis Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_pilihTanggal.text.isNotEmpty &&
        _namaRs.text.isNotEmpty &&
        _namaDokter.text.isNotEmpty &&
        _hasilAnalisis.text.isNotEmpty) {
      final tanggalInput = DateFormat('dd-MM-yyyy').parse(_pilihTanggal.text);
      final tanggalPerawatan = DateFormat('yyyy-MM-dd').format(tanggalInput);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');
      String? iduser = prefs.getString('iduser');

      final request =
          await http.post(Uri.parse(Koneksi().baseUrl + 'healthcare'), body: {
        'datetime': tanggalPerawatan,
        'health_center': _namaRs.text,
        'doctor': _namaDokter.text,
        'analysis_results': _hasilAnalisis.text,
        'users_id': iduser
      }, headers: {
        'Authorization': 'Bearer $access_token',
      });
      log(request.body);
      if (request.statusCode == 200) {
        _btnController.success();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          Navigator.pop(context, 'added');
        });
        _btnController.reset();
      } else {
        log(request.body);
        _btnController.error();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: 'Gagal Menambahkan Riwayat Perawatan Kesehatan',
          );
        });
        _btnController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => Scaffold(
              appBar: AppBar(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFFF5A5F),
                title: Text(
                  'Riwayat Perawatan Kesehatan',
                  style: TextStyle(fontSize: 12.sp),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 24.0),
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
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );

                              if (selectedDate != null) {
                                _pilihTanggal.text = DateFormat('dd-MM-yyyy')
                                    .format(selectedDate);
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _pilihTanggal,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.date_range),
                                  hintText: 'Pilih Tanggal Pemeriksaan',
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
                      Text('Nama rumah sakit'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 194, 196),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14.0),
                          child: TextFormField(
                            controller: _namaRs,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text('Nama dokter'),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 194, 196),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 14.0),
                          child: TextFormField(
                            controller: _namaDokter,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Text('Hasil analisis'),
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
                            controller: _hasilAnalisis,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
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
                            const Text(
                              "SIMPAN",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        controller: _btnController,
                        onPressed: () {
                          addPemeriksaan();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
