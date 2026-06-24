import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../services/local_database_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._database) : _profile = _database.getProfile();

  final LocalDatabaseService _database;
  Profile _profile;

  Profile get profile => _profile;

  Future<void> save(Profile profile) async {
    _profile = profile;
    await _database.saveProfile(profile);
    notifyListeners();
  }
}
