import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = profile.photoBase64 == null
        ? null
        : base64Decode(profile.photoBase64!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 18,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white.withValues(alpha: .18),
            backgroundImage: bytes == null ? null : MemoryImage(bytes),
            child: bytes == null
                ? const Icon(Icons.person, size: 54, color: Colors.white)
                : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.professionalTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: .9),
                  ),
                ),
                if (profile.shortBio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    profile.shortBio,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: .88),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
