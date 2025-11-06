import 'package:flutter/material.dart';

const List<Color> _appColors = [
  Colors.brown,
  Colors.red,
  Colors.deepOrangeAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.amber,
  Colors.amberAccent,
]; 

class AppTheme {
  
  final int selectedColorIndex;

  AppTheme({this.selectedColorIndex = 0})
      : assert(selectedColorIndex >= 0 && selectedColorIndex < _appColors.length,'Invalid color index');

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _appColors[selectedColorIndex],
    );
  }
}