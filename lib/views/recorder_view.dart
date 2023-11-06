import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ptt_ai_package/common/constant.dart';

import '../http/api.dart';
import '../utils/file_util.dart';
import '../utils/log_util.dart';

class RecorderView extends StatefulWidget {
  final double scaleWidth;
  final String? recordExampleText;
  final String userId;

  const RecorderView({
    Key? key,
    this.scaleWidth = 1,
    this.recordExampleText,
    required this.userId,
  }) : super(key: key);

  @override
  createState() => _RecorderViewState();
}

class _RecorderViewState extends State<RecorderView>
    with WidgetsBindingObserver {
  CancelToken cancelToken = CancelToken();
  double scaleWidth = 1;
  late FlutterSoundRecord _audioRecorder;
  late AudioPlayer _player;
  bool _startSuccess = false;
  final recordStart =
      'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/image_recorder_start.png';
  final recordPause =
      'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/image_recorder_pause.png';
  final gifImage =
      'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/ai_play.gif';
  final _voiceIcon =
      'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/icon_voice.png';
  final _clearImage =
      'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/coolella/images/icon_clear.png';
  var _recording = false;
  late Timer _recordTimer; //录音计时器
  int _seconds = 0; //计时秒数
  String _showTimeStr = '00:00';
  String? _audioFile; //录音文件数据流
  String? _audioFilePath; //录音本地路径

  @override
  void initState() {
    super.initState();
    scaleWidth = widget.scaleWidth;
    _audioRecorder = FlutterSoundRecord();
    _player = AudioPlayer();
    //计时器开启
    recordTimerStart();
  }

  Future<void> audioPlay(String? url) async {
    if (_player.playing) {
      _player.stop();
    }
    log('********audioPlay0');
    if (url != null) {
      log('********audioPlay1:$url');
      await _player.setFilePath(url);
      await _player.play();
      log('********audioPlay');
    }
  }

  recordTimerStart() {
    _recordTimer =
        Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      final isRecording = await _audioRecorder.isRecording();
      final isPaused = await _audioRecorder.isPaused();
      // log('------isRecording:$isRecording');
      // log('------isRecording:$isPaused');
      if (isRecording && !isPaused) {
        _seconds = _seconds + 1;
        int second = _seconds % 60;
        var minutes = _seconds ~/ 60;
        String secondStr = second.toString();
        String minuteStr = minutes.toString();
        if (second < 10) {
          secondStr = '0$secondStr';
        }
        if (minutes < 10) {
          minuteStr = '0$minuteStr';
        }
        setState(() {
          _showTimeStr = '$minuteStr:$secondStr';
        });
      }
    });
  }

  Future<void> startRecord() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        log('******startRecord0');
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
        log('******_audioFilePath:${_audioFilePath!}');
        setState(() {
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
    if (isRecording) {
      if (isPaused) {
        //恢复录音
        await _audioRecorder.resume();
        setState(() {
          _recording = true;
        });
      } else {
        //暂停
        await _audioRecorder.pause();
        setState(() {
          _recording = false;
        });
      }
    } else {
      //开始录音
      startRecord();
    }
  }

  Future<void> uploadAudioFile() async {
    if (_audioFile != null && _audioFile!.isNotEmpty) {
      var file = await MultipartFile.fromFile(_audioFile!);
      var formData = FormData.fromMap({'audio_file': file});
      try {
        var resp = await Api.audioModelTrain(
          formData,
          userId: widget.userId,
          cancelToken: cancelToken,
        );
        if (resp == null || resp.data == null) {
          log('resp:$resp---resp.data:${resp.data}');
          return;
        }
        var res = resp.data;
        log(res);
        if (res["code"] == '10000') {
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          Fluttertoast.showToast(
              msg: res["msg"] ?? '请求失败,请稍后再试', gravity: ToastGravity.CENTER);
        }
      } catch (e) {
        log('>>>>>>error<<<$e');
      }
    } else if (_startSuccess) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        // setState(() {
        _audioFile = path;
        // });
        log('***********_audioPath:${_audioFile!}');
      } else {
        log('***********_audioPathnull');
      }
      _startSuccess = false;
      setState(() {
        _recording = false;
      });
    } else {}
  }

  //删除录音
  audioFileClearHandler() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('确定删除录音文件？'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消')),
              TextButton(
                  onPressed: () {
                    if (_audioFile != null) {
                      setState(() {
                        _audioFile = null;
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: const Text('确定')),
            ],
          );
        });
  }

  audioPlayHandler() {
    audioPlay(_audioFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(10 * scaleWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: navPopUp,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 30 * scaleWidth,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 15 * scaleWidth),
                        child: Text(Constant.recordExampleText1,
                            style: TextStyle(
                                fontSize: 15 * scaleWidth,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Text(Constant.recordExampleText2,
                          style: TextStyle(
                              fontSize: 13 * scaleWidth,
                              color: CupertinoColors.systemGrey)),
                      Text(Constant.recordExampleText3,
                          style: TextStyle(
                              fontSize: 13 * scaleWidth,
                              color: CupertinoColors.systemGrey)),
                      SizedBox(
                        width: 200 * scaleWidth,
                        height: 15 * scaleWidth,
                      ),
                      Expanded(
                        flex: 1,
                        child: ListView(
                          children: [
                            Text(
                              widget.recordExampleText ??
                                  Constant.recordExampleText4,
                              style: TextStyle(
                                  fontSize: 14 * scaleWidth,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
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
                    padding: EdgeInsets.all(5 * scaleWidth),
                    margin: EdgeInsets.only(top: 15 * scaleWidth),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4 * scaleWidth),
                      color: const Color(0xffaaaaaa),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: audioPlayHandler,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                _voiceIcon,
                                width: 20 * scaleWidth,
                                height: 20 * scaleWidth,
                              ),
                              SizedBox(
                                width: 5 * scaleWidth,
                                height: 5 * scaleWidth,
                              ),
                              Text(
                                _showTimeStr,
                                style: TextStyle(
                                    fontSize: 12 * scaleWidth,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                width: 5 * scaleWidth,
                                height: 5 * scaleWidth,
                              ),
                              Container(
                                width: 1 * scaleWidth,
                                height: 15 * scaleWidth,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5 * scaleWidth,
                                height: 5 * scaleWidth,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: audioFileClearHandler,
                          child: Image.network(
                            _clearImage,
                            width: 15 * scaleWidth,
                            height: 15 * scaleWidth,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 200 * scaleWidth,
                  height: 10 * scaleWidth,
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '—  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —',
                        style: TextStyle(
                            fontSize: 13 * scaleWidth,
                            color: Colors.white,
                            overflow: TextOverflow.clip),
                        maxLines: 1,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20 * scaleWidth),
                        child: Text(
                          _showTimeStr,
                          style: TextStyle(
                              fontSize: 18 * scaleWidth,
                              color: Colors.white,
                              overflow: TextOverflow.clip),
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(top: 20 * scaleWidth),
                          child: Visibility(
                            visible: _recording,
                            child: Image.network(
                              gifImage,
                              width: 150 * scaleWidth,
                              height: 50 * scaleWidth,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: recorderButtonClickHandler,
                              child: Image.network(
                                _recording ? recordPause : recordStart,
                                width: 85 * scaleWidth,
                                height: 85 * scaleWidth,
                              ),
                            ),
                            Text(
                              _recording ? '点击暂停录音' : '点击开始录音',
                              style: TextStyle(
                                  fontSize: 14 * scaleWidth,
                                  color: Colors.white),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200 * scaleWidth,
                        height: 15 * scaleWidth,
                      ),
                      InkWell(
                        onTap: uploadAudioFile,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(24 * scaleWidth),
                              color: const Color(0xff432AD3)),
                          height: 48,
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            _audioFile != null ? '开始训练' : '完成录音',
                            style: TextStyle(
                              fontSize: 18 * scaleWidth,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    if (_player.playing) {
      _player.stop();
    }
    _player.dispose();

    //移除录音计时
    if (_recordTimer.isActive) {
      _recordTimer.cancel();
    }
    cancelToken.cancel();
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
