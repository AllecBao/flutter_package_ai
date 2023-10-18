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
                      type: 1,
                      time: 12345678,
                      isDebug: true,
                      openVolume: true,
                      promptText: '“庭妹妹，请带我了解一下本月爆款”',
                      audioTextArray:[
                        '1111谢谢您选择我们的产品，愿它为您带来持久的美丽，祝您永远保持健康与光彩！',
                        '感谢您购买我们的产品，希望它能让您更漂亮噢！祝您拥有美好的一天！',
                        '3333亲亲，感谢您的支持，愿我们的产品能令您焕发出独特的魅力，祝您美丽动人！',
                        '4444嗨，很高兴被你选中！非常感谢你的购买，祝你每天喜笑颜开！',
                        '5555亲爱的，感谢你为自己的美丽投资！衷心希望我们能让你每一天都光彩照人、自信满满！',
                      ],
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
