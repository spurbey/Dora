import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:dora/core/map/models/app_latlng.dart';

class LatLngConverter extends TypeConverter<AppLatLng, String> {
  const LatLngConverter();

  @override
  AppLatLng fromSql(String fromDb) {
    final json = jsonDecode(fromDb) as Map<String, dynamic>;
    return AppLatLng.fromJson(json);
  }

  @override
  String toSql(AppLatLng value) => jsonEncode(value.toJson());
}

class LatLngListConverter extends TypeConverter<List<AppLatLng>, String> {
  const LatLngListConverter();

  @override
  List<AppLatLng> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List;
    return decoded
        .map((item) => AppLatLng.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<AppLatLng> value) {
    return jsonEncode(value.map((item) => item.toJson()).toList());
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List;
    return decoded.cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
