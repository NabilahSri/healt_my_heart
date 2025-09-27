import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/home/catatan_pemeriksaan.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddCatatanPemerksaan extends StatefulWidget {
  const AddCatatanPemerksaan({super.key});

  @override
  State<AddCatatanPemerksaan> createState() => _AddCatatanPemerksaanState();
}

class _AddCatatanPemerksaanState extends State<AddCatatanPemerksaan> {
  final TextEditingController _pilihTanggal = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _tekananDarah = TextEditingController();
  final TextEditingController _gulaDarahSewaktu = TextEditingController();
  final TextEditingController _gulaDarahPuasa = TextEditingController();
  final TextEditingController _gulaDarah2JamPP = TextEditingController();
  final TextEditingController _hba1c = TextEditingController();
  final TextEditingController _ldl = TextEditingController();
  final TextEditingController _hdl = TextEditingController();
  final TextEditingController _kolesterolTotal = TextEditingController();
  final TextEditingController _ureum = TextEditingController();
  final TextEditingController _kreatinin = TextEditingController();
  final TextEditingController _namaDokter = TextEditingController();
  final TextEditingController _namaRs = TextEditingController();
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

    if (_tekananDarah.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Tekanan Darah Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_pilihTanggal.text.isNotEmpty && _tekananDarah.text.isNotEmpty) {
      final tanggalInput = DateFormat('dd-MM-yyyy').parse(_pilihTanggal.text);
      final tanggalPemeriksaan = DateFormat('yyyy-MM-dd').format(tanggalInput);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');
      String? iduser = prefs.getString('iduser');

      final request =
          await http.post(Uri.parse(Koneksi().baseUrl + 'mcu'), body: {
        'date_mcu': tanggalPemeriksaan,
        'tekanan_darah': _tekananDarah.text,
        'gula_darah_sewaktu': _gulaDarahSewaktu.text,
        'gula_darah_puasa': _gulaDarahPuasa.text,
        'gula_darah_dua_jam_pp': _gulaDarah2JamPP.text,
        'hba1c': _hba1c.text,
        'ldl': _ldl.text,
        'hdl': _hdl.text,
        'kolesterol': _kolesterolTotal.text,
        'ureum': _ureum.text,
        'kreatinin': _kreatinin.text,
        'doctor': _namaDokter.text,
        'health_center': _namaRs.text,
        'note': _hasilAnalisis.text,
        'users_id': iduser
      }, headers: {
        'Authorization': 'Bearer $access_token',
      });
      log(request.body);
      if (request.statusCode == 200) {
        _btnController.success();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CatatanPemeriksaan()));
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
            text: 'Gagal Menambahkan Riwayat Pemeriksaan',
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
          backgroundColor: Color(0xFFFF5A5F),
          foregroundColor: Colors.white,
          title: Text(
            'Tambah Riwayat Pemeriksaan',
            style: TextStyle(fontSize: 12.sp),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, right: 12.0, left: 12.0),
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
                          _pilihTanggal.text =
                              DateFormat('dd-MM-yyyy').format(selectedDate);
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
                Text('Tekanan darah'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _tekananDarah,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: '100/70',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('Gula darah sewaktu'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _gulaDarahSewaktu,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('Gula darah puasa'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _gulaDarahPuasa,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('Gula darah 2 jam PP'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _gulaDarah2JamPP,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('HBA1C'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _hba1c,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('LDL'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _ldl,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('HDL'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _hdl,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('Kolesterol total'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _kolesterolTotal,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('Ureum'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _ureum,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text('Kreatinin'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _kreatinin,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Boleh Dikosongkan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
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
                        hintText: 'RS. Citra Medika',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
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
                        hintText: 'Dr. Sutrisno',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
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
                        hintText: 'Lainl-lain',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                // Tombol Masuk
                RoundedLoadingButton(
                    valueColor: Colors.black38,
                    successColor: Colors.green,
                    height: 40.h,
                    color: Color(0xFFFF5A5F),
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
                    }),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
