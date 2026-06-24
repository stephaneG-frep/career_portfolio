import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/experience.dart';
import '../providers/experience_provider.dart';
import '../widgets/experience_tile.dart';
import 'education_screen.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(
                  text: 'Expériences',
                  icon: Icon(Icons.work_history_outlined),
                ),
                Tab(text: 'Formations', icon: Icon(Icons.school_outlined)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ExperienceList(onAdd: () => _openDialog(context, null)),
                  const EducationScreen(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () {
              if (DefaultTabController.of(context).index == 0) {
                _openDialog(context, null);
              } else {
                EducationScreen.openEditor(context);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        ),
      ),
    );
  }

  static Future<void> _openDialog(
    BuildContext context,
    Experience? experience,
  ) async {
    final result = await showDialog<_ExperienceResult>(
      context: context,
      builder: (_) => _ExperienceDialog(experience: experience),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<ExperienceProvider>();
    if (result.delete) {
      await provider.delete(experience!.id);
    } else {
      await provider.save(result.experience!);
    }
  }
}

class _ExperienceList extends StatelessWidget {
  const _ExperienceList({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ExperienceProvider>().items;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.isEmpty ? 1 : items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une expérience'),
              ),
            ),
          );
        }
        final item = items[index];
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ExperienceTile(
              experience: item,
              onEdit: () => ExperienceScreen._openDialog(context, item),
              onDelete: () => ExperienceScreen._openDialog(context, item),
            ),
          ),
        );
      },
    );
  }
}

class _ExperienceResult {
  const _ExperienceResult.save(this.experience) : delete = false;
  const _ExperienceResult.delete() : experience = null, delete = true;
  final Experience? experience;
  final bool delete;
}

class _ExperienceDialog extends StatefulWidget {
  const _ExperienceDialog({this.experience});
  final Experience? experience;

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _position;
  late final TextEditingController _company;
  late final TextEditingController _description;
  late final TextEditingController _skills;
  late ExperienceType _type;
  late DateTime _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final item = widget.experience;
    _position = TextEditingController(text: item?.position);
    _company = TextEditingController(text: item?.company);
    _description = TextEditingController(text: item?.description);
    _skills = TextEditingController(text: item?.skills.join(', '));
    _type = item?.type ?? ExperienceType.job;
    _start = item?.startDate ?? DateTime.now();
    _end = item?.endDate;
  }

  @override
  void dispose() {
    _position.dispose();
    _company.dispose();
    _description.dispose();
    _skills.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.experience == null ? 'Nouvelle expérience' : 'Expérience',
    ),
    content: SizedBox(
      width: 620,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _requiredField(_position, 'Poste'),
              _requiredField(_company, 'Entreprise ou organisme'),
              DropdownButtonFormField(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ExperienceType.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dateButton(
                      'Début',
                      _start,
                      (date) => _start = date,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateButton(
                      'Fin (optionnel)',
                      _end,
                      (date) => _end = date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skills,
                decoration: const InputDecoration(
                  labelText:
                      'Compétences utilisées (séparées par des virgules)',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      if (widget.experience != null)
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const _ExperienceResult.delete()),
          child: const Text('Supprimer'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Enregistrer')),
    ],
  );

  Widget _requiredField(TextEditingController controller, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ce champ est obligatoire'
              : null,
        ),
      );

  Widget _dateButton(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onChanged,
  ) => OutlinedButton.icon(
    onPressed: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2100),
      );
      if (selected != null) {
        onChanged(selected);
        setState(() {});
      }
    },
    icon: const Icon(Icons.calendar_today_outlined),
    label: Text(date == null ? label : DateFormat.yMMMd('fr').format(date)),
    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
  );

  void _submit() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      _ExperienceResult.save(
        Experience(
          id: widget.experience?.id ?? const Uuid().v4(),
          position: _position.text.trim(),
          company: _company.text.trim(),
          type: _type,
          startDate: _start,
          endDate: _end,
          description: _description.text.trim(),
          skills: _skills.text
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(),
        ),
      ),
    );
  }
}
