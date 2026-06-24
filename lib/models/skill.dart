enum SkillCategory {
  web('Développement web'),
  mobile('Développement mobile'),
  design('Design UI/UX'),
  database('Base de données'),
  ai('IA'),
  cybersecurity('Cybersécurité'),
  softSkills('Soft skills'),
  other('Autre');

  const SkillCategory(this.label);
  final String label;
}

enum SkillLevel {
  beginner('Débutant'),
  intermediate('Intermédiaire'),
  advanced('Avancé'),
  expert('Expert');

  const SkillLevel(this.label);
  final String label;
}

class Skill {
  const Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    this.note = '',
    this.colorValue = 0xFF6750A4,
  });

  final String id;
  final String name;
  final SkillCategory category;
  final SkillLevel level;
  final String note;
  final int colorValue;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category.name,
    'level': level.name,
    'note': note,
    'colorValue': colorValue,
  };

  factory Skill.fromMap(Map<dynamic, dynamic> map) => Skill(
    id: map['id'] as String,
    name: map['name'] as String? ?? '',
    category: SkillCategory.values.byName(
      map['category'] as String? ?? SkillCategory.other.name,
    ),
    level: SkillLevel.values.byName(
      map['level'] as String? ?? SkillLevel.beginner.name,
    ),
    note: map['note'] as String? ?? '',
    colorValue: map['colorValue'] as int? ?? 0xFF6750A4,
  );
}
