import 'package:flutter/foundation.dart';

class TravelProvider extends ChangeNotifier {
  bool _showMap = false;
  bool get showMap => _showMap;

  void toggleMap() {
    _showMap = !_showMap;
    notifyListeners();
  }
}
