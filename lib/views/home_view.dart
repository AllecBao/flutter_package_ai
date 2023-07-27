import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

import '../http/api.dart';
import '../model/sound_model.dart';
import '../utils/file_util.dart';

class HomeView extends StatefulWidget {
  final int? time;

  const HomeView({Key? key, this.time}) : super(key: key);

  @override
  createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  Timer? _ampTimer;
  Amplitude? _amplitude;
  int stopCount = 0;
  int validCount = 0;//有效语音时长
  int talkTime = 0;
  bool startSuccess = false;
  final _player = AudioPlayer();

  // final audioStart =
  //     'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ai/audios/sound_start.wav';
  final audioStart = 'assets/audio/sound_start.wav';

  // final audioEnd =
  //     'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ai/audios/sound_end.mp3';
  int recording = 1; // 0:录音处理中 1:正在录音 2:录音失败

  late String imageBg;

  @override
  void initState() {
    super.initState();
    imageBg =
        'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ptt/images/img_aidialog_bg.png?time=${widget.time ?? DateTime.now().millisecondsSinceEpoch}';
    // print('------>>>>>>>>$imageBg');
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback( (timeStamp) async {
      await audioPlay(audioStart);
      record();
    });
  }



  Future<void> audioPlay(String url) async {
    _player.stop();
    await _player.setAsset(
      url,
      package: 'ptt_ai_package',
    );
    // await _player.setUrl(url);
    await _player.play();
  }

  Future<void> record() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        _ampTimer?.cancel();
        final filePath = await createFileGetPath(
          fileName: 'tstAudio${DateTime.now().millisecondsSinceEpoch}.m4a',
          dirName: 'audio',
          tempFile: true,
        );
        await _audioRecorder.start(
          path: filePath,
        );
        startSuccess = true;
        stopCount = 0;
        validCount = 0;
        talkTime = 0;
        _ampTimer =
            Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {

            talkTime++;
            if (talkTime > 11 * 5) {
              talkTime = 0;
              stopRecorder();
              return;
            }
          _amplitude = await _audioRecorder.getAmplitude();

          final amplitudeCurrent = _amplitude?.current;
          // print('*********value:$amplitudeCurrent');
          if (amplitudeCurrent != null) {
            if (amplitudeCurrent < -26) {
              if(validCount<5){
                validCount = 0;
              }
              stopCount++;
              if(validCount>5){
                if (stopCount >= 7) {
                  stopCount = 0;
                  stopRecorder();
                }
              }
            } else {
              validCount++;
              stopCount = 0;
            }
          }
        });
      } else {
        Fluttertoast.showToast(msg: '请开启麦克风权限', gravity: ToastGravity.CENTER)
            .then((value) {
          var nav = Navigator.of(context);
          nav.pop({'errorMsg': '麦克风权限未打开', 'errorType': '1'});
        });
      }
    } catch (e) {
      // print('------>>>>>>>>e$e');
      if (e.runtimeType == PlatformException) {
        Fluttertoast.showToast(msg: '请开启麦克风权限', gravity: ToastGravity.CENTER)
            .then((value) {
          var nav = Navigator.of(context);
          nav.pop({'errorMsg': '麦克风权限未打开', 'errorType': '1'});
        });
      }
    }
  }

  void stopRecorder() async {
    var nav = Navigator.of(context);
    _ampTimer?.cancel();
    final String? path = await _audioRecorder.stop();

    if(validCount<5){
      setState(() {
        recording = 2;
      });
      Future.delayed(const Duration(seconds: 1)).then((value) {
        setState(() {
          recording = 1;
        });
        record();
      });
      return;
    }
    // audioPlay(audioEnd);
    if (path != null && path.isNotEmpty) {
      var file = await dio.MultipartFile.fromFile(path);
      var formData = dio.FormData.fromMap({'file': file});

      setState(() {
        recording = 0;
      });
      var resp = await Api.voiceToTextToSkip(formData);
      var res = resp.data;
      // print(res);
      if (res["code"] == '10000') {
        SoundModel soundRes = SoundModel.fromJson(res["res"]);
        var data = {"isNativePage": soundRes.nativePage, "url": soundRes.url};
        if (soundRes.url != null && soundRes.url?.isNotEmpty == true) {
          recording = 0;
          nav.pop(data);
        } else {
          recording = 2;
        }
        setState(() {});
        if (recording == 2) {
          Future.delayed(const Duration(seconds: 2)).then((value) {
            setState(() {
              recording = 1;
            });
            record();
          });
        }

        // print(data);
      } else {
        setState(() {
          recording = 2;
        });
        // Fluttertoast.showToast(
        //     msg: res['msg'] ?? '服务出了点问题...', gravity: ToastGravity.CENTER);
        Future.delayed(const Duration(seconds: 2)).then((value) {
          setState(() {
            recording = 1;
          });
          record();
        });
      }
    } else {
      nav.pop({'errorMsg': '录音出错', 'errorType': '0'});
    }
  }

  void navPopUp() {
    var canPop = Navigator.canPop(context);
    if (canPop) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            image: DecorationImage(
              // image: AssetImage(
              //   'assets/images/img_aidialog_bg.png',
              //   package: 'ptt_ai_package',
              // ),
              // image: NetworkImage(
              //     'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ptt/images/img_aidialog_bg.png?time=${widget.time ??  DateTime.now().millisecondsSinceEpoch}',),
              image: CachedNetworkImageProvider(imageBg),
            ),
          ),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 33),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(),
                  ),
                  Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            right: 20,
                            child: GestureDetector(
                              onTap: () {
                                // stopRecorder();
                                navPopUp();
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                color: const Color(0x00000001),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '你可以这样说',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                 const FittedBox(
                                   child:  Text(
                                     '“庭妹妹,我想要活酵母”',
                                     style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 18,
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (recording == 1)
                                  Image.asset(
                                    'assets/images/ai_play.gif',
                                    package: 'ptt_ai_package',
                                    height: 35,
                                    fit: BoxFit.contain,
                                  )
                                else if (recording == 0)
                                  Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: const [
                                        CupertinoActivityIndicator(
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '处理中...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  const Center(
                                    child: Text(
                                      '没找到您想要的结果',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                 Center(
                                    child: GestureDetector(
                                      onTap: (){
                                          validCount=5;
                                          stopRecorder();
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          height: 38,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(19),
                                              gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: recording==1 ? [
                                                    Color(0x9912336a),
                                                    Color(0x9906ced9),
                                                    ] : [
                                                    Color(0x7712336a),
                                                    Color(0x7706ced9),
                                                  ]
                                              )
                                          ),
                                          child: Center(
                                            child: Text('完成',
                                              style: TextStyle(
                                                color: recording==1 ? Colors.white:Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                      ),
                                    ),
                                )
                              ],
                            ),
                          ),

                        ],
                      )),
                  const SizedBox(width: 5,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('******dispose');
    _audioRecorder.dispose();
    _ampTimer?.cancel();
    _player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (startSuccess) {
          record();
        }
        // print('------>>>>>>>>resumed进入前台');
        break;
      case AppLifecycleState.inactive:
        // print('------>>>>>>>>inactive进入后台');
        if (startSuccess) {
          try {
            final isRecording = await _audioRecorder.isRecording();
            if (isRecording) {
              stopRecorder();
            }
          } catch (_) {}
        }
        break;
      case AppLifecycleState.paused:
        // print('------>>>>>>>>paused应用暂停');
        break;
      case AppLifecycleState.detached:
        // print('------>>>>>>>>detached');
        break;
    }
  }
}
