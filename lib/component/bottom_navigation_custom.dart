import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/artikel/artikel.dart';
import 'package:health_my_heart/home/home.dart';
import 'package:health_my_heart/obat/obat.dart';
import 'package:health_my_heart/perawat.dart';
import 'package:health_my_heart/profil/profil.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavigationCustom extends StatefulWidget {
  final int id;
  const BottomNavigationCustom({super.key, required this.id});

  @override
  State<BottomNavigationCustom> createState() => _BottomNavigationCustomState();
}

class _BottomNavigationCustomState extends State<BottomNavigationCustom> {
  late int index;
  @override
  void initState() {
    super.initState();
    setState(() {
      index = widget.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 50.h,
        child: SalomonBottomBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 255, 198, 200),
          backgroundColor: const Color(0xFFFF5A5F),
          items: [
            SalomonBottomBarItem(
              icon: Icon(
                Icons.home,
                size: 18.h,
              ),
              title: Text("Beranda"),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.article,
                size: 18.h,
              ),
              title: Text("Artikel"),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.medical_information,
                size: 18.h,
              ),
              title: Text("Obat"),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.add_box,
                size: 18.h,
              ),
              title: Text("Perawat"),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.person,
                size: 18.h,
              ),
              title: Text("Profil"),
            ),
          ],
          currentIndex: index,
          onTap: (selectedIndex) {
            setState(() {
              index = selectedIndex;
            });
          },
        ),
      ),
      body: getSelectedWidget(index: index),
    );
  }

  Widget getSelectedWidget({required int index}) {
    Widget widget;
    switch (index) {
      case 0:
        widget = const Home();
        break;
      case 1:
        widget = const Artikel();
        break;
      case 2:
        widget = const Obat();
        break;
      case 3:
        widget = Perawat();
        break;
      case 4:
        widget = Profil();
        break;
      default:
        widget = const Home();
    }
    return widget;
  }
}
