import 'package:flutter/material.dart';

class TravelProvider extends ChangeNotifier {
  bool showMap = false;

  void toggleMap() {
    showMap = !showMap;
    notifyListeners();
  }
}
