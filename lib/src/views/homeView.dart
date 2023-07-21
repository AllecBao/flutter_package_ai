import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

import '../http/api.dart';
import '../model/soundModel.dart';
import '../utils/file_util.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  Timer? _ampTimer;
  Amplitude? _amplitude;
  int stopCount = 0;
  int talkTime = 0;
  final _player = AudioPlayer();
  final audioStart =
      'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ai/audios/sound_start.wav';
  final audioEnd =
      'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ai/audios/sound_end.mp3';
  int recording = 1; // 0:录音处理中 1:正在录音 2:录音失败

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    record();
    super.initState();
  }

  Future<void> audioPlay(String url) async {
    _player.stop();
    await _player.setUrl(url);
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
        await audioPlay(audioStart);
        await _audioRecorder.start(
          path: filePath,
        );
        _ampTimer =
            Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
          talkTime++;
          if (talkTime > 15 * 5) {
            talkTime = 0;
            stopRecorder();
            return;
          }
          _amplitude = await _audioRecorder.getAmplitude();
          final amplitudeCurrent = _amplitude?.current;
          if (amplitudeCurrent != null) {
            if (amplitudeCurrent < -30) {
              stopCount++;
              if (stopCount >= 8) {
                stopCount = 0;
                stopRecorder();
              }
            } else {
              stopCount = 0;
            }
          }

          print(
              '----->>>>>>>>${DateTime.now().millisecondsSinceEpoch}------>>>>${_amplitude?.current}');
        });
      } else {
        Fluttertoast.showToast(msg: '请开启麦克风权限', gravity: ToastGravity.CENTER);
      }
    } catch (e) {}
  }

  void stopRecorder() async {
    var nav = Navigator.of(context);
    _ampTimer?.cancel();
    final String? path = await _audioRecorder.stop();
    // audioPlay(audioEnd);
    if (path != null && path.isNotEmpty) {
      var file = await MultipartFile.fromFile(path);
      var formData = FormData.fromMap({'file': file});

      setState(() {
        recording = 0;
      });
      var resp = await Api.voiceToTextToSkip(formData);
      var res = resp.data;
      print(res);
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

        print(data);
      } else {
        recording = 2;
        setState(() {});
        if (recording == 2) {
          Future.delayed(const Duration(seconds: 2)).then((value) {
            setState(() {
              recording = 1;
            });
            record();
          });
        }
        Fluttertoast.showToast(
            msg: res['msg'] ?? '服务出了点问题...', gravity: ToastGravity.CENTER);
        record();
      }
    } else {
      nav.pop({'errorMsg': '录音出错'});
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
    return Center(
      child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            image: DecorationImage(
              image: NetworkImage(
                  'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ptt/images/img_aidialog_bg.png'),
            ),
          ),
          child: AspectRatio(
            aspectRatio: 3 / 2,
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
                        Column(
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
                            // 一般播放和录音没啥关系
                            const Text(
                              '“我想要活酵母”',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (recording == 1)
                              Center(
                                child: Image.network(
                                  'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ptt/images/audio_record.gif',
                                  height: 35,
                                  fit: BoxFit.contain,
                                ),
                              )

                            // Image.asset(
                            //   'asset/ai_play.gif',
                            //   height: 35,
                            //   fit: BoxFit.contain,
                            // )
                            else if (recording == 0)
                              Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
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
                            // const SizedBox(
                            //   height: 10,
                            // ),
                          ],
                        )
                      ],
                    )),
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
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
        record();
        print('------>>>>>>>>resumed进入前台');
        break;
      case AppLifecycleState.inactive:
        print('------>>>>>>>>inactive进入后台');
        final isRecording = await _audioRecorder.isRecording();
        if (isRecording) {
          stopRecorder();
        }
        break;
      case AppLifecycleState.paused:
        print('------>>>>>>>>paused应用暂停');
        break;
      case AppLifecycleState.detached:
        print('------>>>>>>>>detached');
        break;
    }
  }
}
