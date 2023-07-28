import 'package:flutter/material.dart';

import 'package:ptt_ai_package/common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: InkWell(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: const Text('点击弹出ai')),
              onTap: () async {
                showMainView(
                  context,
                  time: 12345678,
                  isDebug: true,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
