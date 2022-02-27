import 'package:area_de_risco/app/controllers/area_controller.dart';
import 'package:area_de_risco/app/controllers/location_controller.dart';
import 'package:area_de_risco/app/controllers/user_controller.dart';
import 'package:area_de_risco/app/utils/risks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Consumer<AreaController>(builder: (c, areaController, child) {
      return Consumer<LocationController>(
          builder: (c, locationController, child) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                GoogleMap(
                  markers: areaController.markers,
                  polylines: areaController.polylines,
                  mapType: MapType.hybrid,
                  initialCameraPosition: locationController.cameraPosition,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: true,
                  circles: Set.from(
                    areaController.areas.map(
                      (e) => Circle(
                          circleId: CircleId(
                            e['id'],
                          ),
                          radius: e['radius'],
                          strokeWidth: 0,
                          center: LatLng.fromJson(e['position'])!,
                          fillColor: risks[e['risk']]['color'] as Color),
                    ),
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    locationController.mapController = controller;
                    locationController.updatePosition(context);
                  },
                  myLocationEnabled: true,
                ),
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          locationController.piker = 0;
                          areaController.searchFrom(context);
                        },
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                                dense: true,
                                title: Text(
                                  areaController.from != null
                                      ? areaController
                                          .from!.place!.formattedAddress!
                                      : "Partida",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: areaController.from != null
                                    ? IconButton(
                                        onPressed: () {
                                          areaController.from = null;
                                          areaController.polylines.clear();
                                          areaController.notifyListeners();
                                        },
                                        icon: Icon(Icons.close),
                                      )
                                    : SizedBox())),
                      ),
                      GestureDetector(
                        onTap: () {
                          locationController.piker = 1;
                          areaController.searchTo(context);
                        },
                        child: Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                                dense: true,
                                title: Text(
                                  areaController.to != null
                                      ? areaController
                                          .to!.place!.formattedAddress!
                                      : "Chegada",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: areaController.to != null
                                    ? IconButton(
                                        onPressed: () {
                                          areaController.to = null;
                                          areaController.polylines.clear();
                                          areaController.notifyListeners();
                                        },
                                        icon: Icon(Icons.close),
                                      )
                                    : SizedBox())),
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: Container(
                          margin: EdgeInsets.only(top: 32),
                          alignment: Alignment.centerLeft,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  risks.getRange(1, risks.length).length,
                                  (index) {
                                List names =
                                    risks.getRange(1, risks.length).toList();
                                return Card(
                                    color: Colors.white.withOpacity(0.8),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            color: names[index]['color'],
                                            width: 15,
                                            height: 15,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              names[index]['name'],
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              })),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          heroTag: "a",
                          backgroundColor: Colors.blueGrey,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            locationController.updatePosition(context);
                          },
                        ),
                      ),
                      areaController.from != null && areaController.to != null
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              //margin: EdgeInsets.only(bottom: 16),
                              width: double.infinity,
                              child: TextButton(
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 6)),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red)),
                                child: const Text(
                                  "Traçar rota",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  await areaController.drawRoute();

                                  var bounds = areaController.getBounds();

                                  locationController.mapController!
                                      .animateCamera(
                                          CameraUpdate.newLatLngBounds(
                                              bounds, 100));
                                  Fluttertoast.showToast(
                                      toastLength: Toast.LENGTH_LONG,
                                      msg:
                                          "Nós vamos te seguindo! É só sair andando...");
                                  locationController.notifyListeners();
                                },
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                )
              ],
            ));
      });
    });
  }
}
