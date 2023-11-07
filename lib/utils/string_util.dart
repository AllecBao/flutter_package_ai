import 'package:flutter/material.dart';

extension StringExtension on String? {
  double toDouble({double defaultValue = 0}) {
    return double.tryParse(this ?? '$defaultValue') ?? defaultValue;
  }

  int toInt({int defaultValue = 0}) {
    return int.tryParse(this ?? '$defaultValue') ?? defaultValue;
  }

  Color toColor({Color defaultValue = Colors.transparent}) {
    if (this == null || this?.isEmpty == true) {
      return Colors.transparent;
    }
    if (this == 'transparent') {
      return Colors.transparent;
    }
    var hexColor = this?.toUpperCase().replaceAll('#', '');
    if (hexColor?.length == 6) {
      hexColor = 'FF$hexColor';
    } else if (hexColor?.length == 3) {
      hexColor =
          'FF${hexColor![0]}${hexColor[0]}${hexColor[1]}${hexColor[1]}${hexColor[2]}${hexColor[2]}';
    } else if (hexColor?.length == 4) {
      hexColor =
          '${hexColor![0]}${hexColor[0]}${hexColor[1]}${hexColor[1]}${hexColor[2]}${hexColor[2]}${hexColor[3]}${hexColor[3]}';
    }
    if (hexColor != null) {
      var intColor = int.tryParse(hexColor, radix: 16);
      if (intColor != null) {
        return Color(intColor);
      }
    }
    return defaultValue;
  }
}
