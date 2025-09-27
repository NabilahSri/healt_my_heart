import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/home/add_riwayat_perawatan_kesehatan.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPerawatanKesehatan extends StatefulWidget {
  const RiwayatPerawatanKesehatan({super.key});

  @override
  State<RiwayatPerawatanKesehatan> createState() =>
      _RiwayatPerawatanKesehatanState();
}

class _RiwayatPerawatanKesehatanState extends State<RiwayatPerawatanKesehatan> {
  bool isLoading = false;
  List listData = [];
  Future<void> _showDaata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        Uri.parse(Koneksi().baseUrl + 'healthcare/user/' + iduser!),
        headers: {'Authorization': 'Bearer $access_token'});
    if (response.statusCode == 200) {
      setState(() {
        listData = jsonDecode(response.body);
      });
      log(listData.toString());
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Terjadi Kesalahan!',
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final response = await http.delete(
        Uri.parse(Koneksi().baseUrl + 'healthcare/' + id),
        headers: {'Authorization': 'Bearer $access_token'});
    if (response.statusCode == 200) {
      _showDaata();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Data Berhasil Dihapus!',
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Terjadi Kesalahan!',
      );
    }
  }

  @override
  void initState() {
    _showDaata();
    super.initState();
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
          actions: [
            IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddRiwayatPerawatanKesehatan()),
                  );
                  // Setelah kembali dari halaman tambah data, muat ulang data
                  if (result == 'added') {
                    _showDaata(); // Memperbarui data
                  }
                },
                icon: Icon(Icons.add_box))
          ],
        ),
        body: isLoading
            ? SpinKitChasingDots(color: Color(0xFFFF5A5F))
            : listData.isEmpty
                ? Center(child: Text('Tidak ada riwayat perawatan kesehatan'))
                : Padding(
                    padding: const EdgeInsets.only(
                        top: 24.0, left: 24.0, right: 24.0),
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          final item = listData[index];
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(DateFormat('dd-MM-yyyy').format(
                                        DateTime.parse(item['datetime']))),
                                    IconButton(
                                        onPressed: () {
                                          _deleteData(item['id'].toString());
                                        },
                                        icon: Icon(
                                          Icons.delete_forever,
                                        ))
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Nama Rumah Sakit'),
                                    Text(item['health_center'])
                                  ],
                                ),
                                SizedBox(height: 9.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Nama Dokter'),
                                    Text(item['doctor'])
                                  ],
                                ),
                                SizedBox(height: 9.h),
                                Text('Hasil Analisis Dokter'),
                                Text(item['analysis_results']),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 9.h);
                        },
                        itemCount: listData.length),
                  ),
      ),
    );
  }
}
