import 'package:area_de_risco/app/api/Api.dart';
import 'package:area_de_risco/app/api/model/CustomLocation.dart';
import 'package:area_de_risco/app/controllers/area_controller.dart';
import 'package:area_de_risco/app/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SearchPlace extends StatefulWidget {
  const SearchPlace({Key? key}) : super(key: key);

  @override
  _SearchPlaceState createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  FocusNode searchFocus = FocusNode();
  TextEditingController searchController = TextEditingController();
  var googlePlace = GooglePlace(kGoogleApiKey);
  GoogleMapController? _controller;
  List<SearchResult> places = [];

  SearchResult? selectedLocation;

  LatLng? latLng;

  search() async {
    if (searchController.text.isNotEmpty) {
      var result = await googlePlace.search
          .getTextSearch(searchController.text, language: "pt");

      if (result != null &&
          result.results != null &&
          result.results!.isNotEmpty) {
        setState(() {
          places = result.results!;
        });
      } else
        places = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer<LocationController>(
          builder: (c, locationController, child) {
            return child ??
                Stack(
                  children: [
                    GoogleMap(
                      onTap: (LatLng latLng) {
                        searchFocus.unfocus();
                        setState(() {});
                      },
                      onCameraMove: (position) {
                        latLng = position.target;
                        searchFocus.unfocus();
                        setState(() {});
                      },
                      zoomControlsEnabled: false,
                      initialCameraPosition: locationController.cameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        locationController.updatePosition(context,
                            controller: controller);
                      },
                    ),
                    Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                              bottomLeft: searchFocus.hasFocus
                                  ? Radius.circular(0)
                                  : Radius.circular(4),
                              bottomRight: searchFocus.hasFocus
                                  ? Radius.circular(0)
                                  : Radius.circular(4),
                            ),
                          ),
                          margin: EdgeInsets.only(top: 8, left: 8, right: 8),
                          child: TextFormField(
                            onTap: () {
                              setState(() {});
                            },
                            onChanged: (text) {
                              search();
                            },
                            focusNode: searchFocus,
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: "Endereço",
                              suffixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8))),
                          margin: EdgeInsets.only(left: 8, right: 8),
                          child: AnimatedContainer(
                            height: searchFocus.hasFocus && places.isNotEmpty
                                ? 150
                                : 0,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.ease,
                            child: ListView.builder(
                                itemCount: places.length,
                                itemBuilder: (c, i) {
                                  return ListTile(
                                    title: Text(places[i].name ?? ""),
                                    subtitle:
                                        Text(places[i].formattedAddress ?? ""),
                                    onTap: () {
                                      setState(() {
                                        selectedLocation = places[i];
                                      });
                                      searchController.text =
                                          places[i].formattedAddress!;
                                      locationController.setPlace(
                                          places[i].geometry!.location!,
                                          controller: _controller);
                                    },
                                  );
                                }),
                          ),
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.location_pin,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            alignment: Alignment.centerRight,
                            child: FloatingActionButton(
                              backgroundColor: Colors.red,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                locationController.updatePosition(context,
                                    controller: _controller);
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            width: double.infinity,
                            child: TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 6)),
                                  backgroundColor: MaterialStateProperty.all(
                                      selectedLocation != null
                                          ? Colors.red
                                          : Colors.grey)),
                              child: const Text(
                                "Usar a localização atual",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                if (selectedLocation != null) {
                                  if (locationController.piker == 0) {
                                    Provider.of<AreaController>(context,
                                                listen: false)
                                            .from =
                                        CustomLocation(
                                            latLng, selectedLocation);
                                  } else {
                                    Provider.of<AreaController>(context,
                                                listen: false)
                                            .to =
                                        CustomLocation(
                                            latLng, selectedLocation);
                                  }
                                  Provider.of<AreaController>(context,
                                          listen: false)
                                      .notifyListeners();
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
          },
        ),
      ),
    );
  }
}
