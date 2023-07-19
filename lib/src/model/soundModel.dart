import 'dart:convert';

class SoundModel{

  SoundModel soundModelFromJson(String str) => SoundModel.fromJson(json.decode(str));
  SoundModel({
    this.audioUrl
  });
  // final Map<String,dynamic>? sound;
  final int status = 0;
  final String? audioUrl;
  factory SoundModel.fromJson(Map<String,dynamic> json) => SoundModel(
    audioUrl: json["audioUrl"],
  );
}