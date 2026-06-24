import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/education_provider.dart';
import 'providers/experience_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/project_provider.dart';
import 'providers/skill_provider.dart';
import 'services/local_database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');
  await Hive.initFlutter();
  final database = LocalDatabaseService();
  await database.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider(database)),
        ChangeNotifierProvider(create: (_) => SkillProvider(database)),
        ChangeNotifierProvider(create: (_) => ProjectProvider(database)),
        ChangeNotifierProvider(create: (_) => ExperienceProvider(database)),
        ChangeNotifierProvider(create: (_) => EducationProvider(database)),
      ],
      child: const CareerPortfolioApp(),
    ),
  );
}
