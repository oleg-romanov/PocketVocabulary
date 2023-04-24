// ignore_for_file: public_member_api_docs, avoid_print
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

class ScanTextScreen extends StatefulWidget {
  const ScanTextScreen({super.key});

  @override
  _ScanTextScreenState createState() => _ScanTextScreenState();
}

class _ScanTextScreenState extends State<ScanTextScreen> {
  String text = "";
  final StreamController<String> controller = StreamController<String>();

  void setText(value) {
    controller.add(value);
    text = value;
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  void _completeButtonTapped() {
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Сканирование"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ScalableOCR(
                  paintboxCustom: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4.0
                    ..color = const Color.fromARGB(153, 102, 160, 241),
                  boxLeftOff: 5,
                  boxBottomOff: 2.5,
                  boxRightOff: 5,
                  boxTopOff: 2.5,
                  boxHeight: MediaQuery.of(context).size.height / 3,
                  getRawData: (value) {
                    inspect(value);
                  },
                  getScannedText: (value) {
                    setText(value);
                  }),
              Container(
                width: double.infinity,
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: _completeButtonTapped,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.lightGreen),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Colors.white),
                  ),
                  child: const Text(
                    'Готово',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16.0),
              //   child: SizedBox(
              //     height: 50.0,
              //     child: T
              //   ),
              // ),
              // TextButton(
              //   onPressed: _completeButtonTapped,
              //   style: ButtonStyle(
              //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //       RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16.0),
              //       ),
              //     ),
              //     // padding: const MaterialStatePropertyAll<EdgeInsets>(
              //     //   EdgeInsets.symmetric(horizontal: 46.0, vertical: 16.0),
              //     // ),
              //     padding: EdgeInsets.symmetric(horizontal: 16),
              //     backgroundColor:
              //         const MaterialStatePropertyAll<Color>(Colors.blue),
              //     foregroundColor:
              //         const MaterialStatePropertyAll<Color>(Colors.white),
              //   ),
              //   child: SizedBox(
              //     height: 50.0,
              //     child: ,
              //   )const Text('Готово'),
              // ),
              StreamBuilder<String>(
                stream: controller.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return Result(
                      text: snapshot.data != null ? snapshot.data! : "");
                },
              )
            ],
          ),
        ));
  }
}

class Result extends StatelessWidget {
  const Result({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Text(
        "Readed text: $text",
        style: const TextStyle(fontSize: 26),
      ),
    );
  }
}
