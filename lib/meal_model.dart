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

  @HiveField(4)
  String? id;

  Meal({
    required this.name,
    required this.calories,
    required this.time,
    this.photoPath,
    this.id,
  });


  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['strMeal'],
      calories: 0, // API doesn't provide calories, set default or fetch separately
      time: DateTime.now(), // API doesn't provide time, set default
      photoPath: json['strMealThumb'],
      id: json['idMeal'],
    );
  }

  // Convert Meal object to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'strMeal': name,
      'idMeal': id,
      'strMealThumb': photoPath,
    };
  }
}
