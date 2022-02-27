import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class CustomLocation {
  LatLng? position;
  SearchResult? place;
  double radius;

  CustomLocation(this.position, this.place, {this.radius: 0});
}
