import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:health_my_heart/obat/add_obat.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Obat extends StatefulWidget {
  const Obat({super.key});

  @override
  State<Obat> createState() => _ObatState();
}

class _ObatState extends State<Obat> {
  bool isLoading = false;
  List dataObat = [];

  Future<void> _showObat() async {
    if (isLoading) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.get(
      Uri.parse(Koneksi().baseUrl + 'medicine/group/' + iduser!),
      headers: {'Authorization': 'Bearer $access_token'},
    );
    if (request.statusCode == 200) {
      final response = jsonDecode(request.body);
      if (mounted) {
        setState(() {
          dataObat = response;
        });
      }
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Gagal mengambil data obat',
      );
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteObat(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final request = await http.delete(
      Uri.parse(Koneksi().baseUrl + 'medicine/' + id),
      headers: {'Authorization': 'Bearer $access_token'},
    );
    if (request.statusCode == 200) {
      _showObat();
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Data berhasil dihapus');
    } else {
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
    super.initState();
    _showObat();
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
            'Daftar Obat Saya',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddObat()));
                },
                icon: Icon(Icons.add_box))
          ],
          centerTitle: true,
        ),
        body: isLoading
            ? SpinKitChasingDots(color: Color(0xFFFF5A5F))
            : dataObat.isEmpty
                ? Center(child: Text('Tidak ada obat'))
                : Padding(
                    padding: const EdgeInsets.only(
                        right: 24.0, left: 24.0, top: 24.0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        final item = dataObat[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['time'],
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            ...item['obat'].map<Widget>((obat) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 50.h,
                                      child: VerticalDivider(
                                        color: Color(0xFFFF5A5F),
                                        thickness: 1,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            obat['name'],
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                          Text(obat['instruction'])
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.confirm,
                                          title: 'Konfirmasi',
                                          text:
                                              'Apakah anda yakin ingin menghapus data ini ?',
                                          confirmBtnText: 'Ya',
                                          cancelBtnText: 'Tidak',
                                          onConfirmBtnTap: () {
                                            _deleteObat(obat['id'].toString());
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.delete),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                      itemCount: dataObat.length,
                    ),
                  ),
      ),
    );
  }
}
