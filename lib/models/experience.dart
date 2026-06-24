enum ExperienceType {
  job('Emploi'),
  internship('Stage'),
  training('Formation'),
  personalProject('Projet personnel'),
  volunteering('Bénévolat'),
  other('Autre');

  const ExperienceType(this.label);
  final String label;
}

class Experience {
  const Experience({
    required this.id,
    required this.position,
    required this.company,
    required this.type,
    required this.startDate,
    this.endDate,
    this.description = '',
    this.skills = const [],
  });

  final String id;
  final String position;
  final String company;
  final ExperienceType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String description;
  final List<String> skills;

  Map<String, dynamic> toMap() => {
    'id': id,
    'position': position,
    'company': company,
    'type': type.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'description': description,
    'skills': skills,
  };

  factory Experience.fromMap(Map<dynamic, dynamic> map) => Experience(
    id: map['id'] as String,
    position: map['position'] as String? ?? '',
    company: map['company'] as String? ?? '',
    type: ExperienceType.values.byName(
      map['type'] as String? ?? ExperienceType.other.name,
    ),
    startDate:
        DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(map['endDate'] as String? ?? ''),
    description: map['description'] as String? ?? '',
    skills: List<String>.from(map['skills'] as List? ?? const []),
  );
}
