import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/experience.dart';

class ExperienceTile extends StatelessWidget {
  const ExperienceTile({
    required this.experience,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Experience experience;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.yMMM('fr');
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          child: Icon(
            experience.type == ExperienceType.training
                ? Icons.school_outlined
                : Icons.business_center_outlined,
          ),
        ),
        title: Text(
          experience.position,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${experience.company} • ${experience.type.label}'),
              Text(
                '${format.format(experience.startDate)} — '
                '${experience.endDate == null ? 'Aujourd’hui' : format.format(experience.endDate!)}',
              ),
              if (experience.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(experience.description),
              ],
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              value == 'edit' ? onEdit?.call() : onDelete?.call(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }
}
