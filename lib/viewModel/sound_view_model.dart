import 'package:flutter/material.dart';
import '../model/sound_model.dart';

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