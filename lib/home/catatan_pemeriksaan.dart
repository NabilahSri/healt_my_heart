import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/home/add_catatan_pemerksaan.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CatatanPemeriksaan extends StatefulWidget {
  const CatatanPemeriksaan({super.key});

  @override
  State<CatatanPemeriksaan> createState() => _CatatanPemeriksaanState();
}

class _CatatanPemeriksaanState extends State<CatatanPemeriksaan> {
  List _listCatatanPemeriksaan = [];
  bool isLoading = false;
  Future<void> _showCatatanPemeriksaan() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.get(
        Uri.parse(Koneksi().baseUrl + 'mcu/user/' + iduser!),
        headers: {'Authorization': 'Bearer $access_token'});
    if (request.statusCode == 200) {
      final response = jsonDecode(request.body);
      if (mounted) {
        setState(() {
          _listCatatanPemeriksaan = response;
        });
      }
      log('Data Catatan Pemeriksaan: ' + _listCatatanPemeriksaan.toString());
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteCatatanPemeriksaan(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final request = await http.delete(
        Uri.parse(Koneksi().baseUrl + 'mcu/' + id),
        headers: {'Authorization': 'Bearer $access_token'});
    if (request.statusCode == 200) {
      _showCatatanPemeriksaan();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Data berhasil dihapus!',
      );
    } else {
      log(request.body);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Terjadi Kesalahan!',
      );
    }
  }

  @override
  void initState() {
    _showCatatanPemeriksaan();
    super.initState();
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
            'Catatan Pemeriksaan Terakhir',
            style: TextStyle(fontSize: 12.sp),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddCatatanPemerksaan()));
              },
              icon: Icon(Icons.add_box),
            )
          ],
        ),
        body: isLoading
            ? SpinKitChasingDots(color: Color(0xFFFF5A5F))
            : (_listCatatanPemeriksaan == null ||
                    _listCatatanPemeriksaan.isEmpty)
                ? Center(
                    child: Text(
                      "Anda belum memiliki daftar pemeriksaan.\nSilahkan tambahkan daftar pemeriksaan sekarang!",
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      final item = _listCatatanPemeriksaan[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['date_mcu'] ?? '-',
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: 'Konfirmasi',
                                            text:
                                                'Apakah anda ingin menghapus data ini?',
                                            confirmBtnText: 'Ya',
                                            cancelBtnText: 'Tidak',
                                            onConfirmBtnTap: () {
                                              _deleteCatatanPemeriksaan(
                                                  item['id'].toString());
                                              Navigator.pop(context);
                                            });
                                      },
                                      icon: Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                      ))
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nama Dokter',
                                  ),
                                  Text(
                                    item['doctor'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nama Rumah Sakit',
                                  ),
                                  Text(
                                    item['health_center'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tekana Darah',
                                  ),
                                  Text(
                                    item['tekanan_darah'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gula Darah Sewaktu',
                                  ),
                                  Text(
                                    item['gula_darah_sewaktu'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gula Darah Puasa',
                                  ),
                                  Text(
                                    item['gula_darah_puasa'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gula Darah 2 Jam PP',
                                  ),
                                  Text(
                                    item['gula_darah_dua_jam_pp'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'HBA1C',
                                  ),
                                  Text(
                                    item['hba1c'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'LDL',
                                  ),
                                  Text(
                                    item['ldl'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'HDL',
                                  ),
                                  Text(
                                    item['hdl'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kolesterol Total',
                                  ),
                                  Text(
                                    item['kolesterol'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ureum',
                                  ),
                                  Text(
                                    item['ureum'] ?? '-',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kreatinin',
                                  ),
                                  Text(
                                    item['kreatinin'] ?? '-',
                                  ),
                                ],
                              ),
                              Text('Hasil Analisis Lainnya'),
                              SizedBox(height: 4.sp),
                              Text(item['note'] ?? '-'),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: _listCatatanPemeriksaan.length,
                  ),
      ),
    );
  }
}
