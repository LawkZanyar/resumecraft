import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// Initials avatar. Profile photos stay local, so initials are the fallback.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, this.radius = 28});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        Formatters.initials(name),
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
