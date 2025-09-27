import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UbahProfil extends StatefulWidget {
  const UbahProfil({super.key});

  @override
  State<UbahProfil> createState() => _UbahProfilState();
}

class _UbahProfilState extends State<UbahProfil> {
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _dokterPelayananDasar = TextEditingController();
  final TextEditingController _rumahSakitKontrol = TextEditingController();
  final TextEditingController _pilihTanggal = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  bool isLoading = false;
  Map<String, dynamic> dataUser = {};
  String? _selectedGender;
  Future<void> _showUser() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.get(
      Uri.parse(Koneksi().baseUrl + 'users/' + iduser!),
      headers: {'Authorization': 'Bearer $access_token'},
    );
    if (request.statusCode == 200) {
      final response = jsonDecode(request.body);
      if (mounted) {
        if (mounted) {
          setState(() {
            dataUser = response;
            _nama.text = dataUser['name'];
            _pilihTanggal.text = DateFormat('dd-MM-yyyy').format(
              DateTime.parse(dataUser['date_of_birth']),
            );
            _selectedGender = dataUser['sex'];
            _email.text = dataUser['email'];
            _dokterPelayananDasar.text = dataUser['primary_care_doctor'] ?? '';
            _rumahSakitKontrol.text = dataUser['control_health_care'] ?? '';
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUser() async {
    if (_nama.text.isNotEmpty &&
        _pilihTanggal.text.isNotEmpty &&
        _selectedGender != null &&
        _email.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');
      String? iduser = prefs.getString('iduser');
      final tanggalInput = DateFormat('dd-MM-yyyy').parse(_pilihTanggal.text);
      final tanggalLahir = DateFormat('yyyy-MM-dd').format(tanggalInput);
      final request = await http.put(
        Uri.parse(Koneksi().baseUrl + 'users/' + iduser!),
        body: {
          'name': _nama.text,
          'date_of_birth': tanggalLahir,
          'sex': _selectedGender,
          'email': _email.text,
          'primary_care_doctor': _dokterPelayananDasar.text,
          'control_health_care': _rumahSakitKontrol.text
        },
        headers: {'Authorization': 'Bearer $access_token'},
      );
      if (request.statusCode == 200) {
        _btnController.success();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigationCustom(id: 4)),
              (route) => false);
        });
        _btnController.reset();
      } else {
        _btnController.error();
        Timer(const Duration(seconds: 1), () {
          _btnController.reset();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: 'Data gagal diubah',
          );
        });
      }
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Data tidak boleh kosong',
        );
      });
      _btnController.reset();
    }
  }

  @override
  void initState() {
    _showUser();
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
                  'Ubah Profil',
                  style: TextStyle(fontSize: 12.sp),
                ),
                centerTitle: true,
              ),
              body: isLoading
                  ? SpinKitChasingDots(
                      color: Color(0xFFFF5A5F),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: 24.0, right: 12.0, left: 12.0),
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
                                child: TextFormField(
                                  controller: _nama,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    hintText: 'Masukan Nama Anda',
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 9.h),
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
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 16.0),
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
                                    DateTime? selectedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100),
                                    );

                                    if (selectedDate != null) {
                                      _pilihTanggal.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(selectedDate);
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      controller: _pilihTanggal,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.date_range),
                                        hintText: 'Pilih Tanggal Lahir',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 16.0),
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
                                  child: const Text('Laki-laki'),
                                ),
                                RadioMenuButton(
                                  value: 'P',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  },
                                  child: const Text('Perempuan'),
                                ),
                              ],
                            ),
                            Divider(),
                            SizedBox(height: 9.h),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 250, 194, 196),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 14.0),
                                child: TextFormField(
                                  controller: _dokterPelayananDasar,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.personal_injury),
                                    hintText: 'Dokter Pelayanan Dasar',
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 9.h),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 250, 194, 196),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 14.0),
                                child: TextFormField(
                                  controller: _rumahSakitKontrol,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    hintText: 'Rumah Sakit Kontrol',
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            // Tombol Masuk
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
                                _updateUser();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ));
  }
}
