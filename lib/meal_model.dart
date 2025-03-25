import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'meal_model.g.dart';

@HiveType(typeId: 0)
class Meal extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int calories;

  @HiveField(2)
  DateTime time;

  @HiveField(3)
  String? photoPath;

  Meal({
    required this.name,
    required this.calories,
    required this.time,
    this.photoPath,
  });
}
