import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meal_tracking/add_meal.dart';
import 'package:meal_tracking/details.dart';
import 'meal_model.dart';
import 'api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Meal> mealBox;
  final ApiService apiService = ApiService();
  String sortBy = 'time';
  TextEditingController searchController = TextEditingController();
  List<Meal> filteredMeals = [];
  List<Meal> apiMeals = [];
  List<String> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    mealBox = Hive.box<Meal>('meals');
    filteredMeals = mealBox.values.toList();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    categories = await apiService.fetchCategories();
    setState(() {});
  }

  Future<void> filterByCategory(String category) async {
    selectedCategory = category;
    apiMeals = await apiService.filterByCategory(category);
    setState(() {});
  }

  void clearCategoryFilter() {
    setState(() {
      selectedCategory = null;
      apiMeals.clear();
    });
  }

  void deleteMeal(int index) {
    mealBox.deleteAt(index);
    setState(() {
      filteredMeals = mealBox.values.toList();
    });
  }

  void sortMeals(String criteria) {
    setState(() {
      sortBy = criteria;
    });
  }

  Future<void> searchMeals(String query) async {
    apiMeals = await apiService.searchMeals(query);
    setState(() {});
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      apiMeals.clear();
      filteredMeals = mealBox.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Meal> meals = apiMeals.isNotEmpty ? apiMeals : List.from(filteredMeals);

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
        title: Center(child: const Text('Meal Tracker')),
        actions: [
          PopupMenuButton<String>(
            onSelected: sortMeals,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'calories', child: Text('Sort by Calories')),
              const PopupMenuItem(value: 'time', child: Text('Sort by Time')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close), onPressed: clearSearch)
                    : IconButton(icon: const Icon(Icons.search), onPressed: () => searchMeals(searchController.text)),
              ),
              onChanged: (text) {
                setState(() {});
                searchMeals(text);
              },
            ),
          ),
          if (categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ChoiceChip(
                      label: Text(category, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                      selected: isSelected,
                      selectedColor: Colors.orange,
                      backgroundColor: Colors.grey.shade200,
                      onSelected: (selected) {
                        if (selected) {
                          filterByCategory(category);
                        } else {
                          clearCategoryFilter();
                        }
                      },
                    ),
                  );
                },
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
                      leading: meal.photoPath != null
                          ? Image.network(meal.photoPath!, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.fastfood),
                      title: Text(meal.name),
                      subtitle: Text('${meal.calories} calories \n ${DateFormat('yyyy-MM-dd HH:mm:ss').format(meal.time)}'),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteMeal(index)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailScreen(meal: meal)));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMealScreen()));
          setState(() {
            filteredMeals = mealBox.values.toList();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
