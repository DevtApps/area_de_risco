import 'package:area_de_risco/app/api/Api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class LocationController extends ChangeNotifier {
  GoogleMapController? mapController;
  var googlePlace = GooglePlace(kGoogleApiKey);
  Location location = Location(lat: 0, lng: 0);
  CameraPosition cameraPosition =
      CameraPosition(target: LatLng(0, 0), zoom: 13);

  var piker = 0;

  void updatePosition(context, {GoogleMapController? controller}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("GPS desativado"),
        action: SnackBarAction(
          label: "Ativar",
          onPressed: () {
            Geolocator.openLocationSettings();
          },
        ),
      ));
    } else {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sem acesso a localização")));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Localização negada permanentemente")));
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        var position = await Geolocator.getCurrentPosition();

        (controller ?? mapController!).animateCamera(CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude)));
        this.location =
            Location(lat: position.latitude, lng: position.longitude);
        notifyListeners();
      }
    }
  }

  setPlace(Location location, {GoogleMapController? controller}) async {
    (controller ?? mapController!).animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(location.lat!, location.lng!), 17));
    this.location = location;
    notifyListeners();
  }
}
