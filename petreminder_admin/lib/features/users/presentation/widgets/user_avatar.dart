import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.name,
    required this.photoUrl,
    this.radius = 22,
    super.key,
  });

  final String name;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      backgroundImage: url != null && url.startsWith('http')
          ? NetworkImage(url)
          : null,
      child: url == null || !url.startsWith('http')
          ? Text(initial, style: const TextStyle(fontWeight: FontWeight.w700))
          : null,
    );
  }
}
