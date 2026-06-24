import 'package:flutter/foundation.dart';

import '../models/project.dart';
import '../services/local_database_service.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider(this._database) : _items = _database.getProjects();

  final LocalDatabaseService _database;
  final List<PortfolioProject> _items;
  String _query = '';
  String? _technology;
  ProjectStatus? _status;

  List<PortfolioProject> get items => List.unmodifiable(_items);
  String get query => _query;
  String? get technology => _technology;
  ProjectStatus? get status => _status;
  List<String> get technologies =>
      (_items.expand((item) => item.technologies).toSet().toList()..sort());

  List<PortfolioProject> get filteredItems {
    final normalized = _query.trim().toLowerCase();
    return _items.where((item) {
      final matchesQuery =
          normalized.isEmpty ||
          item.name.toLowerCase().contains(normalized) ||
          item.shortDescription.toLowerCase().contains(normalized) ||
          item.technologies.any(
            (technology) => technology.toLowerCase().contains(normalized),
          );
      return matchesQuery &&
          (_technology == null || item.technologies.contains(_technology)) &&
          (_status == null || item.status == _status);
    }).toList();
  }

  void updateFilters({
    String? query,
    String? technology,
    bool clearTechnology = false,
    ProjectStatus? status,
    bool clearStatus = false,
  }) {
    if (query != null) _query = query;
    _technology = clearTechnology ? null : technology ?? _technology;
    _status = clearStatus ? null : status ?? _status;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _technology = null;
    _status = null;
    notifyListeners();
  }

  Future<void> save(PortfolioProject project) async {
    final index = _items.indexWhere((item) => item.id == project.id);
    index < 0 ? _items.add(project) : _items[index] = project;
    await _database.saveProjects(_items);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _database.saveProjects(_items);
    notifyListeners();
  }
}
