import 'package:google_maps_flutter/google_maps_flutter.dart';

class Area {
  LatLng? position;
  var radius;
  var risk;
  var address;
  var user;
  var id;

  Area.fromJson(Map<String, dynamic> map) {
    this.position = LatLng.fromJson(map['position']);
    this.radius = map['radius'];
    this.risk = map['risk'];
    this.user = map['user'];
    this.address = map['address'];
  }

  toJson() {
    Map<String, dynamic> map = new Map();

    map['radius'] = radius;
    map['position'] = position!.toJson();
    map['risk'] = risk;
    map['user'] = user;
    return map;
  }
}
