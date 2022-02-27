import 'package:area_de_risco/app/api/model/Area.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  List<Area> myAreas = [];
  FirebaseAuth auth = FirebaseAuth.instance;

  bool get isLogged => auth.currentUser != null;

  UserController() {}

  void init() {
    FirebaseFirestore.instance
        .collection("areas")
        .where("user", isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .listen((event) {
      myAreas.clear();
      myAreas.addAll(event.docs.map((e) {
        var area = Area.fromJson(e.data());
        area.id = e.id;
        return area;
      }));
      notifyListeners();
    });
  }
}
