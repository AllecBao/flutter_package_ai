
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

   Future.delayed(const Duration(milliseconds: 500),(){
      print('***********delayed');
      _codec = Codec.pcm16WAV;
      _mPath = 'https://resource.51ptt.net/ai/temp/tmm_ai_welcome.wav';
      play();
    });
  }
  void play() {
    _mPlayer!.startPlayer(
        fromURI: _mPath,
        // 'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3',
        codec: _codec,
        whenFinished: () {
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void record() async {
    Codec _codec = Codec.aacMP4;
    String _mPath = 'tau_file.mp4';
    _mRecorder!.startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: AudioSource.microphone,
    ).then((value) {});

    setState(() {
      recording = true;
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
                    record();
                  }
                },
                child: Text(recording ? 'Stop' : 'Record'))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('***********dispose');
    if(recording){
      stopRecorder();
    }
    super.dispose();
  }
}