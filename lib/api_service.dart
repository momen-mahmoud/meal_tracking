import 'dart:convert';
import 'package:http/http.dart' as http;
import 'meal_model.dart';

class ApiService {
  Future<List<String>> fetchCategories() async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return List<String>.from(data['meals'].map((c) => c['strCategory']));
      }
    }
    return [];
  }

  Future<List<Meal>> filterByCategory(String category) async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((meal) => Meal(
          name: meal['strMeal'],
          calories: 0,
          time: DateTime.now(),
          photoPath: meal['strMealThumb'],
        ))
            .toList();
      }
    }
    return [];
  }

  Future<List<Meal>> searchMeals(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((meal) => Meal(
          name: meal['strMeal'],
          calories: 0,
          time: DateTime.now(),
          photoPath: meal['strMealThumb'],
        ))
            .toList();
      }
    }
    return [];
  }
}
