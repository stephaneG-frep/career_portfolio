import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/skill.dart';
import '../providers/skill_provider.dart';
import '../widgets/skill_chip.dart';

class SkillScreen extends StatelessWidget {
  const SkillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SkillProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<SkillCategory?>(
                    initialValue: provider.categoryFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par catégorie',
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Toutes les catégories'),
                      ),
                      ...SkillCategory.values.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        ),
                      ),
                    ],
                    onChanged: provider.setCategoryFilter,
                  ),
                  const SizedBox(height: 18),
                  if (provider.filteredItems.isEmpty)
                    const _EmptySkills()
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth > 720 ? 2 : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.filteredItems.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 104,
                              ),
                          itemBuilder: (_, index) {
                            final skill = provider.filteredItems[index];
                            return SkillChip(
                              skill: skill,
                              onTap: () => _openDialog(context, skill),
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
        heroTag: 'skill_add_fab',
        onPressed: () => _openDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Compétence'),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context, Skill? skill) async {
    final result = await showDialog<_SkillResult>(
      context: context,
      builder: (_) => _SkillDialog(skill: skill),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<SkillProvider>();
    if (result.delete) {
      await provider.delete(skill!.id);
    } else {
      await provider.save(result.skill!);
    }
  }
}

class _EmptySkills extends StatelessWidget {
  const _EmptySkills();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(48),
    child: Center(child: Text('Aucune compétence dans cette catégorie.')),
  );
}

class _SkillResult {
  const _SkillResult.save(this.skill) : delete = false;
  const _SkillResult.delete() : skill = null, delete = true;
  final Skill? skill;
  final bool delete;
}

class _SkillDialog extends StatefulWidget {
  const _SkillDialog({this.skill});
  final Skill? skill;

  @override
  State<_SkillDialog> createState() => _SkillDialogState();
}

class _SkillDialogState extends State<_SkillDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _note;
  late SkillCategory _category;
  late SkillLevel _level;
  late int _color;
  static const _colors = [
    0xFF00A8E8,
    0xFF7C4DFF,
    0xFF006D77,
    0xFFE76F51,
    0xFF2A9D8F,
    0xFFF4A261,
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.skill?.name);
    _note = TextEditingController(text: widget.skill?.note);
    _category = widget.skill?.category ?? SkillCategory.mobile;
    _level = widget.skill?.level ?? SkillLevel.intermediate;
    _color = widget.skill?.colorValue ?? _colors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.skill == null ? 'Nouvelle compétence' : 'Compétence'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Indiquez un nom'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: SkillCategory.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                initialValue: _level,
                decoration: const InputDecoration(labelText: 'Niveau'),
                items: SkillLevel.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _level = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note personnelle',
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Couleur',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colors
                    .map(
                      (color) => InkWell(
                        onTap: () => setState(() => _color = color),
                        borderRadius: BorderRadius.circular(30),
                        child: CircleAvatar(
                          backgroundColor: Color(color),
                          child: _color == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      if (widget.skill != null)
        TextButton(
          onPressed: () => Navigator.pop(context, const _SkillResult.delete()),
          child: const Text('Supprimer'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Enregistrer')),
    ],
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _SkillResult.save(
        Skill(
          id: widget.skill?.id ?? const Uuid().v4(),
          name: _name.text.trim(),
          category: _category,
          level: _level,
          note: _note.text.trim(),
          colorValue: _color,
        ),
      ),
    );
  }
}
