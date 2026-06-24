class Education {
  const Education({
    required this.id,
    required this.name,
    required this.organization,
    required this.date,
    this.duration = '',
    this.certificateBase64,
    this.notes = '',
  });

  final String id;
  final String name;
  final String organization;
  final DateTime date;
  final String duration;
  final String? certificateBase64;
  final String notes;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'organization': organization,
    'date': date.toIso8601String(),
    'duration': duration,
    'certificateBase64': certificateBase64,
    'notes': notes,
  };

  factory Education.fromMap(Map<dynamic, dynamic> map) => Education(
    id: map['id'] as String,
    name: map['name'] as String? ?? '',
    organization: map['organization'] as String? ?? '',
    date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
    duration: map['duration'] as String? ?? '',
    certificateBase64: map['certificateBase64'] as String?,
    notes: map['notes'] as String? ?? '',
  );
}
