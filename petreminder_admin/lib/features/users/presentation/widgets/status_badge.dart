import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF247A57) : const Color(0xFFA43E49);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check_circle_outline : Icons.block_outlined,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 5),
            Text(
              active ? 'Activa' : 'Deshabilitada',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
