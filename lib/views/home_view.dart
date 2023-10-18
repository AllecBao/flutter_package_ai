import 'dart:async';

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
import '../model/audio_url_model.dart';
import '../model/sound_model.dart';
import '../utils/file_util.dart';
import '../utils/log_util.dart';

class HomeView extends StatefulWidget {
  final int type; //0:录音；1:播报语音
  final int? time;
  final bool isDebug;
  final double scaleWidth;
  final bool? openVolume;
  final String? promptText;
  final List<String>? audioTextArray;
  final String? imageBg;

  const HomeView({
    Key? key,
    required this.type,
    this.time,
    this.isDebug = false,
    this.scaleWidth = 1,
    this.openVolume,
    this.promptText,
    this.audioTextArray,
    this.imageBg,
  }) : super(key: key);

  @override
  createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  Timer? _ampTimer;
  Amplitude? _amplitude;
  int stopCount = 0;
  int validCount = 0; //有效语音时长
  int talkTime = 0;
  bool startSuccess = false;
  final _player = AudioPlayer();
  double scaleWidth = 1;
  final CancelToken _cancelToken = CancelToken();
  final audioStart = 'assets/audio/sound_start.wav';
  int recording = 1; // 0:录音处理中 1:正在录音 2:录音失败
  late String imageBg;
  BuildContext? buildContext;
  String? currentAudioText;
  bool openVolume = true; // 是否打开声音

  @override
  void initState() {
    super.initState();
    openVolume = widget.openVolume ?? true;
    scaleWidth = widget.scaleWidth;
    imageBg = widget.imageBg != null
        ? widget.imageBg!
        : 'https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ptt/images/img_aidialog_bg.png';
    if (!imageBg.contains('time=')) {
      imageBg =
          '$imageBg?time=${widget.time ?? DateTime.now().millisecondsSinceEpoch}';
    }
    log(imageBg);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      buildContext = context;
      if (widget.type == 1) {
        await audioToTextAndPlay();
      } else if (widget.type == 0) {
        await audioPlay(audioStart);
        record();
      }
    });
  }

  Future<void> audioPlay(String url,
      {bool isNet = false, bool isAutoClose = false}) async {
    if (_player.playing) {
      _player.stop();
    }
    if (isNet) {
      await _player.setUrl(url);
    } else {
      await _player.setAsset(
        url,
        package: 'ptt_ai_package',
      );
    }
    await _player.setVolume(openVolume ? 1 : 0);
    await _player.play();

    //播放完是否自动关闭
    if (isAutoClose && buildContext != null) {
      Navigator.pop(buildContext!);
    }
  }

  Future<void> audioToTextAndPlay() async {
    final audioTextArray = widget.audioTextArray;
    if (audioTextArray != null && audioTextArray.isNotEmpty) {
      final audioUrlArray =
          List<String?>.generate(audioTextArray.length, (_) => null);
      final pathList = <AudioUrlModel>[];
      for (int i = 0; i < audioTextArray.length; i++) {
        if (Constant.audioResource.containsKey(audioTextArray[i])) {
          audioUrlArray.setAll(i, [Constant.audioResource[audioTextArray[i]]]);
        } else {
          pathList.add(AudioUrlModel(index: i, path: audioTextArray[i]));
        }
      }
      final resList = await Api.textListToVoice(
          audioPathList: pathList, cancelToken: _cancelToken);
      if (resList != null) {
        for (var element in resList) {
          if (element.index != null) {
            audioUrlArray.setAll(element.index!, [element.path]);
          }
        }
      }
      for (var i = 0; i < audioUrlArray.length; i++) {
        var audioUrl = audioUrlArray[i];
        if (audioUrl != null) {
          setState(() {
            currentAudioText = audioTextArray[i];
          });
          await audioPlay(audioUrl,
              isNet: true, isAutoClose: (i + 1) == audioUrlArray.length);
        }
      }
    }
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
          // log('*********value:$amplitudeCurrent');
          if (amplitudeCurrent != null) {
            if (amplitudeCurrent < -24) {
              if (validCount < 5) {
                validCount = 0;
              }
              if (validCount > 5) {
                stopCount++;
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
      log('$e');
      if (e.runtimeType == PlatformException) {
        Fluttertoast.showToast(msg: '请开启麦克风权限', gravity: ToastGravity.CENTER)
            .then((value) {
          var nav = Navigator.of(context);
          nav.pop({'errorMsg': '麦克风权限未打开', 'errorType': '1'});
        });
      }
    }
  }

  Future<void> stopRecorder() async {
    var nav = Navigator.of(context);
    _ampTimer?.cancel();
    final String? path = await _audioRecorder.stop();

    if (validCount < 5) {
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
      var resp =
          await Api.voiceToTextToSkip(formData, cancelToken: _cancelToken);
      if (resp == null || resp.data == null) {
        log('resp:$resp---resp.data:${resp.data}');
        return;
      }
      var res = resp.data;
      log(res);
      if (res["code"] == '10000') {
        SoundModel soundRes = SoundModel.fromJson(res["res"]);
        var data = {"isNativePage": soundRes.nativePage, "url": soundRes.url};
        if (soundRes.wavUrl != null && soundRes.wavUrl?.isNotEmpty == true) {
          //如果需要播放语音，先播放语音
          await audioPlay(soundRes.wavUrl!, isNet: true);
        }
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

        // log(data);
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
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10 * scaleWidth),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imageBg),
                  ),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: InkWell(
                onTap: () {},
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 18 * scaleWidth, vertical: 33 * scaleWidth),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  openVolume = !openVolume;
                                });
                                _player.setVolume(openVolume ? 1 : 0);
                              },
                              child: Icon(
                                openVolume
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                size: 30 * scaleWidth,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                child: SizedBox(
                                  width: 46 * scaleWidth,
                                  height: 26 * scaleWidth,
                                ),
                              ),
                            ),
                            if (widget.type == 0)
                              _rightRecordWidget()
                            else if (widget.type == 1)
                              _rightAudioTextWidget(),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 5 * scaleWidth,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _rightRecordWidget() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '你可以这样说',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16 * scaleWidth,
            ),
          ),
          SizedBox(
            height: 14 * scaleWidth,
          ),
          FittedBox(
            child: Text(
              widget.promptText ?? '“庭妹妹，请带我了解一下本月爆款”',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * scaleWidth,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: _recordStateWidget()),
        ],
      ),
    );
  }

  Widget _rightAudioTextWidget() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 8 * scaleWidth, right: 0 * scaleWidth),
          child: Text(
            currentAudioText ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16 * scaleWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget _recordStateWidget() {
    if (recording == 1) {
      return _recordingWidget();
    } else if (recording == 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: 18 * scaleWidth),
        child: _recordHandleWidget(),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: 18 * scaleWidth),
        child: _recordFailWidget(),
      );
    }
  }

  Widget _recordingWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Image.asset(
            'assets/images/ai_play.gif',
            package: 'ptt_ai_package',
            height: 35 * scaleWidth,
            fit: BoxFit.contain,
          ),
          InkWell(
            onTap: () {
              if (recording == 1) {
                validCount = 5;
                stopRecorder();
              }
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
                margin: const EdgeInsets.only(top: 2),
                height: 38 * scaleWidth,
                width: 80 * scaleWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: recording == 1
                            ? [
                                const Color(0x8812336a),
                                const Color(0x8806ced9),
                              ]
                            : [
                                const Color(0x4412336a),
                                const Color(0x4406ced9),
                              ])),
                child: Center(
                  child: Text(
                    '完成',
                    style: TextStyle(
                      color: recording == 1 ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _recordHandleWidget() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const CupertinoActivityIndicator(
            color: Colors.white,
          ),
          SizedBox(
            width: 5 * scaleWidth,
          ),
          Text(
            '处理中...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16 * scaleWidth,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordFailWidget() {
    return Center(
      child: Text(
        '没找到您想要的结果',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16 * scaleWidth,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  @override
  void dispose() {
    buildContext = null;
    _audioRecorder.dispose();
    _ampTimer?.cancel();

    if (_player.playing) {
      _player.stop();
    }
    _player.dispose();
    _cancelToken.cancel();
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
        // log('进入前台');
        break;
      case AppLifecycleState.inactive:
        // log('进入后台');
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
        // log('应用暂停');
        break;
      case AppLifecycleState.detached:
        // log('detached');
        break;
    }
  }
}
