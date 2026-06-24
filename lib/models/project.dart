enum ProjectStatus {
  idea('Idée'),
  inProgress('En cours'),
  completed('Terminé'),
  published('Publié');

  const ProjectStatus(this.label);
  final String label;
}

class PortfolioProject {
  const PortfolioProject({
    required this.id,
    required this.name,
    required this.shortDescription,
    this.detailedDescription = '',
    this.technologies = const [],
    this.imageBase64List = const [],
    this.githubUrl = '',
    this.demoUrl = '',
    this.status = ProjectStatus.idea,
    this.startDate,
    this.endDate,
    this.notes = '',
  });

  final String id;
  final String name;
  final String shortDescription;
  final String detailedDescription;
  final List<String> technologies;
  final List<String> imageBase64List;
  final String githubUrl;
  final String demoUrl;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String notes;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'shortDescription': shortDescription,
    'detailedDescription': detailedDescription,
    'technologies': technologies,
    'imageBase64List': imageBase64List,
    'githubUrl': githubUrl,
    'demoUrl': demoUrl,
    'status': status.name,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'notes': notes,
  };

  factory PortfolioProject.fromMap(Map<dynamic, dynamic> map) =>
      PortfolioProject(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        shortDescription: map['shortDescription'] as String? ?? '',
        detailedDescription: map['detailedDescription'] as String? ?? '',
        technologies: List<String>.from(
          map['technologies'] as List? ?? const [],
        ),
        imageBase64List: List<String>.from(
          map['imageBase64List'] as List? ?? const [],
        ),
        githubUrl: map['githubUrl'] as String? ?? '',
        demoUrl: map['demoUrl'] as String? ?? '',
        status: ProjectStatus.values.byName(
          map['status'] as String? ?? ProjectStatus.idea.name,
        ),
        startDate: DateTime.tryParse(map['startDate'] as String? ?? ''),
        endDate: DateTime.tryParse(map['endDate'] as String? ?? ''),
        notes: map['notes'] as String? ?? '',
      );
}
