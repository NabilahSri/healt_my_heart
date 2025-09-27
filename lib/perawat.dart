import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Perawat extends StatefulWidget {
  const Perawat({super.key});

  @override
  State<Perawat> createState() => _PerawatState();
}

class _PerawatState extends State<Perawat> {
  bool isLoading = false;
  List dataPerawat = [];
  Future<void> _showPerawat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    final Request = await http.get(Uri.parse(Koneksi().baseUrl + 'paramedics'),
        headers: {'Authorization': 'Bearer $access_token'});
    if (Request.statusCode == 200) {
      final response = jsonDecode(Request.body);
      if (mounted) {
        setState(() {
          dataPerawat = response;
        });
      }
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Gagal mengambil data perawat',
      );
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _showPerawat();
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
            'Daftar Perawat/Petugas',
            style: TextStyle(fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? SpinKitChasingDots(
                color: Color(0xFFFF5A5F),
              )
            : Padding(
                padding:
                    const EdgeInsets.only(right: 12.0, left: 12.0, top: 12.0),
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      final item = dataPerawat[index];
                      return ListTile(
                        leading: CircleAvatar(),
                        title: Text(item['name']),
                        subtitle: Text(item['health_center']),
                        trailing: IconButton(
                          onPressed: () async {
                            final String phoneNumber = item['number_contact'];

                            String url = "https://wa.me/$phoneNumber";
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Tidak dapat membuka WhatsApp.")),
                              );
                            }
                          },
                          icon: FaIcon(FontAwesomeIcons.whatsapp),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemCount: dataPerawat.length),
              ),
      ),
    );
  }
}
