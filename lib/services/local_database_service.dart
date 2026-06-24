import 'package:hive_ce/hive.dart';

import '../models/education.dart';
import '../models/experience.dart';
import '../models/profile.dart';
import '../models/project.dart';
import '../models/skill.dart';

class LocalDatabaseService {
  static const _boxName = 'career_portfolio';
  late final Box<dynamic> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    if (_box.get('initialized') != true) {
      await _seedDemoData();
    }
  }

  Profile getProfile() =>
      Profile.fromMap(Map<dynamic, dynamic>.from(_box.get('profile') as Map));

  Future<void> saveProfile(Profile profile) =>
      _box.put('profile', profile.toMap());

  List<Skill> getSkills() => _readList('skills', Skill.fromMap);
  List<PortfolioProject> getProjects() =>
      _readList('projects', PortfolioProject.fromMap);
  List<Experience> getExperiences() =>
      _readList('experiences', Experience.fromMap);
  List<Education> getEducation() => _readList('education', Education.fromMap);

  Future<void> saveSkills(List<Skill> items) =>
      _writeList('skills', items.map((item) => item.toMap()));
  Future<void> saveProjects(List<PortfolioProject> items) =>
      _writeList('projects', items.map((item) => item.toMap()));
  Future<void> saveExperiences(List<Experience> items) =>
      _writeList('experiences', items.map((item) => item.toMap()));
  Future<void> saveEducation(List<Education> items) =>
      _writeList('education', items.map((item) => item.toMap()));

  bool get darkMode => _box.get('darkMode', defaultValue: false) as bool;
  Future<void> saveDarkMode({required bool value}) =>
      _box.put('darkMode', value);

  List<T> _readList<T>(String key, T Function(Map<dynamic, dynamic>) fromMap) {
    final raw = _box.get(key, defaultValue: <dynamic>[]) as List;
    return raw
        .map((item) => fromMap(Map<dynamic, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> _writeList(String key, Iterable<Map<String, dynamic>> items) =>
      _box.put(key, items.toList());

  Future<void> _seedDemoData() async {
    final now = DateTime.now();
    await _box.put(
      'profile',
      const Profile(
        fullName: 'Camille Martin',
        professionalTitle: 'Développeuse Flutter',
        shortBio:
            'Je conçois des applications mobiles et desktop élégantes, '
            'accessibles et performantes.',
        longBio:
            'Passionnée par les produits utiles et les interfaces soignées, '
            'je transforme des idées en expériences multiplateformes robustes.',
        city: 'Lyon, France',
        email: 'camille.martin@example.com',
        website: 'https://example.com',
        github: 'https://github.com/camille-demo',
        linkedin: 'https://linkedin.com/in/camille-demo',
      ).toMap(),
    );
    await _box.put('skills', [
      const Skill(
        id: 'skill-flutter',
        name: 'Flutter & Dart',
        category: SkillCategory.mobile,
        level: SkillLevel.expert,
        note: 'Applications mobiles, web et desktop.',
        colorValue: 0xFF00A8E8,
      ).toMap(),
      const Skill(
        id: 'skill-ux',
        name: 'UI/UX Design',
        category: SkillCategory.design,
        level: SkillLevel.advanced,
        note: 'Design systems et prototypage.',
        colorValue: 0xFF7C4DFF,
      ).toMap(),
      const Skill(
        id: 'skill-sql',
        name: 'Bases de données',
        category: SkillCategory.database,
        level: SkillLevel.advanced,
        note: 'SQLite, PostgreSQL et modélisation.',
        colorValue: 0xFF006D77,
      ).toMap(),
    ]);
    await _box.put('projects', [
      PortfolioProject(
        id: 'project-focus',
        name: 'FocusFlow',
        shortDescription:
            'Une application de productivité locale centrée sur la concentration.',
        detailedDescription:
            'Minuteur, statistiques et planification quotidienne dans une '
            'interface Material 3.',
        technologies: const ['Flutter', 'Dart', 'Hive'],
        githubUrl: 'https://github.com/camille-demo/focusflow',
        status: ProjectStatus.published,
        startDate: DateTime(now.year - 1, 2),
        endDate: DateTime(now.year - 1, 7),
      ).toMap(),
      PortfolioProject(
        id: 'project-city',
        name: 'CityPulse',
        shortDescription:
            'Un tableau de bord responsive pour explorer les données urbaines.',
        detailedDescription:
            'Visualisations, favoris hors ligne et expérience adaptative.',
        technologies: const ['Flutter Web', 'REST', 'Charts'],
        status: ProjectStatus.completed,
        startDate: DateTime(now.year - 1, 9),
        endDate: DateTime(now.year, 1),
      ).toMap(),
    ]);
    await _box.put('experiences', [
      Experience(
        id: 'experience-studio',
        position: 'Développeuse Flutter',
        company: 'Studio Nova',
        type: ExperienceType.job,
        startDate: DateTime(now.year - 2, 3),
        description:
            'Conception et livraison d’applications multiplateformes, revue '
            'de code et collaboration avec l’équipe design.',
        skills: const ['Flutter', 'Dart', 'Figma', 'Git'],
      ).toMap(),
    ]);
    await _box.put('education', [
      Education(
        id: 'education-mobile',
        name: 'Certification développement mobile',
        organization: 'Open Learning Institute',
        date: DateTime(now.year - 2, 1),
        duration: '6 mois',
        notes: 'Architecture, qualité logicielle et publication.',
      ).toMap(),
    ]);
    await _box.put('darkMode', false);
    await _box.put('initialized', true);
  }
}
