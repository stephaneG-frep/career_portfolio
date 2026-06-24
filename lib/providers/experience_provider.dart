import 'package:flutter/foundation.dart';

import '../models/experience.dart';
import '../services/local_database_service.dart';

class ExperienceProvider extends ChangeNotifier {
  ExperienceProvider(this._database) : _items = _database.getExperiences();

  final LocalDatabaseService _database;
  final List<Experience> _items;

  List<Experience> get items {
    final result = [..._items]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return result;
  }

  Future<void> save(Experience experience) async {
    final index = _items.indexWhere((item) => item.id == experience.id);
    index < 0 ? _items.add(experience) : _items[index] = experience;
    await _database.saveExperiences(_items);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _database.saveExperiences(_items);
    notifyListeners();
  }
}
