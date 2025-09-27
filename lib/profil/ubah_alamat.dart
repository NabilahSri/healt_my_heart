import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UbahAlamat extends StatefulWidget {
  const UbahAlamat({super.key});

  @override
  State<UbahAlamat> createState() => _UbahAlamatState();
}

class _UbahAlamatState extends State<UbahAlamat> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  bool isLoading = false;
  Map<String, dynamic> dataUser = {};
  final TextEditingController _alamat = TextEditingController();
  final TextEditingController _kecamatan = TextEditingController();
  final TextEditingController _kota = TextEditingController();
  final TextEditingController _provinsi = TextEditingController();
  List<dynamic> jsonData = [];
  List<Map<String, String>> allKecamatan = [];
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
            _alamat.text = dataUser['complete_address'];
            _kecamatan.text = dataUser['district'];
            _kota.text = dataUser['city'];
            _provinsi.text = dataUser['province'];
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final response = await http
        .put(Uri.parse(Koneksi().baseUrl + 'users/' + iduser!), headers: {
      'Authorization': 'Bearer $access_token'
    }, body: {
      'complete_address': _alamat.text,
      'district': _kecamatan.text,
      'city': _kota.text,
      'province': _provinsi.text,
    });
    if (response.statusCode == 200) {
      _btnController.success();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationCustom(id: 4)),
            (route) => false);
      });
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 1), () {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Gagal Mengubah Alamat',
        );
      });
      _btnController.reset();
    }
    log(response.body);
  }

  Future<void> loadJsonData() async {
    String jsonString =
        await rootBundle.loadString('assets/json/indonesia-region.min.json');
    setState(() {
      jsonData = json.decode(jsonString);
      loadAllKecamatan();
    });
  }

  void loadAllKecamatan() {
    allKecamatan.clear();
    for (var province in jsonData) {
      for (var regency in province['regencies']) {
        for (var district in regency['districts']) {
          allKecamatan.add({
            'kecamatan': district['name'],
            'kota': regency['name'],
            'provinsi': province['name'],
          });
        }
      }
    }
  }

  void _showKecamatanBottomSheet() {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, String>> filteredKecamatan = List.from(allKecamatan);

    void filterKecamatan(String query) {
      if (mounted) {
        setState(() {
          filteredKecamatan = allKecamatan
              .where((kecamatan) => kecamatan['kecamatan']!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 24.0, left: 12.0, right: 12.0),
                child: Column(
                  children: [
                    // Input Search
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 250, 194, 196),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 14.0),
                        child: TextFormField(
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            setModalState(() {
                              filterKecamatan(value);
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Cari Kecamatan',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 16.0),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 12.h),
                    // Daftar Kecamatan
                    Expanded(
                      child: filteredKecamatan.isNotEmpty
                          ? ListView.separated(
                              itemCount: filteredKecamatan.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    filteredKecamatan[index]['kecamatan']!,
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                  subtitle: Text(
                                    '${filteredKecamatan[index]['kota']} - ${filteredKecamatan[index]['provinsi']}',
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        _kecamatan.text =
                                            filteredKecamatan[index]
                                                ['kecamatan']!;
                                        _kota.text =
                                            filteredKecamatan[index]['kota']!;
                                        _provinsi.text =
                                            filteredKecamatan[index]
                                                ['provinsi']!;
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider();
                              },
                            )
                          : Center(
                              child: Text(
                                "Kecamatan tidak ditemukan",
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    _showUser();
    loadJsonData();
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
                  'Ubah Alamat',
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
                            EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
                        child: Column(
                          children: [
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
                                  controller: _alamat,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    hintText: 'Masukan Alamat Anda',
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 9.h),
                            GestureDetector(
                              onTap: _showKecamatanBottomSheet,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 250, 194, 196),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 14.0),
                                  child: TextFormField(
                                    controller: _kecamatan,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      hintText: 'Kecamatan',
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                    ),
                                    style: const TextStyle(
                                      color: Colors
                                          .black, // Warna teks tetap hitam meskipun nonaktif
                                    ),
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
                                  controller: _kota,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Kota',
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
                                  controller: _provinsi,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Provinsi',
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
