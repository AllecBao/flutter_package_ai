// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soundModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SoundModel _$SoundModelFromJson(Map<String, dynamic> json) => SoundModel(
      text: json['text'] as String?,
      type: json['type'] as String?,
      url: json['url'] as String?,
      nativePage: json['nativePage'] as String?,
      maybes:
          (json['maybes'] as List<dynamic>?)?.map((e) => e as String?).toList(),
      texts:
          (json['texts'] as List<dynamic>?)?.map((e) => e as String?).toList(),
    );

Map<String, dynamic> _$SoundModelToJson(SoundModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'type': instance.type,
      'url': instance.url,
      'nativePage': instance.nativePage,
      'maybes': instance.maybes,
      'texts': instance.texts,
    };
