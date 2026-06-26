import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/education_provider.dart';
import '../providers/experience_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/project_provider.dart';
import '../providers/skill_provider.dart';
import '../services/html_export_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/export_button.dart';
import 'portfolio_preview_screen.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _exportingPdf = false;
  bool _exportingHtml = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.public,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Votre vitrine professionnelle',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prévisualisez le résultat avant de créer vos fichiers.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PortfolioPreviewScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Ouvrir l’aperçu'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ExportButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Portfolio PDF',
                  description:
                      'Document professionnel avec page de garde, parcours et coordonnées.',
                  loading: _exportingPdf,
                  onPressed: () => _export(pdf: true),
                ),
                const SizedBox(height: 14),
                ExportButton(
                  icon: Icons.html_outlined,
                  label: 'Site HTML statique',
                  description:
                      'Archive ZIP contenant index.html et le dossier assets/, prête à héberger.',
                  loading: _exportingHtml,
                  onPressed: () => _export(pdf: false),
                ),
                const SizedBox(height: 18),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Toutes les données et les images restent sur cet appareil. '
                            'Aucun compte, serveur ou service externe n’est utilisé.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _export({required bool pdf}) async {
    setState(() => pdf ? _exportingPdf = true : _exportingHtml = true);
    try {
      final profile = context.read<ProfileProvider>().profile;
      final skills = context.read<SkillProvider>().items;
      final projects = context.read<ProjectProvider>().items;
      final experiences = context.read<ExperienceProvider>().items;
      final education = context.read<EducationProvider>().items;
      if (pdf) {
        await PdfExportService().export(
          profile: profile,
          skills: skills,
          projects: projects,
          experiences: experiences,
          education: education,
        );
      } else {
        final htmlPath = await HtmlExportService().export(
          profile: profile,
          skills: skills,
          projects: projects,
          experiences: experiences,
          education: education,
        );
        if (htmlPath == null && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Export HTML annulé.')));
          return;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archive HTML créée : $htmlPath'),
              duration: const Duration(seconds: 8),
            ),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pdf ? 'Export PDF prêt.' : 'Archive HTML créée avec succès.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d’exporter : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => pdf ? _exportingPdf = false : _exportingHtml = false);
      }
    }
  }
}
