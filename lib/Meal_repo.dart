import 'package:hive/hive.dart';
import 'meal_model.dart';

class MealRepository {
  static Box<Meal> mealBox = Hive.box<Meal>('meals');

  static List<Meal> getAllMeals() {
    return mealBox.values.toList();
  }

  static void addMeal(Meal meal) {
    mealBox.add(meal);
  }

  static void deleteMeal(int index) {
    mealBox.deleteAt(index);
  }
}
