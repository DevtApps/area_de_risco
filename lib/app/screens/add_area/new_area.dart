import 'package:area_de_risco/app/api/Api.dart';
import 'package:area_de_risco/app/api/model/Area.dart';
import 'package:area_de_risco/app/controllers/area_controller.dart';
import 'package:area_de_risco/app/utils/risks.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';

class NewAreaScreen extends StatefulWidget {
  const NewAreaScreen({Key? key}) : super(key: key);

  @override
  _NewAreaScreenState createState() => _NewAreaScreenState();
}

class _NewAreaScreenState extends State<NewAreaScreen> {
  GoogleMapController? mapController;
  var googlePlace = GooglePlace(kGoogleApiKey);
  LatLng location = LatLng(0, 0);
  CameraPosition cameraPosition =
      CameraPosition(target: LatLng(0, 0), zoom: 13);

  var radius = 500.0;

  var selectedRisk = 0;

  FocusNode searchFocus = FocusNode();
  TextEditingController searchController = TextEditingController();
  List<SearchResult> places = [];

  SearchResult? selectedLocation;

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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getLocation() async {
    var position = await Geolocator.getCurrentPosition();
    location = LatLng(position.latitude, position.longitude);
    mapController!.animateCamera(CameraUpdate.newLatLng(location));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Nova área de risco"),
      ),
      body: Consumer<AreaController>(builder: (c, areaController, child) {
        return Column(
          children: [
            Card(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: DropdownButton(
                  isExpanded: true,
                  value: selectedRisk,
                  onChanged: (val) {
                    selectedRisk = val as int;
                    areaController.notifyListeners();
                  },
                  underline: SizedBox(),
                  items: List.generate(
                    risks.length,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text(risks[index]['name'].toString()),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    onTap: (LatLng latLng) {
                      searchFocus.unfocus();
                      setState(() {});
                    },
                    onCameraMove: (position) {
                      location = position.target;
                      searchFocus.unfocus();
                      setState(() {});
                    },
                    padding: EdgeInsets.only(bottom: 40),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      getLocation();
                    },
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    mapType: MapType.hybrid,
                    circles: Set.from([
                      Circle(
                        circleId: CircleId("area"),
                        center: location,
                        strokeWidth: 0,
                        fillColor: selectedRisk != 0
                            ? risks[selectedRisk]['color'] as Color
                            : Colors.blue,
                        radius: radius,
                      )
                    ]),
                    initialCameraPosition: cameraPosition,
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
                                    searchController.text =
                                        places[i].formattedAddress!;
                                    var position = places[i].geometry!.location;
                                    location =
                                        LatLng(position!.lat!, position.lng!);
                                    setState(() {});
                                    mapController!.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                zoom: 13, target: location)));
                                  },
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 65),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(8),
                            child: Slider(
                                max: 100,
                                min: 0,
                                label: "${radius * 100} km",
                                value: radius / 100,
                                onChangeEnd: (val) {},
                                onChanged: (val) {
                                  setState(() {
                                    radius = val * 100;
                                  });
                                }),
                          ),
                          Container(
                            height: 50,
                            margin:
                                EdgeInsets.only(left: 16, right: 16, bottom: 8),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (selectedRisk != 0 &&
                                    searchController.text.isNotEmpty) {
                                  await areaController.addArea(location, radius,
                                      selectedRisk, searchController.text);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Área adicionada")));
                                } else
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Selecione um risco e preencha o endereço")));
                              },
                              child: Text("SALVAR"),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
