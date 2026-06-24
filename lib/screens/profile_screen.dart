import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/profile_provider.dart';
import '../services/image_picker_service.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(profile: profile),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'À propos',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => _openEditor(context, profile),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Modifier'),
                            ),
                          ],
                        ),
                        if (profile.longBio.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(profile.longBio),
                        ],
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            if (profile.city.isNotEmpty)
                              _Info(Icons.location_on_outlined, profile.city),
                            if (profile.email.isNotEmpty)
                              _Info(Icons.email_outlined, profile.email),
                            if (profile.phone.isNotEmpty)
                              _Info(Icons.phone_outlined, profile.phone),
                            if (profile.website.isNotEmpty)
                              _Info(Icons.language, profile.website),
                            if (profile.github.isNotEmpty)
                              _Info(Icons.code, profile.github),
                            if (profile.linkedin.isNotEmpty)
                              _Info(Icons.link, profile.linkedin),
                          ],
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

  Future<void> _openEditor(BuildContext context, Profile profile) async {
    final result = await showDialog<Profile>(
      context: context,
      builder: (_) => _ProfileDialog(profile: profile),
    );
    if (result != null && context.mounted) {
      await context.read<ProfileProvider>().save(result);
    }
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 18), label: Text(text));
}

class _ProfileDialog extends StatefulWidget {
  const _ProfileDialog({required this.profile});
  final Profile profile;

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _photoBase64 = p.photoBase64;
    _controllers = {
      'name': TextEditingController(text: p.fullName),
      'title': TextEditingController(text: p.professionalTitle),
      'short': TextEditingController(text: p.shortBio),
      'long': TextEditingController(text: p.longBio),
      'city': TextEditingController(text: p.city),
      'email': TextEditingController(text: p.email),
      'phone': TextEditingController(text: p.phone),
      'website': TextEditingController(text: p.website),
      'github': TextEditingController(text: p.github),
      'linkedin': TextEditingController(text: p.linkedin),
      'links': TextEditingController(text: p.otherLinks.join('\n')),
    };
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
    return AlertDialog(
      title: const Text('Profil professionnel'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundImage: _photoBase64 == null
                          ? null
                          : MemoryImage(base64Decode(_photoBase64!)),
                      child: _photoBase64 == null
                          ? const Icon(Icons.person, size: 42)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final value = await ImagePickerService()
                            .pickImageAsBase64();
                        if (value != null && mounted) {
                          setState(() => _photoBase64 = value);
                        }
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choisir une photo'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _field('name', 'Nom complet', required: true),
                _field('title', 'Titre professionnel', required: true),
                _field('short', 'Présentation courte', lines: 2),
                _field('long', 'Présentation longue', lines: 4),
                _field('city', 'Ville'),
                _field('email', 'Email', type: TextInputType.emailAddress),
                _field('phone', 'Téléphone', type: TextInputType.phone),
                _field('website', 'Site web'),
                _field('github', 'GitHub'),
                _field('linkedin', 'LinkedIn'),
                _field('links', 'Autres liens (un par ligne)', lines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Enregistrer')),
      ],
    );
  }

  Widget _field(
    String key,
    String label, {
    int lines = 1,
    bool required = false,
    TextInputType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: _controllers[key],
      maxLines: lines,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Ce champ est obligatoire'
                : null
          : null,
    ),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    String value(String key) => _controllers[key]!.text.trim();
    Navigator.pop(
      context,
      Profile(
        fullName: value('name'),
        professionalTitle: value('title'),
        photoBase64: _photoBase64,
        shortBio: value('short'),
        longBio: value('long'),
        city: value('city'),
        email: value('email'),
        phone: value('phone'),
        website: value('website'),
        github: value('github'),
        linkedin: value('linkedin'),
        otherLinks: value('links')
            .split('\n')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
      ),
    );
  }
}
