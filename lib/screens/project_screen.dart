import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import 'project_form_screen.dart';

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => provider.updateFilters(query: value),
                    decoration: const InputDecoration(
                      labelText: 'Rechercher un projet ou une technologie',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: provider.technology,
                          decoration: const InputDecoration(
                            labelText: 'Technologie',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Toutes'),
                            ),
                            ...provider.technologies.map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            ),
                          ],
                          onChanged: (value) => provider.updateFilters(
                            technology: value,
                            clearTechnology: value == null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<ProjectStatus?>(
                          initialValue: provider.status,
                          decoration: const InputDecoration(
                            labelText: 'Statut',
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tous'),
                            ),
                            ...ProjectStatus.values.map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                            ),
                          ],
                          onChanged: (value) => provider.updateFilters(
                            status: value,
                            clearStatus: value == null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (provider.filteredItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Text('Aucun projet ne correspond aux filtres.'),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth > 760 ? 2 : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.filteredItems.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 410,
                              ),
                          itemBuilder: (_, index) {
                            final project = provider.filteredItems[index];
                            return ProjectCard(
                              project: project,
                              onEdit: () => _edit(context, project),
                              onDelete: () => _delete(context, project),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'project_add_fab',
        onPressed: () => _edit(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Projet'),
      ),
    );
  }

  Future<void> _edit(BuildContext context, PortfolioProject? project) async {
    final result = await Navigator.push<PortfolioProject>(
      context,
      MaterialPageRoute(builder: (_) => ProjectFormScreen(project: project)),
    );
    if (result != null && context.mounted) {
      await context.read<ProjectProvider>().save(result);
    }
  }

  Future<void> _delete(BuildContext context, PortfolioProject project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce projet ?'),
        content: Text('« ${project.name} » sera supprimé définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProjectProvider>().delete(project.id);
    }
  }
}
