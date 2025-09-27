import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddObat extends StatefulWidget {
  const AddObat({super.key});

  @override
  State<AddObat> createState() => _AddObatState();
}

class _AddObatState extends State<AddObat> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _namaObat = TextEditingController();
  final TextEditingController _instruksi = TextEditingController();

  List<String> selectedTimes = [];

  Future<void> _addObat() async {
    if (_namaObat.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Nama Obat Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (_instruksi.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Instruksi Tidak Boleh Kosong',
      );
      _btnController.reset();
      return;
    }
    if (selectedTimes.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'Pilih minimal satu waktu',
      );
      _btnController.reset();
      return;
    }

    if (_namaObat.text.isNotEmpty &&
        _instruksi.text.isNotEmpty &&
        selectedTimes.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');
      String? iduser = prefs.getString('iduser');

      log(_instruksi.text);

      final request = await http.post(
        Uri.parse(Koneksi().baseUrl + 'medicine'),
        body: jsonEncode({
          'name': _namaObat.text,
          'instruction': _instruksi.text,
          'time': selectedTimes,
          'users_id': iduser,
        }),
        headers: {
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json',
        },
      );

      if (request.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationCustom(id: 2)),
            (route) => false);
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Gagal menambahkan obat',
        );
        log(request.body);
      }
      _btnController.reset();
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
            'Tambah Obat',
            style: TextStyle(fontSize: 12.sp),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Input Nama Obat
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 194, 196),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 14.0),
                    child: TextFormField(
                      controller: _namaObat,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Nama Obat',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                // Input Instruksi
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
                      controller: _instruksi,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Instruksi/Cara minum obat',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                // Pilihan Jam
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 2),
                  itemCount: 17,
                  itemBuilder: (context, index) {
                    String jam =
                        (index + 6).toString().padLeft(2, '0') + ':00:00';
                    bool isSelected = selectedTimes.contains(jam);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedTimes.remove(jam);
                          } else {
                            selectedTimes.add(jam);

                            log(jam);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade200
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            jam,
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ),
                      ),
                    );
                  },
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
                    _addObat();
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
