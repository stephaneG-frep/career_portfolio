class Profile {
  const Profile({
    required this.fullName,
    required this.professionalTitle,
    this.photoBase64,
    this.shortBio = '',
    this.longBio = '',
    this.city = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.github = '',
    this.linkedin = '',
    this.otherLinks = const [],
  });

  final String fullName;
  final String professionalTitle;
  final String? photoBase64;
  final String shortBio;
  final String longBio;
  final String city;
  final String email;
  final String phone;
  final String website;
  final String github;
  final String linkedin;
  final List<String> otherLinks;

  Profile copyWith({
    String? fullName,
    String? professionalTitle,
    String? photoBase64,
    bool removePhoto = false,
    String? shortBio,
    String? longBio,
    String? city,
    String? email,
    String? phone,
    String? website,
    String? github,
    String? linkedin,
    List<String>? otherLinks,
  }) {
    return Profile(
      fullName: fullName ?? this.fullName,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      photoBase64: removePhoto ? null : photoBase64 ?? this.photoBase64,
      shortBio: shortBio ?? this.shortBio,
      longBio: longBio ?? this.longBio,
      city: city ?? this.city,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      otherLinks: otherLinks ?? this.otherLinks,
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'professionalTitle': professionalTitle,
    'photoBase64': photoBase64,
    'shortBio': shortBio,
    'longBio': longBio,
    'city': city,
    'email': email,
    'phone': phone,
    'website': website,
    'github': github,
    'linkedin': linkedin,
    'otherLinks': otherLinks,
  };

  factory Profile.fromMap(Map<dynamic, dynamic> map) => Profile(
    fullName: map['fullName'] as String? ?? '',
    professionalTitle: map['professionalTitle'] as String? ?? '',
    photoBase64: map['photoBase64'] as String?,
    shortBio: map['shortBio'] as String? ?? '',
    longBio: map['longBio'] as String? ?? '',
    city: map['city'] as String? ?? '',
    email: map['email'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    website: map['website'] as String? ?? '',
    github: map['github'] as String? ?? '',
    linkedin: map['linkedin'] as String? ?? '',
    otherLinks: List<String>.from(map['otherLinks'] as List? ?? const []),
  );
}
