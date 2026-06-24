import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/education.dart';
import '../providers/education_provider.dart';
import '../services/image_picker_service.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<EducationProvider>().items;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.isEmpty ? 1 : items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Text('Aucune formation ou certification.'),
            ),
          );
        }
        final item = items[index];
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const CircleAvatar(child: Icon(Icons.school_outlined)),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${item.organization} • ${DateFormat.yMMM('fr').format(item.date)}'
                  '${item.duration.isEmpty ? '' : ' • ${item.duration}'}'
                  '${item.notes.isEmpty ? '' : '\n${item.notes}'}',
                ),
                trailing: IconButton(
                  onPressed: () => openEditor(context, education: item),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> openEditor(
    BuildContext context, {
    Education? education,
  }) async {
    final result = await showDialog<_EducationResult>(
      context: context,
      builder: (_) => _EducationDialog(education: education),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<EducationProvider>();
    if (result.delete) {
      await provider.delete(education!.id);
    } else {
      await provider.save(result.education!);
    }
  }
}

class _EducationResult {
  const _EducationResult.save(this.education) : delete = false;
  const _EducationResult.delete() : education = null, delete = true;
  final Education? education;
  final bool delete;
}

class _EducationDialog extends StatefulWidget {
  const _EducationDialog({this.education});
  final Education? education;

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _organization;
  late final TextEditingController _duration;
  late final TextEditingController _notes;
  late DateTime _date;
  String? _certificate;

  @override
  void initState() {
    super.initState();
    final item = widget.education;
    _name = TextEditingController(text: item?.name);
    _organization = TextEditingController(text: item?.organization);
    _duration = TextEditingController(text: item?.duration);
    _notes = TextEditingController(text: item?.notes);
    _date = item?.date ?? DateTime.now();
    _certificate = item?.certificateBase64;
  }

  @override
  void dispose() {
    _name.dispose();
    _organization.dispose();
    _duration.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Formation ou certification'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _required(_name, 'Nom de la formation'),
              _required(_organization, 'Organisme'),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) setState(() => _date = selected);
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(DateFormat.yMMMd('fr').format(_date)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _duration,
                decoration: const InputDecoration(labelText: 'Durée'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final value = await ImagePickerService().pickImageAsBase64();
                  if (value != null && mounted) {
                    setState(() => _certificate = value);
                  }
                },
                icon: Icon(
                  _certificate == null
                      ? Icons.attach_file
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  _certificate == null
                      ? 'Ajouter une preuve (image)'
                      : 'Preuve ajoutée',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      if (widget.education != null)
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const _EducationResult.delete()),
          child: const Text('Supprimer'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Enregistrer')),
    ],
  );

  Widget _required(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Ce champ est obligatoire'
          : null,
    ),
  );

  void _submit() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      _EducationResult.save(
        Education(
          id: widget.education?.id ?? const Uuid().v4(),
          name: _name.text.trim(),
          organization: _organization.text.trim(),
          date: _date,
          duration: _duration.text.trim(),
          certificateBase64: _certificate,
          notes: _notes.text.trim(),
        ),
      ),
    );
  }
}
