import 'dart:async';
// import 'dart:ffi';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

// import '../common/constant.dart';
// import '../http/api.dart';
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
  bool _startSuccess = false;
  final recordStart = 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/image_recorder_start.png';
  final recordPause = 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/image_recorder_pause.png';
  final gifImage = 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/ai_play.gif';
  final _voiceIcon = 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/icon_voice.png';
  final _clearImage = 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/icon_clear.png';
  var _recording = false;
  late Timer _recordTimer;//录音计时器
  int _seconds = 0 ;//计时秒数
  String _showTimeStr = '00:00';
  String? _audioFile;//录音文件
  String? _audioFilePath;//录音本地路径

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecord();
    _player = AudioPlayer();
    //计时器开启
    recordTimerStart();
  }

  Future<void> audioPlay(String? url) async {

    if (_player.playing) {
      _player.stop();
    }
    print('********audioPlay0');
    if(url != null){
      print('********audioPlay1:'+url);
      await _player.setFilePath(url);
      await _player.play();
      print('********audioPlay');
    }
  }

  recordTimerStart(){
    _recordTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      final isRecording = await _audioRecorder.isRecording();
      if(isRecording){
        _seconds = _seconds + 1;
        int second = _seconds % 60;
        var minutes = _seconds ~/ 60;
        String secondStr = second.toString();
        String minuteStr = minutes.toString();
        if(second<10){
          secondStr = '0' + secondStr;
        }
        if(minutes<10){
          minuteStr = '0' + minuteStr;
        }
        this.setState(() {
          _showTimeStr = minuteStr + ':' + secondStr;
        });

      };
    });
  }

  Future<void> startRecord() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        print('******startRecord0');
        final filePath = await createFileGetPath(
          fileName: 'tstAudio${DateTime.now().millisecondsSinceEpoch}.m4a',
          dirName: 'audio',
          tempFile: true,
        );
        await _audioRecorder.start(
          path: filePath,
        );
        _audioFilePath = filePath.toString();
        _startSuccess = true;
        print('******_audioFilePath:' + _audioFilePath!);
        this.setState(() {
          _recording = true;
        });
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
      this.setState(() {
        _recording = false;
      });

    }else if(isPaused){
      //恢复录音
      await _audioRecorder.resume();
      this.setState(() {
        _recording = true;
      });
    }else{
      //开始录音
      startRecord();
    }
  }

  Future<void> uploadAudioFile() async {

    if (_audioFile != null && _audioFile!.isNotEmpty) {

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
    }else if(_startSuccess){

      final path = await _audioRecorder.stop();
      if(path != null){
        this.setState(() {
          _audioFile = path;
        });
        print('***********_audioPath:'+_audioFile!);
      }else{
        print('***********_audioPathnull');
      }
      _startSuccess = false;
      this.setState(() {
        _recording = false;
      });

    } else {

    }
  }

  //删除录音
  audioFileClearHandler(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text('确定删除录音文件？'),
        actions: [
          TextButton(
              onPressed: (){

              },
              child: Text('取消')
          ),
          TextButton(
              onPressed: (){
                if(_audioFile != null){
                  this.setState(() {
                    _audioFile = null;
                  });
                }
              },
              child: Text('确定')
          ),
        ],
      );
    });
  }

  audioPlayHandler(){
    audioPlay(_audioFilePath);
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
                  const Text('1.请保持环境安静，语音清晰',
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

              Visibility(
                  visible: _audioFile != null,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Color(0xffaaaaaa),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize:MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: audioPlayHandler,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(_voiceIcon,
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(width: 5,height: 5,),
                              Text('01:08',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white
                                ),
                              ),
                              SizedBox(width: 5,height: 5,),
                              Container(width: 1,height: 15,color: Colors.white,),
                              SizedBox(width: 5,height: 5,),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: audioFileClearHandler,
                          child: Image.network(_clearImage,
                            width: 15,
                            height: 15,
                          ),
                        )

                      ],
                    ),
                  ),
              ),
              SizedBox(
                width: 200,
                height: 10,
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
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child:  Text(_showTimeStr,
                      style: TextStyle(fontSize: 18,color: Colors.white,overflow:TextOverflow.clip),
                      maxLines: 1,
                    ),
                  ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child:
                        Visibility(
                          visible: _recording,
                          child: Image.network(
                            gifImage,
                            width: 150,
                            height: 50,
                          ),
                        ),
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          InkWell(
                            child: Image.network(
                              _recording ? recordPause : recordStart,
                              width: 85,
                              height: 85,
                            ),
                            onTap: recorderButtonClickHandler,
                          ),
                          Text(_recording ? '点击暂停录音':'点击开始录音',
                            style: TextStyle(fontSize: 14,color: Colors.white),
                            maxLines: 1,
                          ),
                        ],
                      ),
                      flex: 3,
                    ),
                  SizedBox(
                    width: 200,
                    height: 15,
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
                          _audioFile != null ? '开始训练' : '完成录音',
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

    //移除录音计时
    if(_recordTimer != null && _recordTimer.isActive){
      _recordTimer.cancel();
    }


    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (_startSuccess) {
          final isPaused = await _audioRecorder.isPaused();
          if (isPaused) {
            _audioRecorder.resume();
          }
        }
        // log('进入前台');
        break;
      case AppLifecycleState.inactive:
      // log('进入后台');
        if (_startSuccess) {
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
