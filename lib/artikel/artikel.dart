import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:health_my_heart/artikel/detail_artikel.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Artikel extends StatefulWidget {
  const Artikel({super.key});

  @override
  State<Artikel> createState() => _ArtikelState();
}

class _ArtikelState extends State<Artikel> {
  List dataArtikel = [];
  bool isLoading = false;
  Future<void> _showArtikel() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final request = await http.get(Uri.parse(Koneksi().baseUrl + 'articles'),
        headers: {'Authorization': 'Bearer $access_token'});
    final response = jsonDecode(request.body);
    if (request.statusCode == 200) {
      if (mounted) {
        setState(() {
          dataArtikel = response;
        });
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _showArtikel();
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
                'Daftar Artikel',
                style: TextStyle(fontSize: 12.sp),
              ),
              centerTitle: true,
            ),
            body: isLoading == true
                ? SpinKitChasingDots(
                    color: Color(0xFFFF5A5F),
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        top: 24.0, right: 12.0, left: 12.0),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final item = dataArtikel[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailArtikel(
                                          id: item['id'].toString(),
                                        )));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10.0), // Tambahkan radius di sini
                            child: Stack(
                              children: [
                                Image.network(
                                  Koneksi().artikelImage + item['thumbnail'],
                                  width: double.infinity,
                                  height: 150.h,
                                  fit: BoxFit.cover,
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.8),
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
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      item['title'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 9.h,
                        );
                      },
                      itemCount: dataArtikel.length,
                    ))));
  }
}
