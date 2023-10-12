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

  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      text: json["text"],
      type: json["type"],
      url: json["url"],
      nativePage: json["nativePage"],
      maybes: (json['maybes'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      texts:
      (json['texts'] as List<dynamic>?)?.map((e) => e as String?).toList(),
      wavUrl: json["wavUrl"],
    );
  }

}