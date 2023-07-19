
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../viewModel/soundViewModel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

class HomeView extends StatefulWidget{
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>{

  Codec _codec = Codec.aacADTS;
  String _mPath = '';
  bool recording = false;

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

  Future<bool> getPermissionStatus() async {
    Permission permission = Permission.microphone;
    //granted 通过，denied 被拒绝，permanentlyDenied 拒绝且不在提示
    PermissionStatus status = await permission.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      requestPermission(permission);
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isRestricted) {
      requestPermission(permission);
    } else {}
    return false;
  }

  ///申请权限
  void requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> openTheRecorder() async {

    await getPermissionStatus().then((value) async {
      if (!value) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    });
    // var status = await Permission.microphone.request();
    // if (status != PermissionStatus.granted) {
    //   throw RecordingPermissionException('Microphone permission not granted');
    // }
    await _mRecorder!.openRecorder();
    // await _mRecorder!._openAudioSession();

    // if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
    //   _codec = Codec.aacADTS;
    //   _mPath = '';
      // if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      //   return;
      // }
    // }
  }


  //late SoundViewModel _viewModel;
  @override
  void initState() async {

    //_viewModel = SoundViewModel().initSoundModel();
    _mPlayer!.openPlayer();
    //开启录音
    openTheRecorder().then((value) => {

    });
    super.initState();
  }

  void play() {
    _mPlayer!
        .startPlayer(
        fromURI: _mPath,
        // 'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3',
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void startRecord() async {
    await getPermissionStatus().then((value) async {
      if (!value) {
        return;
      }
      //用户允许使用麦克风之后开始录音
      Directory tempDir = await getTemporaryDirectory();
      var time = DateTime
          .now()
          .millisecondsSinceEpoch;
      _mPath = '${tempDir.path}/$time${ext[Codec.aacADTS.index]}';

      _mRecorder!.startRecorder(
        toFile: _mPath,
        codec: _codec,
        audioSource: AudioSource.microphone,
      ).then((value) {

      });

      setState(() {
        recording = true;
      });
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        recording = false;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Center(
      child: Container(
        child: Row(
          children: [
            SizedBox(
              width: 3,
            ),
            ElevatedButton(
                onPressed: () {
                  play();
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
                    startRecord();
                  }
                },
                child: Text(recording ? 'Stop' : 'Record'))
          ],
        ),
      ),
    );
  }
}