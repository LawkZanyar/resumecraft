import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/state_views.dart';
import 'routes.dart';

/// Shown for unknown links, so a route never fails silently.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.location});

  final String? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not available')),
      body: EmptyView(
        icon: Icons.explore_off_outlined,
        title: 'This screen is not available',
        message: location == null
            ? null
            : 'Nothing is registered for "$location" yet.',
        action: FilledButton(
          onPressed: () => context.go(Routes.home),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}
