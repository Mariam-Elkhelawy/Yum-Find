import 'package:YumFind/YumFind.dart';
import 'package:YumFind/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/locator/service_locator.dart';
import 'features/tabs/data/models/SearchModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(IngredientsAdapter());
  Hive.registerAdapter(TotalNutrientsAdapter());
  Hive.registerAdapter(EnercKcalAdapter());
  Hive.registerAdapter(ProcntAdapter());
  Hive.registerAdapter(FatAdapter());
  Hive.registerAdapter(ChocdfAdapter());
  await Hive.openBox<Recipe>(AppStrings.favBox);
  await Hive.openBox<Ingredients>(AppStrings.shoppingBox);

  setupServiceLocator();
  runApp(const YumFind());
}
