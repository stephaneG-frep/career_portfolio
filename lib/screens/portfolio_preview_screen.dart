import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/education_provider.dart';
import '../providers/experience_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/project_provider.dart';
import '../providers/skill_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/project_card.dart';
import '../widgets/skill_chip.dart';

class PortfolioPreviewScreen extends StatelessWidget {
  const PortfolioPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final skills = context.watch<SkillProvider>().items;
    final projects = context.watch<ProjectProvider>().items;
    final experiences = context.watch<ExperienceProvider>().items;
    final education = context.watch<EducationProvider>().items;
    return Scaffold(
      appBar: AppBar(title: const Text('Aperçu de la vitrine')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(profile: profile),
                  _section(context, 'À propos', Text(profile.longBio)),
                  _section(
                    context,
                    'Compétences',
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: skills
                          .map(
                            (skill) => SizedBox(
                              width: 320,
                              child: SkillChip(skill: skill),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _section(
                    context,
                    'Projets',
                    LayoutBuilder(
                      builder: (context, constraints) => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projects.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth > 720 ? 2 : 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 350,
                        ),
                        itemBuilder: (_, index) =>
                            ProjectCard(project: projects[index]),
                      ),
                    ),
                  ),
                  _section(
                    context,
                    'Expériences',
                    Column(
                      children: experiences
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.timeline),
                              title: Text(item.position),
                              subtitle: Text(
                                '${item.company}\n${item.description}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _section(
                    context,
                    'Formations',
                    Column(
                      children: education
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.school_outlined),
                              title: Text(item.name),
                              subtitle: Text(item.organization),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _section(
                    context,
                    'Contact',
                    Wrap(
                      spacing: 10,
                      children: [
                        if (profile.email.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.email_outlined),
                            label: Text(profile.email),
                          ),
                        if (profile.website.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.language),
                            label: Text(profile.website),
                          ),
                        if (profile.github.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.code),
                            label: Text(profile.github),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) => Padding(
    padding: const EdgeInsets.only(top: 36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}
