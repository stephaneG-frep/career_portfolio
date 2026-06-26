import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    this.onEdit,
    this.onDelete,
    this.maxVisibleTechnologies = 6,
    this.showImageGallery = false,
    super.key,
  });

  final PortfolioProject project;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int maxVisibleTechnologies;
  final bool showImageGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActions = onEdit != null || onDelete != null;
    final visibleTechnologies = project.technologies
        .take(maxVisibleTechnologies)
        .toList();
    final hiddenTechnologies =
        project.technologies.length - visibleTechnologies.length;
    final images = _decodedImages();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImageGallery)
            _ProjectImageGallery(images: images)
          else if (images.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.memory(images.first, fit: BoxFit.cover),
            )
          else
            const _ProjectImagePlaceholder(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(label: Text(project.status.label)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.shortDescription,
                  maxLines: hasActions ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    ...visibleTechnologies.map(
                      (technology) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(technology),
                      ),
                    ),
                    if (hiddenTechnologies > 0)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text('+$hiddenTechnologies'),
                      ),
                  ],
                ),
                if (hasActions) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          tooltip: 'Modifier',
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      if (onDelete != null)
                        IconButton(
                          tooltip: 'Supprimer',
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Uint8List> _decodedImages() => project.imageBase64List
      .map((imageBase64) {
        try {
          return base64Decode(imageBase64);
        } on FormatException {
          return null;
        }
      })
      .whereType<Uint8List>()
      .toList();
}

class _ProjectImageGallery extends StatelessWidget {
  const _ProjectImageGallery({required this.images});

  final List<Uint8List> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const _ProjectImagePlaceholder();

    final otherImages = images.skip(1).toList();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _ProjectImageFrame(
            image: images.first,
            height: 190,
            borderRadius: BorderRadius.circular(16),
          ),
          if (otherImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: otherImages
                  .map(
                    (image) => SizedBox(
                      width: 112,
                      child: _ProjectImageFrame(
                        image: image,
                        height: 86,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectImageFrame extends StatelessWidget {
  const _ProjectImageFrame({
    required this.image,
    required this.height,
    required this.borderRadius,
  });

  final Uint8List image;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: Container(
      height: height,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(6),
      child: Image.memory(image, fit: BoxFit.contain),
    ),
  );
}

class _ProjectImagePlaceholder extends StatelessWidget {
  const _ProjectImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.tertiaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.rocket_launch_outlined,
          size: 42,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
