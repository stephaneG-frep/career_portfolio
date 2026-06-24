import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';
import '../services/image_picker_service.dart';

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({this.project, super.key});
  final PortfolioProject? project;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late ProjectStatus _status;
  DateTime? _startDate;
  DateTime? _endDate;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _controllers = {
      'name': TextEditingController(text: p?.name),
      'short': TextEditingController(text: p?.shortDescription),
      'details': TextEditingController(text: p?.detailedDescription),
      'tech': TextEditingController(text: p?.technologies.join(', ')),
      'github': TextEditingController(text: p?.githubUrl),
      'demo': TextEditingController(text: p?.demoUrl),
      'notes': TextEditingController(text: p?.notes),
    };
    _status = p?.status ?? ProjectStatus.idea;
    _startDate = p?.startDate;
    _endDate = p?.endDate;
    _images = [...?p?.imageBase64List];
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project == null ? 'Nouveau projet' : 'Modifier le projet',
        ),
        actions: [
          TextButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  children: [
                    _field('name', 'Nom du projet', required: true),
                    _field(
                      'short',
                      'Description courte',
                      lines: 2,
                      required: true,
                    ),
                    _field('details', 'Description détaillée', lines: 5),
                    _field('tech', 'Technologies (séparées par des virgules)'),
                    DropdownButtonFormField(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: ProjectStatus.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _status = value!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DateButton(
                            label: 'Date de début',
                            date: _startDate,
                            onTap: () => _pickDate(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateButton(
                            label: 'Date de fin',
                            date: _endDate,
                            onTap: () => _pickDate(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field('github', 'Lien GitHub'),
                    _field('demo', 'Lien de démonstration'),
                    _field('notes', 'Notes', lines: 3),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Captures d’écran',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final selected = await ImagePickerService()
                                .pickMultipleImagesAsBase64();
                            if (mounted) {
                              setState(() => _images.addAll(selected));
                            }
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Ajouter'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_images.isNotEmpty)
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, index) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.memory(
                                  base64Decode(_images[index]),
                                  width: 190,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: IconButton.filledTonal(
                                  onPressed: () =>
                                      setState(() => _images.removeAt(index)),
                                  icon: const Icon(Icons.close),
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
        ),
      ),
    );
  }

  Widget _field(
    String key,
    String label, {
    int lines = 1,
    bool required = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: _controllers[key],
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Ce champ est obligatoire'
                : null
          : null,
    ),
  );

  Future<void> _pickDate(bool isStart) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => isStart ? _startDate = selected : _endDate = selected);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    String value(String key) => _controllers[key]!.text.trim();
    Navigator.pop(
      context,
      PortfolioProject(
        id: widget.project?.id ?? const Uuid().v4(),
        name: value('name'),
        shortDescription: value('short'),
        detailedDescription: value('details'),
        technologies: value('tech')
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList(),
        imageBase64List: _images,
        githubUrl: value('github'),
        demoUrl: value('demo'),
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
        notes: value('notes'),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.calendar_today_outlined),
    label: Text(
      date == null ? label : '$label : ${DateFormat.yMMMd('fr').format(date!)}',
    ),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      alignment: Alignment.centerLeft,
    ),
  );
}
