import 'package:flutter/foundation.dart';

import '../models/education.dart';
import '../services/local_database_service.dart';

class EducationProvider extends ChangeNotifier {
  EducationProvider(this._database) : _items = _database.getEducation();

  final LocalDatabaseService _database;
  final List<Education> _items;

  List<Education> get items {
    final result = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<void> save(Education education) async {
    final index = _items.indexWhere((item) => item.id == education.id);
    index < 0 ? _items.add(education) : _items[index] = education;
    await _database.saveEducation(_items);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _database.saveEducation(_items);
    notifyListeners();
  }
}
