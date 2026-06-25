import 'package:flutter/material.dart';
import 'package:travel_app_design/travel_provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TravelProvider(),
      builder: (context, child) {
        return Stack(children: [

          
        ]);
      },
    );
  }
}
