import 'package:json_annotation/json_annotation.dart';
part 'sound_model.g.dart';

@JsonSerializable()
class SoundModel{
  SoundModel({
    this.text,
    this.type,
    this.url,
    this.nativePage,
    this.maybes,
    this.texts,
    this.wavUrl,
  });
  String? text;
  String? type;
  String? url;
  String? nativePage;
  List<Map<String, dynamic>>? maybes;
  List<String?>? texts;
  String? wavUrl;
  factory SoundModel.fromJson(Map<String, dynamic> json) => _$SoundModelFromJson(json);
  Map<String,dynamic> toJson() => _$SoundModelToJson(this);
}