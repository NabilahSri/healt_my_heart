// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:quickalert/quickalert.dart';
// import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

// class GejalaKegawatan extends StatefulWidget {
//   const GejalaKegawatan({super.key});

//   @override
//   State<GejalaKegawatan> createState() => _GejalaKegawatanState();
// }

// class _GejalaKegawatanState extends State<GejalaKegawatan> {
//   final RoundedLoadingButtonController _btnController =
//       RoundedLoadingButtonController();

//   List<bool> checkboxStatus = List.generate(12, (index) => false);
//   List<bool> additionalQuestion1 = [false, false];
//   List<bool> additionalQuestion2 = [false, false];

//   final List<int> zonaMerah = [9, 10, 11]; // Indeks checkbox untuk zona merah

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//         designSize: const Size(360, 690),
//         builder: (context, child) => Scaffold(
//               appBar: AppBar(
//                 backgroundColor: const Color(0xFFFF5A5F),
//                 foregroundColor: Colors.white,
//                 title:
//                     Text('Gejala Kegawatan', style: TextStyle(fontSize: 12.sp)),
//                 centerTitle: true,
//               ),
//               body: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Checklist tanda-tanda kegawatan yang anda rasakan.',
//                         style: TextStyle(
//                             fontSize: 11.sp, fontWeight: FontWeight.bold),
//                       ),
//                       for (int i = 0; i < checkboxStatus.length; i++) ...[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 '${i + 1}. ${_getPertanyaan(i)}',
//                                 style: TextStyle(
//                                     fontSize: 11.sp,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Checkbox(
//                               value: checkboxStatus[i],
//                               onChanged: (bool? value) {
//                                 setState(() {
//                                   checkboxStatus[i] = value ?? false;

//                                   if (i == 0) {
//                                     additionalQuestion1 = value == true
//                                         ? [false, false]
//                                         : [false, false];
//                                   }
//                                   if (i == 1) {
//                                     additionalQuestion2 = value == true
//                                         ? [false, false]
//                                         : [false, false];
//                                   }
//                                 });
//                               },
//                             )
//                           ],
//                         ),
//                         if (i == 0 && checkboxStatus[i]) ...[
//                           _buildAdditionalQuestion1(
//                               0, "Napas terasa berat saat tidur terlentang?"),
//                           _buildAdditionalQuestion1(1,
//                               "Napas tidak membaik saat tidur menggunakan beberapa bantal atau duduk di kursi?"),
//                         ],
//                         if (i == 1 && checkboxStatus[i]) ...[
//                           _buildAdditionalQuestion2(0,
//                               "Nyeri dada yang tidak hilang dengan istirahat dan obat-obatan"),
//                         ],
//                       ],
//                       SizedBox(height: 9.h),
//                       RoundedLoadingButton(
//                         valueColor: Colors.black38,
//                         successColor: Colors.green,
//                         height: 40.h,
//                         color: const Color(0xFFFF5A5F),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.save,
//                               color: Colors.black,
//                               size: 20.w,
//                             ),
//                             SizedBox(width: 10.w),
//                             const Text(
//                               "SIMPAN",
//                               style: TextStyle(color: Colors.black),
//                             ),
//                           ],
//                         ),
//                         controller: _btnController,
//                         onPressed: () {
//                           _cekZona();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ));
//   }

//   String _getPertanyaan(int index) {
//     const pertanyaan = [
//       "Ada sesak nafas",
//       "Ada nyeri dada, ketidaknyamanan di dada",
//       "Ada pembengkakan atau ada meningkat pembengkakan di kaki, pergelangan kaki, tungkai dan abdomen",
//       "Ada peningkatan BB > 2 Kg dalam 2 hari atau > 2,5 Kg dalam 1 minggu",
//       "Muntah-muntah atau diare > 2 hari",
//       "Merasa lebih lelah dan tidak punya tenaga saat aktifitas",
//       "Merasa pusing",
//       "Mengalami batuk kering",
//       "Perasaan tidak nyaman pada tubuh",
//       "Detak jantung cepat dan tidak melambat saat istirahat",
//       "Kesulitan berpikir jernih dan perasaan bingung",
//       "Mengalami pingsan"
//     ];
//     return pertanyaan[index];
//   }

//   Widget _buildAdditionalQuestion1(int index, String question) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 24.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(question,
//                 style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
//           ),
//           Checkbox(
//             value: additionalQuestion1[index],
//             onChanged: (bool? value) {
//               setState(() {
//                 additionalQuestion1[index] = value ?? false;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdditionalQuestion2(int index, String question) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 24.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(question,
//                 style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
//           ),
//           Checkbox(
//             value: additionalQuestion2[index],
//             onChanged: (bool? value) {
//               setState(() {
//                 additionalQuestion2[index] = value ?? false;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _cekZona() {
//     bool merah = false;
//     bool kuning = false;

//     for (int i = 0; i < checkboxStatus.length; i++) {
//       if (checkboxStatus[i]) {
//         if (zonaMerah.contains(i)) {
//           merah = true;
//         } else {
//           kuning = true;
//         }
//       }
//     }

//     // Cek pertanyaan tambahan
//     if (additionalQuestion1[0]) {
//       // Pertanyaan tambahan pertama dianggap zona kuning
//       kuning = true;
//     }
//     if (additionalQuestion1[1] || additionalQuestion2.contains(true)) {
//       merah = true; // Pertanyaan tambahan lainnya tetap zona merah
//     }

//     if (!merah && !kuning) {
//       _showAlert(QuickAlertType.success, "Keterangan", "Terkontrol");
//     } else if (merah) {
//       _showAlert(
//           QuickAlertType.error, "Ketarangan", "Hubungi Petugas Kesehatan");
//     } else if (kuning) {
//       _showAlert(QuickAlertType.warning, "Keterangan",
//           "Datang ke UGD atau Hubungi 119");
//     }

//     _btnController.reset();
//   }

//   void _showAlert(QuickAlertType type, String title, String message) {
//     QuickAlert.show(
//       context: context,
//       type: type,
//       title: title,
//       text: message,
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_my_heart/koneksi/connection.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GejalaKegawatan extends StatefulWidget {
  const GejalaKegawatan({super.key});

  @override
  State<GejalaKegawatan> createState() => _GejalaKegawatanState();
}

class _GejalaKegawatanState extends State<GejalaKegawatan> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  List<bool> checkboxStatus = List.generate(12, (index) => false);
  List<bool> additionalQuestion1 = [false, false];
  List<bool> additionalQuestion2 = [false, false];

  final List<int> zonaMerah = [9, 10, 11]; // Indeks checkbox untuk zona merah

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF5A5F),
          foregroundColor: Colors.white,
          title: Text('Gejala Kegawatan', style: TextStyle(fontSize: 12.sp)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checklist tanda-tanda kegawatan yang anda rasakan.',
                  style:
                      TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                ),
                for (int i = 0; i < checkboxStatus.length; i++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${i + 1}. ${_getPertanyaan(i)}',
                          style: TextStyle(
                              fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Checkbox(
                        value: checkboxStatus[i],
                        onChanged: (bool? value) {
                          setState(() {
                            checkboxStatus[i] = value ?? false;
                            // Reset pertanyaan tambahan sesuai dengan pilihan
                            if (i == 0) {
                              additionalQuestion1 = value == true
                                  ? [false, false]
                                  : [false, false];
                            }
                            if (i == 1) {
                              additionalQuestion2 = value == true
                                  ? [false, false]
                                  : [false, false];
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (i == 0 && checkboxStatus[i]) ...[
                    _buildAdditionalQuestion1(
                        0, "Napas terasa berat saat tidur terlentang?"),
                    _buildAdditionalQuestion1(1,
                        "Napas tidak membaik saat tidur menggunakan beberapa bantal atau duduk di kursi?"),
                  ],
                  if (i == 1 && checkboxStatus[i]) ...[
                    _buildAdditionalQuestion2(0,
                        "Nyeri dada yang tidak hilang dengan istirahat dan obat-obatan"),
                  ],
                ],
                SizedBox(height: 9.h),
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
                        "CEK GEJALA",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  controller: _btnController,
                  onPressed: () {
                    _cekZona();
                    _kirimData();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPertanyaan(int index) {
    const pertanyaan = [
      "Ada sesak nafas",
      "Ada nyeri dada, ketidaknyamanan di dada",
      "Ada pembengkakan atau ada meningkat pembengkakan di kaki, pergelangan kaki, tungkai dan abdomen",
      "Ada peningkatan BB > 2 Kg dalam 2 hari atau > 2,5 Kg dalam 1 minggu",
      "Muntah-muntah atau diare > 2 hari",
      "Merasa lebih lelah dan tidak punya tenaga saat aktifitas",
      "Merasa pusing",
      "Mengalami batuk kering",
      "Perasaan tidak nyaman pada tubuh",
      "Detak jantung cepat dan tidak melambat saat istirahat",
      "Kesulitan berpikir jernih dan perasaan bingung",
      "Mengalami pingsan"
    ];
    return pertanyaan[index];
  }

  Widget _buildAdditionalQuestion1(int index, String question) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(question,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
          ),
          Checkbox(
            value: additionalQuestion1[index],
            onChanged: (bool? value) {
              setState(() {
                additionalQuestion1[index] = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalQuestion2(int index, String question) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(question,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
          ),
          Checkbox(
            value: additionalQuestion2[index],
            onChanged: (bool? value) {
              setState(() {
                additionalQuestion2[index] = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  void _cekZona() {
    bool merah = false;
    bool kuning = false;

    for (int i = 0; i < checkboxStatus.length; i++) {
      if (checkboxStatus[i]) {
        if (zonaMerah.contains(i)) {
          merah = true;
        } else {
          kuning = true;
        }
      }
    }

    // Cek pertanyaan tambahan
    if (additionalQuestion1[0]) {
      // Pertanyaan tambahan pertama dianggap zona kuning
      kuning = true;
    }
    if (additionalQuestion1[1] || additionalQuestion2.contains(true)) {
      merah = true; // Pertanyaan tambahan lainnya tetap zona merah
    }

    if (!merah && !kuning) {
      _showAlert(QuickAlertType.success, "Keterangan", "Terkontrol");
    } else if (merah) {
      _showAlert(
          QuickAlertType.error, "Keterangan", "Datang ke UGD atau Hubungi 119");
    } else if (kuning) {
      _showAlert(
          QuickAlertType.warning, "Keterangan", "Hubungi Petugas Kesehatan");
    }

    _btnController.reset();
  }

  void _showAlert(QuickAlertType type, String title, String message) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: message,
    );
  }

  // Fungsi untuk mengirim data dalam format JSON
  Future<void> _kirimData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? access_token = prefs.getString('access_token');
    String? iduser = prefs.getString('iduser');
    List<Map<String, dynamic>> indications = [];
    for (int i = 0; i < checkboxStatus.length; i++) {
      indications.add({
        "name_indication": _getPertanyaan(i),
        "status": checkboxStatus[i] ? 1 : 0,
      });
    }
    for (int i = 0; i < additionalQuestion1.length; i++) {
      indications.add({
        "name_indication": i == 0
            ? "Napas terasa berat saat tidur terlentang?"
            : "Napas tidak membaik saat tidur menggunakan beberapa bantal atau duduk di kursi?",
        "status": additionalQuestion1[i] ? 1 : 0,
      });
    }
    for (int i = 0; i < additionalQuestion2.length; i++) {
      indications.add({
        "name_indication":
            "Nyeri dada yang tidak hilang dengan istirahat dan obat-obatan",
        "status": additionalQuestion2[i] ? 1 : 0,
      });
    }

    // JSON structure
    Map<String, dynamic> data = {
      "users_id": iduser,
      "indication": indications,
    };

    String jsonData = jsonEncode(data);

    // Tampilkan data JSON yang akan dikirim
    log(jsonData);

    final response = await http.post(
        Uri.parse(Koneksi().baseUrl + 'indication'),
        headers: {
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json'
        },
        body: jsonData);

    if (response.statusCode == 201) {
      _btnController.success();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
      });
    } else {
      log('RESPOMSE: ${response.body}');
      _btnController.error();
      Timer(const Duration(seconds: 1), () {
        _btnController.reset();
      });
    }
  }
}
