
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ptt_ai_package/src/model/soundModel.dart';
import '../viewModel/soundViewModel.dart';
import '../http/api.dart';
// import '../assets/audio/sound_start.wav';

class HomeView extends StatefulWidget{
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>{

  final _player = AudioPlayer();
  final audioStart = '../assets/audio/sound_start.wav';
  final audioEnd = '../assets/audio/sound_end.mp3';

  @override
  void initState() {

    super.initState();
    audioPlay(audioStart);
  }
  void audioPlay(audioUrl) async{

    await _player.setFilePath(audioUrl);;
    await _player.play();
  }

  void record() {

  }

  void stopRecorder() {

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
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            image: new DecorationImage(
              image: NetworkImage('https://ptt-resource.oss-cn-hangzhou.aliyuncs.com/ptt/images/img_aidialog_bg.png'),
            ),
          ),
          child: AspectRatio(
            aspectRatio: 3/2,
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Container()
                ),
                Expanded(
                    flex: 1,
                    child:Stack(
                      children: [
                        Positioned(
                          top:20,
                          right: 20,
                          child: GestureDetector(
                            onTap: (){
                              stopRecorder();
                              // navPopUp();
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Color(0x00000001),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Container(child: Text('你可以这样说',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )),
                            SizedBox(
                              height: 20,
                            ),
                            // 一般播放和录音没啥关系
                            Container(child: Text( '“我想要活酵母”',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        )
                      ],
                    )
                ),
              ],
            ),
          )
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}