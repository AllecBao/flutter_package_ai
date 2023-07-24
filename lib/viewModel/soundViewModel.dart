import 'package:flutter/material.dart';
import '../model/soundModel.dart';

class SoundViewModel with ChangeNotifier{

  late SoundModel _soundModel;
  SoundModel get soundModel => _soundModel;

   initSoundModel(){
    _soundModel = SoundModel();
    notifyListeners();
  }

  setSoundModel(SoundModel sound){
    _soundModel = sound;
    notifyListeners();
  }
}