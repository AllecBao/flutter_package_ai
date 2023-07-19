
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    await _mRecorder!.openRecorder();
    // await _mRecorder!._openAudioSession();

    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        return;
      }
    }
  }


  late SoundViewModel _viewModel;
  @override
  void initState() {

    _viewModel = SoundViewModel().initSoundModel();
    _mPlayer!.openPlayer();
    openTheRecorder();

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

  void record() async {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: AudioSource.microphone,
    )
        .then((value) {});

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
}