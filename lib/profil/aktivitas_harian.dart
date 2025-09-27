import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:health_my_heart/profil/add_aktivitas_harian.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AktivitasHarian extends StatefulWidget {
  const AktivitasHarian({super.key});

  @override
  State<AktivitasHarian> createState() => _AktivitasHarianState();
}

class _AktivitasHarianState extends State<AktivitasHarian> {
  bool isLoading = false;
  List dataAktivitas = [];
  Future<void> _showData() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.get(
        Uri.parse(Koneksi().baseUrl + 'activity/user/' + iduser!),
        headers: {'Authorization': 'Bearer $access_token'});
    if (request.statusCode == 200) {
      final response = jsonDecode(request.body);
      if (mounted) {
        setState(() {
          dataAktivitas = response;
        });
      }
    } else {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal',
          text: 'Gagal mengambil data aktivitas harian');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final request = await http.delete(
        Uri.parse(Koneksi().baseUrl + 'activity/' + id),
        headers: {'Authorization': 'Bearer $access_token'});
    if (request.statusCode == 200) {
      _showData();
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
    initializeDateFormatting('id_ID', null).then((_) {
      _showData(); // Panggil setelah inisialisasi selesai
    });
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
                'Aktivitas Harian',
                style: TextStyle(fontSize: 12.sp),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddAktivitasHarian()));
                    },
                    icon: Icon(Icons.add_box))
              ],
            ),
            body: isLoading
                ? SpinKitChasingDots(
                    color: Color(0xFFFF5A5F),
                  )
                : dataAktivitas.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      )
                    : ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          final item = dataAktivitas[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 12.0,
                                  left: 12.0,
                                  right: 12.0,
                                  bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('dd MMMM yyyy', 'id_ID')
                                          .format(DateTime.parse(
                                              item['created_at']))),
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
                                                _deleteData(
                                                    item['id'].toString());
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                          icon: Icon(Icons.delete_forever)),
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text('Tekanan darah harian')),
                                      Expanded(
                                        child: Text(item['tekanan_darah'],
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child:
                                              Text('Berat badan (per 3 hari)')),
                                      Expanded(
                                        child: Text(item['berat_badan'],
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                            'Jumlah cairan yang masuk (per hari)'),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(item['jml_cairan'],
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text('Aktivitas harian')),
                                      Expanded(
                                        flex: 3,
                                        child: Text(item['aktivitas'],
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text('Intake makanan harian')),
                                      Expanded(
                                        flex: 3,
                                        child: Text(item['makanan'],
                                            textAlign: TextAlign.end),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: dataAktivitas.length,
                      )));
  }
}
