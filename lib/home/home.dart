import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/artikel/detail_artikel.dart';
import 'package:health_my_heart/auth/masuk.dart';
import 'package:health_my_heart/component/bottom_navigation_custom.dart';
import 'package:health_my_heart/home/catatan_pemeriksaan.dart';
import 'package:health_my_heart/home/gejala_kegawatan.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:health_my_heart/profil/aktivitas_harian.dart';
import 'package:health_my_heart/splash_screen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _sessionTimer;
  List dataArtikel = [];
  Map<dynamic, dynamic>? dataUser;
  bool isLoadingUser = false;
  bool isLoadingArtikel = false;
  Future<void> _showArtikel() async {
    if (mounted) {
      setState(() {
        isLoadingArtikel = true;
      });
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? access_token = prefs.getString('access_token');

      final request = await http.get(
        Uri.parse(Koneksi().baseUrl + 'articles'),
        headers: {'Authorization': 'Bearer $access_token'},
      );

      if (request.statusCode == 200) {
        try {
          final response = jsonDecode(request.body);

          if (mounted) {
            setState(() {
              // Ambil hanya 3 data teratas
              dataArtikel = response.take(3).toList();
            });
          }
          log('Data Artikel: ' + dataArtikel.toString());
        } catch (e) {
          log('Error parsing JSON: $e');
          // Jika respons bukan JSON, arahkan ke halaman login
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Masuk(),
              ),
              (route) => false);
        }
      } else {
        // Jika status kode bukan 200, arahkan ke halaman login
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Masuk(),
            ),
            (route) => false);
      }
    } catch (e) {
      log('Error fetching data: $e');
      // Jika ada error koneksi atau lainnya, arahkan ke halaman login
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Masuk(),
          ),
          (route) => false);
    }

    if (mounted) {
      setState(() {
        isLoadingArtikel = false;
      });
    }
  }

  Future<void> _showUser() async {
    setState(() {
      isLoadingUser = true;
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
      if (mounted) {
        setState(() {
          dataUser = response;
        });
        log('Data User: ' + dataUser!['profile_image'].toString());
      }
    }
    if (mounted) {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  void _startSessionChecker() {
    _sessionTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final loginTimestamp = prefs.getInt('loginTimestamp') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      const sessionDuration = 3 * 60 * 60 * 1000; // 3 jam dalam milidetik
      if ((currentTime - loginTimestamp) > sessionDuration) {
        // Sesi habis, logout otomatis
        await prefs.remove('isLoggedIn');
        await prefs.remove('loginTimestamp');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        }
      }
    });
  }

  @override
  void initState() {
    _startSessionChecker();
    _showArtikel();
    _showUser();
    super.initState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel(); // Pastikan timer dihentikan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => Scaffold(
          body: isLoadingArtikel == false && isLoadingUser == false
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset('assets/images/background.jpg',
                          fit: BoxFit.contain, alignment: Alignment.topCenter),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: const Color.fromARGB(255, 248, 202, 204)
                            .withOpacity(0.8),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            title: Text(
                              dataUser?['name'] ?? '',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            actions: [
                              IconButton(
                                icon: const Icon(
                                  Icons.help,
                                  size: 24,
                                ),
                                onPressed: () {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.info,
                                    text:
                                        'APLKASI HEALTMYHEART adalah aplikasi yang diciptakan sebagai selft report atau pemantauan mandiri pasien gagal jantung yang telah menjalani perawatan ataupun yang belum supaya tidak terjadi rawat berulang atau komplikasi yang lebih berat.',
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const BottomNavigationCustom(
                                                  id: 4,
                                                )),
                                        (route) => false);
                                  },
                                  child: ClipOval(
                                    child: dataUser?['profile_image'] == null
                                        ? Icon(
                                            Icons.person,
                                            size: 40.sp,
                                            color: Colors.white,
                                          )
                                        : Container(
                                            width: 40.sp,
                                            height: 40.sp,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(Koneksi()
                                                        .profileImage +
                                                    dataUser!['profile_image']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            width: 140.w,
                            alignment: Alignment.center,
                            child: Text(
                              'SELAMAT DATANG DI CARINGMYHEART',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 78, 11, 11),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Container(
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
                                    right: 12.0, left: 12.0, top: 24.0),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.info,
                                            title: 'Management Perawatan Diri',
                                            text: '1. Batasi konsumsi sodium\n'
                                                '2. Batasi minum\n'
                                                '3. Hindari alkohol\n'
                                                '4. Minum obat sesuai resep\n'
                                                '5. Berhenti merokok\n'
                                                '6. Tidur cukup\n'
                                                '7. Beraktifitas sesuai anjuran\n'
                                                '8. Segera kontrol jika ada perubahan mendadak\n',
                                          );
                                        },
                                        child: ListTile(
                                          leading: Icon(Icons.manage_history),
                                          title: Text(
                                            'MANAGEMENT PERAWATAN DIRI',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp),
                                          ),
                                          subtitle: Text(
                                            'Kenali cara perawatan diri yang baik',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 9.h),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GejalaKegawatan(),
                                            ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5A5F)
                                              .withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: ListTile(
                                          leading: Icon(Icons.warning),
                                          title: Text(
                                            'MONITORING TANDA-TANDA KEGAWATAN',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp),
                                          ),
                                          subtitle: Text(
                                            'Kenali tanda-tanda kegawaran',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 9.h),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AktivitasHarian()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5A5F)
                                              .withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: ListTile(
                                          leading: Icon(Icons.notes),
                                          title: Text(
                                            'MONITORING MANAGEMENT PERAWATAN DIRI',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp),
                                          ),
                                          subtitle: Text(
                                            'Update aktifitas konsumsi minuman dan peningkatan berat badan anda',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 9.h),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const CatatanPemeriksaan()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.lightBlue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: ListTile(
                                          leading: Icon(Icons.edit_document),
                                          title: Text(
                                            'CATATAN PEMERIKSAAN',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp),
                                          ),
                                          subtitle: Text(
                                            'Daftar hasil pemeriksaan terakhir anda',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Hal Yang Perlu Diperhatikan',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BottomNavigationCustom(
                                                          id: 1,
                                                        )),
                                                (context) => false);
                                          },
                                          child: Text(
                                            'semua >',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        )
                                      ],
                                    ),
                                    ListView.separated(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final item = dataArtikel[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailArtikel(
                                                          id: item['id']
                                                              .toString(),
                                                        )));
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                10.0), // Tambahkan radius di sini
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  Koneksi().artikelImage +
                                                      item['thumbnail'],
                                                  width: double.infinity,
                                                  height: 150.h,
                                                  fit: BoxFit.cover,
                                                ),
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(0.8),
                                                          Colors.transparent
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                      item['title'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(
                                          height: 9.h,
                                        );
                                      },
                                      itemCount: dataArtikel.length,
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                )
              : SpinKitChasingDots(color: Color(0xFFFF5A5F))),
    );
  }
}
