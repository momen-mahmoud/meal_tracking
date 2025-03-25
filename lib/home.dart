import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meal_tracking/add_meal.dart';
import 'meal_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Meal> mealBox;
  String sortBy = 'time';

  @override
  void initState() {
    super.initState();
    mealBox = Hive.box<Meal>('meals');
  }

  void deleteMeal(int index) {
    mealBox.deleteAt(index);
    setState(() {});
  }

  void sortMeals(String criteria) {
    setState(() {
      sortBy = criteria;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Meal> meals = mealBox.values.toList();

    if (sortBy == 'name') {
      meals.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == 'calories') {
      meals.sort((a, b) => a.calories.compareTo(b.calories));
    } else {
      meals.sort((a, b) => a.time.compareTo(b.time));
    }

    int totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: sortMeals,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'name',
                    child: Text('Sort by Name'),
                  ),
                  const PopupMenuItem(
                    value: 'calories',
                    child: Text('Sort by Calories'),
                  ),
                  const PopupMenuItem(
                    value: 'time',
                    child: Text('Sort by Time'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Calories: $totalCalories',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                Meal meal = meals[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      leading:
                          meal.photoPath != null
                              ? Image.asset(
                                meal.photoPath!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : const Icon(Icons.fastfood),
                      title: Text(meal.name),
                      subtitle: Text(
                        '${meal.calories} calories \n ${DateFormat('yyyy-MM-dd HH:mm:ss').format(meal.time)}',
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteMeal(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMealScreen()),
            ).then((_) => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}
