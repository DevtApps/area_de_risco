import 'package:area_de_risco/app/api/Api.dart';
import 'package:area_de_risco/app/api/model/CustomLocation.dart';
import 'package:area_de_risco/app/controllers/location_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';

class AreaController extends ChangeNotifier {
  CustomLocation? from;
  CustomLocation? riskArea;
  CustomLocation? to;

  var areas = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var currentAreaType = -1;

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();

  AreaController() {}

  initListen() {
    firestore.collection("areas").snapshots().listen((event) {
      areas.clear();
      event.docs.forEach((element) {
        areas.addAll(event.docs.map((e) {
          var data = e.data();
          data['id'] = e.id;
          return data;
        }));
      });
      notifyListeners();
    });
  }

  void searchFrom(context) async {
    Navigator.of(context).pushNamed("search_place");
  }

  void searchTo(context) async {
    Navigator.of(context).pushNamed("search_place");
  }

  void pickRiskArea(context) async {
    Navigator.of(context).pushNamed("search_area");
  }

  drawRoute() async {
    polylineCoordinates.clear();
    polylines.clear();
    var result = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(from!.position!.latitude, from!.position!.longitude),
        PointLatLng(to!.position!.latitude, to!.position!.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    Polyline polyline = Polyline(
        polylineId: PolylineId("poly"),
        color: Colors.red,
        width: 3,
        points: polylineCoordinates);

    polylines.add(polyline);

    notifyListeners();
  }

  LatLngBounds getBounds() {
    var southLat = from!.position!.latitude < to!.position!.latitude
        ? from!.position!.latitude
        : to!.position!.latitude;
    var southLng = from!.position!.longitude < to!.position!.longitude
        ? from!.position!.longitude
        : to!.position!.longitude;

    var northLat = from!.position!.latitude > to!.position!.latitude
        ? from!.position!.latitude
        : to!.position!.latitude;
    var northLng = from!.position!.longitude > to!.position!.longitude
        ? from!.position!.longitude
        : to!.position!.longitude;

    return LatLngBounds(
        southwest: LatLng(southLat, southLng),
        northeast: LatLng(northLat, northLng));
  }

  Future<void> addArea(
      LatLng position, double radius, int risk, address) async {
    await firestore.collection("areas").add({
      "position": position.toJson(),
      "radius": radius,
      "risk": risk,
      "address": address,
      "user": FirebaseAuth.instance.currentUser!.uid
    });
  }

  Future<void> removeArea(id) async {
    await firestore.collection("areas").doc(id).delete();
  }
}
