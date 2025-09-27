import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailArtikel extends StatefulWidget {
  final String id;
  const DetailArtikel({super.key, required this.id});

  @override
  State<DetailArtikel> createState() => _DetailArtikelState();
}

class _DetailArtikelState extends State<DetailArtikel> {
  Map<String, dynamic>? artikel;
  bool isLoading = false;
  Future<void> artikelById() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    final request = await http.get(
        Uri.parse(
            Uri.parse(Koneksi().baseUrl + 'articles/' + widget.id).toString()),
        headers: {'Authorization': 'Bearer $access_token'});
    if (request.statusCode == 200) {
      final response = jsonDecode(request.body);
      if (mounted) {
        setState(() {
          artikel = response;
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
    artikelById();
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
            'Detail Artikel',
            style: TextStyle(fontSize: 12.sp),
          ),
          centerTitle: true,
        ),
        body: isLoading == true
            ? SpinKitChasingDots(color: Color(0xFFFF5A5F))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Image.network(
                      Koneksi().artikelImage + artikel!['thumbnail'],
                      height: 150.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24.0, left: 12.0, right: 12.0),
                      child: Column(
                        children: [
                          Text(
                            artikel!['title'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          HtmlWidget(
                            artikel!['text'],
                            // webView:
                            //     true, // Jika tabel kompleks, aktifkan WebView
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
