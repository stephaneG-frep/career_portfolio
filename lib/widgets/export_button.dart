import 'package:flutter/material.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(radius: 25, child: Icon(icon)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(description),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: loading ? null : onPressed,
              child: loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Exporter'),
            ),
          ],
        ),
      ),
    );
  }
}
