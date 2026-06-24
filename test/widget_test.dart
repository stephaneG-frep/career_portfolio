import 'package:career_portfolio/models/profile.dart';
import 'package:career_portfolio/models/project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le profil conserve ses données après sérialisation', () {
    const profile = Profile(
      fullName: 'Ada Lovelace',
      professionalTitle: 'Ingénieure',
      otherLinks: ['https://example.com'],
    );

    final restored = Profile.fromMap(profile.toMap());

    expect(restored.fullName, 'Ada Lovelace');
    expect(restored.otherLinks, ['https://example.com']);
  });

  test('un projet conserve son statut et ses technologies', () {
    const project = PortfolioProject(
      id: '1',
      name: 'CareerPortfolio',
      shortDescription: 'Portfolio local',
      technologies: ['Flutter', 'Hive'],
      status: ProjectStatus.published,
    );

    final restored = PortfolioProject.fromMap(project.toMap());

    expect(restored.status, ProjectStatus.published);
    expect(restored.technologies, contains('Hive'));
  });
}
