
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../viewModel/soundViewModel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import '../http/api.dart';

class HomeView extends StatefulWidget{
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>{

  Codec _codec = Codec.aacMP4;
  String _mPath = 'tau_file.mp4';
  bool recording = false;

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder!.openAudioSession();

    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      print('***********kIsWeb');
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        return;
      }
    }
  }

  @override
  void initState() {

    _mPlayer!.openAudioSession().then((value) {});
    openTheRecorder().then((value) {
      setState(() {});
    });
    super.initState();

   Future.delayed(const Duration(milliseconds: 200),(){
      _codec = Codec.pcm16WAV;
      _mPath = 'https://resource.51ptt.net/ai/temp/tmm_ai_welcome.wav';
      play();
    });
  }
  void play() {
    _mPlayer!.startPlayer(
        fromURI: _mPath,
        codec: _codec,
        whenFinished: () {
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void record() async {
    _codec = Codec.aacMP4;
    _mPath = 'tau_file.mp4';
    await _mRecorder!.startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: AudioSource.microphone,
    ).then((value) {
      setState(() {
        recording = true;
      });
    });
    // _mRecorder!.onProgress!.listen((e) {
    //   print('========processduration:'+e.duration.toString());
    //   print('========processdecibels:'+e.decibels.toString());
    // });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        recording = false;
      });
    });
    var path = await _mRecorder!.getRecordURL(path: _mPath);
    var file = await MultipartFile.fromFile(path!);
    var formData = FormData.fromMap({
      'file':file
    });
    var res = await Api.voiceToTextToSkip(formData);
    if(res.code == '10000'){
      var data = {
        "isNativePage":res.res["nativePage"],
        "url":res.res["url"]
      };
      Fluttertoast.showToast(msg: '恭喜你获取成功！');
      print(data);
    }else{
      var msg = res.msg;
      Fluttertoast.showToast(msg: msg);
    }
    print(res);
  }

  void navPopUp(){
   var canpop = Navigator.canPop(context);
   if(canpop){
     Navigator.pop(context);
   }
  }

  @override
  Widget build(BuildContext context){
    return Center(
      child: AspectRatio(
        aspectRatio: 3/2,
        child: Container(
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Row(
            children: [
              Expanded(flex: 2,child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Image.network('https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ptt/images/ai_logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color:Colors.grey)
                    ),

                    child: Text('小助手正在听',style: TextStyle(
                      color: Colors.white,
                    ),
                      textAlign: TextAlign.center,

                    ),
                  )
                ],
              )),
              Expanded(flex: 3,child: Container(
                child:Row(
                  children: [
                    SizedBox(
                      width: 3,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          navPopUp();
                        },
                        child: Text('Play')),
                    SizedBox(
                      width: 20,
                    ),
                    // 一般播放和录音没啥关系
                    ElevatedButton(
                        onPressed: () {
                          if (recording) {
                            stopRecorder();
                          } else {
                            record();
                          }
                        },
                        child: Text(recording ? 'Stop' : 'Record'))
                  ],
                ),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Container(child: Text('你可以这样说',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 16,
                //       ),
                //     )),
                //     SizedBox(
                //       height: 20,
                //     ),
                //     // 一般播放和录音没啥关系
                //     Container(child: Text( '“我想要活酵母”',
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 22,
                //           fontWeight: FontWeight.bold
                //       ),
                //     )),
                //   ],
                // ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('***********dispose');
    if(_mRecorder!.isRecording){
      stopRecorder();
    }
    if(_mPlayer!.isPlaying){
      _mPlayer!.stopPlayer();
    }
    super.dispose();
  }
}