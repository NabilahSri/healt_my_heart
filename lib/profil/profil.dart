import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/auth/masuk.dart';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/home/catatan_pemeriksaan.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:health_my_heart/profil/aktivitas_harian.dart';
import 'package:health_my_heart/profil/riwayat_penyakit.dart';
import 'package:health_my_heart/profil/ubah_alamat.dart';
import 'package:health_my_heart/profil/ubah_kata_sandi.dart';
import 'package:health_my_heart/profil/ubah_profil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  bool isLoading = false;
  Map<dynamic, dynamic>? dataUser;
  String? usia;
  File? _image;
  String foto = '';
  Future<void> _showUser() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.get(
      Uri.parse(Koneksi().baseUrl + 'users/' + iduser!),
      headers: {'Authorization': 'Bearer $access_token'},
    );
    if (request.statusCode == 200) {
      final response = jsonDecode(request.body);
      final date_of_birth = response['date_of_birth'];
      DateTime dob = DateTime.parse(date_of_birth);
      int year = DateTime.now().year - dob.year;
      int month = DateTime.now().month - dob.month;
      if (month < 0 || (month == 0 && DateTime.now().day < dob.day)) {
        year--;
      }
      if (mounted) {
        setState(() {
          dataUser = response;
          usia = year.toString();
        });
        log(dataUser!['profile_image'].toString());
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final request = await http.get(
      Uri.parse(Koneksi().baseUrl + 'logout'),
      headers: {'Authorization': 'Bearer $access_token'},
    );
    if (request.statusCode == 200) {
      await prefs.remove('access_token');
      await prefs.remove('iduser');
      await prefs.remove('isLoggedIn');
      await prefs.remove('loginTimestamp');
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Masuk()), (route) => false);
    }
  }

  Future<void> profileWithGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.MultipartRequest(
      'POST',
      Uri.parse(Koneksi().baseUrl + 'users/image/' + iduser!),
    );
    var file = await http.MultipartFile.fromPath('image', _image!.path);
    request.files.add(file);
    request.headers['Authorization'] = 'Bearer $access_token';
    var response = await request.send();
    if (response.statusCode == 200) {
      _showUser();
    }
  }

  Future<void> profileWithCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    final request = await http.MultipartRequest(
      'POST',
      Uri.parse(Koneksi().baseUrl + 'users/image/' + iduser!),
    );
    var file = await http.MultipartFile.fromPath('image', _image!.path);
    request.files.add(file);
    request.headers['Authorization'] = 'Bearer $access_token';
    var response = await request.send();
    if (response.statusCode == 200) {
      _showUser();
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
        backgroundColor: const Color(0xFFFF5A5F),
        body: isLoading
            ? SpinKitChasingDots(color: Colors.white)
            : Column(
                children: [
                  SizedBox(height: 50.h),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return Container(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Galeri'),
                                  onTap: () {
                                    // Implementasi mengambil gambar dari galeri
                                    Navigator.pop(context);
                                    profileWithGallery();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Kamera'),
                                  onTap: () {
                                    // Implementasi mengambil gambar dari kamera
                                    Navigator.pop(context);
                                    profileWithCamera();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: ClipOval(
                      child: dataUser?['profile_image'] == null
                          ? Icon(
                              Icons.person,
                              size: 96.sp,
                              color: Colors.white,
                            )
                          : Container(
                              width: 96.sp,
                              height: 96.sp,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(Koneksi().profileImage +
                                      dataUser!['profile_image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 9.h),
                  Text(
                    dataUser?['name'],
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp),
                  ),
                  Text(usia! + ' Tahun',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 50.h),
                  Expanded(
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 20),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 12.0,
                            left: 12.0,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Ubah Profil',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    subtitle: Text(
                                      'Ubah data diri anda',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UbahProfil()));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Ubah Kata Sandi',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    subtitle: Text(
                                      'Ubah kata sandi anda',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UbahKataSandi(),
                                            ));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Ubah Alamat',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    subtitle: Text(
                                      'Ubah data alamat tinggal anda',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UbahAlamat()));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Obat Anda',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    subtitle: Text(
                                      'Data obat yang anda konsumsi',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigationCustom(
                                                      id: 2,
                                                    )),
                                            (context) => false);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Aktivitas Harian',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    subtitle: Text(
                                      'monitoring aktivitas harian anda',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AktivitasHarian()));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Riwayat Penyakit',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    subtitle: Text(
                                      'Data riwayat penyakit anda',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RiwayatPenyakit()));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Riwayat Perawatan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp),
                                    ),
                                    subtitle: Text(
                                      'Data riwayat perawatan anda',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CatatanPemeriksaan()));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: Colors.black26)),
                                  child: ListTile(
                                    title: Text(
                                      'Keluar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                          color: Colors.red),
                                    ),
                                    subtitle: Text(
                                      'Keluar dari aplikasi MyHeart',
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_forward_ios,
                                          size: 15.sp),
                                      onPressed: () {
                                        _logout();
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 9.h),
                              ],
                            ),
                          ),
                        )),
                  ),
                ],
              ),
      ),
    );
  }
}
