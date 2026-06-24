import 'package:flutter/material.dart';

import '../models/skill.dart';

class SkillChip extends StatelessWidget {
  const SkillChip({required this.skill, this.onTap, super.key});

  final Skill skill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(skill.colorValue);
    return Material(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                foregroundColor: Colors.white,
                child: Text(skill.name.characters.first.toUpperCase()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('${skill.category.label} • ${skill.level.label}'),
                    if (skill.note.isNotEmpty)
                      Text(
                        skill.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
