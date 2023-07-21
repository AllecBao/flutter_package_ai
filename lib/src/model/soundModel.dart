import 'package:json_annotation/json_annotation.dart';
part 'soundModel.g.dart';

@JsonSerializable()
class SoundModel{
  SoundModel({
    this.text,
    this.type,
    this.url,
    this.nativePage,
    this.maybes,
    this.texts,
  });
  String? text;
  String? type;
  String? url;
  String? nativePage;
  List<String?>? maybes;
  List<String?>? texts;
  factory SoundModel.fromJson(Map<String, dynamic> json) => _$SoundModelFromJson(json);
  Map<String,dynamic> toJson() => _$SoundModelToJson(this);
}