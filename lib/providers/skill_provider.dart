import 'package:flutter/foundation.dart';

import '../models/skill.dart';
import '../services/local_database_service.dart';

class SkillProvider extends ChangeNotifier {
  SkillProvider(this._database) : _items = _database.getSkills();

  final LocalDatabaseService _database;
  final List<Skill> _items;
  SkillCategory? _categoryFilter;

  List<Skill> get items => List.unmodifiable(_items);
  SkillCategory? get categoryFilter => _categoryFilter;
  List<Skill> get filteredItems => _categoryFilter == null
      ? items
      : _items.where((item) => item.category == _categoryFilter).toList();

  void setCategoryFilter(SkillCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  Future<void> save(Skill skill) async {
    final index = _items.indexWhere((item) => item.id == skill.id);
    index < 0 ? _items.add(skill) : _items[index] = skill;
    await _database.saveSkills(_items);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _database.saveSkills(_items);
    notifyListeners();
  }
}
