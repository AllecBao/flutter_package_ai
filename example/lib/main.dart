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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showMainView(
                      context,
                      time: 12345678,
                      isDebug: true,
                      audioText:'谢谢您选择我们的产品，愿它为您带来持久的美丽，祝您永远保持健康与光彩！',
                    );
                  },
                  child: const Text('点击弹出AI'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
