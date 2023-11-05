import 'dart:async';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

import '../common/constant.dart';
import '../http/api.dart';
import '../utils/file_util.dart';
import '../utils/log_util.dart';

class RecorderView extends StatefulWidget {

  const RecorderView({
    Key? key
  }) : super(key: key);

  @override
  createState() => _RecorderViewState();
}

class _RecorderViewState extends State<RecorderView> with WidgetsBindingObserver {
  late FlutterSoundRecord _audioRecorder;
  late AudioPlayer _player;
  bool startSuccess = false;
  final recordStart = 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/image_recorder_start.png';
  final recordPause = 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/image_recorder_pause.png';
  var recording = false;
  late Timer recordTimer;//录音计时器
  int seconds = 0 ;//计时秒数
  String showTimeStr = '00:00';

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecord();
    _player = AudioPlayer();
  }

  Future<void> audioPlay(String url) async {
    if (_player.playing) {
      _player.stop();
    }
    await _player.setAsset(
      url,
      package: 'ptt_ai_package',
    );
    await _player.play();
  }

  recordTimerStart(){
    recordTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      final isRecording = await _audioRecorder.isRecording();
      if(isRecording){
        seconds ++ ;
        int second = seconds % 60;
        var minutes = seconds ~/ 60;
        String secondStr = second.toString();
        String minuteStr = minutes.toString();
        if(second<10){
          secondStr = '0' + secondStr;
        }
        if(minutes<10){
          minuteStr = '0' + minuteStr;
        }
        showTimeStr = minuteStr + ':' + secondStr;
      };
    });
  }

  Future<void> startRecord() async {
    try {
      if (await _audioRecorder.hasPermission()) {

        final filePath = await createFileGetPath(
          fileName: 'tstAudio${DateTime.now().millisecondsSinceEpoch}.m4a',
          dirName: 'audio',
          tempFile: true,
        );
        await _audioRecorder.start(
          path: filePath,
        );
        startSuccess = true;
        recording = true;
      } else {
        Fluttertoast.showToast(msg: '请开启麦克风权限', gravity: ToastGravity.CENTER)
            .then((value) {
          navPopUp({'errorMsg': '麦克风权限未打开', 'errorType': '1'});
        });
      }
    } catch (e) {
      log('$e');
      if (e.runtimeType == PlatformException) {
        Fluttertoast.showToast(msg: '请开启麦克风权限', gravity: ToastGravity.CENTER)
            .then((value) {
          navPopUp({'errorMsg': '麦克风权限未打开', 'errorType': '1'});
        });
      }
    }
  }

  //点击录音按钮
  recorderButtonClickHandler() async {
    final isRecording = await _audioRecorder.isRecording();
    final isPaused = await _audioRecorder.isPaused();
    if(isRecording){
      //暂停
      await _audioRecorder.pause();
      recording = false;
    }else if(isPaused){
      //恢复录音
      await _audioRecorder.resume();
      recording = true;
    }else{
      //开始录音
      startRecord();
    }
  }

  Future<void> uploadAudioFile() async {

    final String? path = await _audioRecorder.stop();
    recording = false;
    startSuccess = false;
    if (path != null && path!.isNotEmpty) {
      audioPlay(path!);
      // var file = await dio.MultipartFile.fromFile(path!);
      // var formData = dio.FormData.fromMap({'file': file});
      //
      // var resp =
      // await Api.voiceToTextToSkip(formData);
      // if (resp == null || resp.data == null) {
      //   log('resp:$resp---resp.data:${resp.data}');
      //   return;
      // }
      // var res = resp.data;
      // log(res);
      // if (res["code"] == '10000') {
      //
      //   // log(data);
      // } else {
      //
      // }
    } else {
      navPopUp({'errorMsg': '录音出错', 'errorType': '0'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(

        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: navPopUp,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 30,
                  color:Colors.white,
                ),
              ),
              Expanded(flex: 5,child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: const Text('录音时，请朗读以下内容',
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white)
                    ),
                  ),
                  const Text('1.请保持环境安静，口吃清晰',
                      style: TextStyle(fontSize: 13,color: CupertinoColors.systemGrey)
                  ),
                  const Text('2.录制声音3-5分钟，中途可以点击暂停休息调整',
                      style: TextStyle(fontSize: 13,color: CupertinoColors.systemGrey)
                  ),
                  SizedBox(
                    width: 200,
                    height: 15,
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: [
                         Text('这款产品是一款帮助皮肤迅速补水的绝佳护肤品，它还有很多护肤品中都没有的法国榆木内芽成分，可以加速肌肤新陈代谢。其中的变性乙醇成分，清洁效果很好。轻松改善暗沉肤色，让皮肤充分补水，达到干净透亮的效果。保湿水对皮肤的包容性特别强，它没有一丁点的酒精和矿物油成分，不管什么皮肤的姐妹都可以放心使用。这款产品是一款帮助皮肤迅速补水的绝佳护肤品，它还有很多护肤品中都没有的法国榆木内芽成分，可以加速肌肤新陈代谢。其中的变性乙醇成分，清洁效果很好。轻松改善暗沉肤色，让皮肤充分补水，达到干净透亮的效果。保湿水对皮肤的包容性特别强，它没有一丁点的酒精和矿物油成分，不管什么皮肤的姐妹都可以放心使用。',
                          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),
                        )
                      ],
                    ),
                  )
                ],
              ),
              ),
              SizedBox(
                width: 200,
                height: 15,
              ),
              Expanded(
                flex: 6,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Text('—  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —',
                      style: TextStyle(fontSize: 13,color: Colors.white,overflow:TextOverflow.clip),
                      maxLines: 1,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child:  Text(showTimeStr,
                          style: TextStyle(fontSize: 18,color: Colors.white,overflow:TextOverflow.clip),
                          maxLines: 1,
                        ),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          InkWell(
                            child: Image.network(
                              recording ? recordPause : recordStart,
                              width: 140,
                              height: 140,
                            ),
                            onTap: recorderButtonClickHandler,
                          ),
                          Text(recording ? '点击暂停录音':'点击开始录音',
                            style: TextStyle(fontSize: 14,color: Colors.white),
                            maxLines: 1,
                          ),
                        ],
                      ),
                      flex: 3,
                    ),
                  SizedBox(
                    width: 200,
                    height: 20,
                  ),
                    InkWell(
                      onTap: uploadAudioFile,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Color(0xff432AD3)
                        ),
                        height: 48,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          '开始训练',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                ],
              ),),


            ],

          ),
        ),
      )
    );
  }



  @override
  void dispose() {
    _audioRecorder.dispose();
    if (_player.playing) {
      _player.stop();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (startSuccess) {
          final isPaused = await _audioRecorder.isPaused();
          if (isPaused) {
            _audioRecorder.resume();
          }
        }
        // log('进入前台');
        break;
      case AppLifecycleState.inactive:
      // log('进入后台');
        if (startSuccess) {
          try {
            final isRecording = await _audioRecorder.isRecording();
            if (isRecording) {
              _audioRecorder.pause();
            }
          } catch (_) {}
        }
        break;
      case AppLifecycleState.paused:
      // log('应用暂停');
        break;
      case AppLifecycleState.detached:
      // log('detached');
        break;
    // case AppLifecycleState.hidden:
    //   break;
    }
  }

  void navPopUp([Map? result]) {
    if (mounted) {
      Navigator.pop(context, [result]);
    }
  }
}
