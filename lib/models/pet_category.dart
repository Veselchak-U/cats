import 'package:flutter/material.dart';

class PetCategory {
  PetCategory(
      {@required this.name, @required this.image, @required this.count});

  final String name;
  final String image;
  final int count;
}