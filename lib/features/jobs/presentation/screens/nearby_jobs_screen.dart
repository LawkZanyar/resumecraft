import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../domain/geo.dart';
import '../jobs_providers.dart';
import '../widgets/job_card.dart';

/// Nearby layout: radius control and job markers around a center point.
/// Phase 1 uses a labeled sample location; GPS and the real map come in Phase 3.
class NearbyJobsScreen extends ConsumerStatefulWidget {
  const NearbyJobsScreen({super.key});

  @override
  ConsumerState<NearbyJobsScreen> createState() => _NearbyJobsScreenState();
}

class _NearbyJobsScreenState extends ConsumerState<NearbyJobsScreen> {
  double _radius = 25;
  AsyncValue<List<Job>> _jobs = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _jobs = const AsyncLoading());
    final r = await ref
        .read(jobRepositoryProvider)
        .searchJobs(
          JobQuery(
            latitude: sampleCenter.latitude,
            longitude: sampleCenter.longitude,
            radiusKm: _radius,
            pageSize: 100,
          ),
        );
    if (!mounted) return;
    setState(
      () => _jobs = r.when(
        ok: (p) => AsyncData(p.jobs),
        err: (f) => AsyncError(f, StackTrace.current),
      ),
    );
  }

  double _dist(Job j) =>
      distanceKm(sampleCenter.latitude, sampleCenter.longitude, j.latitude!, j.longitude!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby jobs')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const AppCard(
            child: Row(
              children: [
                Icon(Icons.place_rounded),
                AppSpacing.gapSm,
                Expanded(child: Text('Center: $sampleCenterName')),
                SampleBadge(text: 'Sample location'),
              ],
            ),
          ),
          AppSpacing.gapSm,
          const PhaseLockedButton(
            phase: 3,
            label: 'Use my location',
            icon: Icons.my_location_rounded,
          ),
          AppSpacing.gapLg,
          Text(
            'Search radius: ${_radius.round()} km',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            key: const Key('radius_slider'),
            value: _radius,
            min: 5,
            max: 200,
            divisions: 39,
            label: '${_radius.round()} km',
            onChanged: (v) => setState(() => _radius = v),
            onChangeEnd: (_) => _load(),
          ),
          _jobs.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(error: e, onRetry: _load),
            data: (jobs) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RadarLayout(jobs: jobs, radiusKm: _radius),
                AppSpacing.gapSm,
                Text(
                  'Layout preview. The interactive map arrives in Phase 3.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SectionHeader('${jobs.length} jobs within ${_radius.round()} km'),
                if (jobs.isEmpty)
                  EmptyView(
                    icon: Icons.location_searching_rounded,
                    title: 'No jobs in this radius',
                    action: OutlinedButton(
                      onPressed: () {
                        setState(() => _radius = math.min(200, _radius * 2));
                        _load();
                      },
                      child: const Text('Widen the search'),
                    ),
                  ),
                for (final j in jobs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: JobCard(job: j, distanceKm: _dist(j)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple projection of job positions around the center inside a circle.
class _RadarLayout extends StatelessWidget {
  const _RadarLayout({required this.jobs, required this.radiusKm});

  final List<Job> jobs;
  final double radiusKm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1.4,
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          final r = math.min(size.width, size.height) / 2 - 16;
          final c = Offset(size.width / 2, size.height / 2);
          Offset pos(Job j) {
            const kmPerDegLat = 110.574;
            final kmPerDegLng = 111.320 * math.cos(sampleCenter.latitude * math.pi / 180);
            final dy = (j.latitude! - sampleCenter.latitude) * kmPerDegLat;
            final dx = (j.longitude! - sampleCenter.longitude) * kmPerDegLng;
            return c + Offset(dx / radiusKm * r, -dy / radiusKm * r);
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              color: scheme.surfaceContainerHigh,
              child: Stack(
                children: [
                  CustomPaint(size: size, painter: _RingsPainter(c, r, scheme.outline)),
                  Positioned(
                    left: c.dx - 10,
                    top: c.dy - 10,
                    child: Icon(Icons.my_location_rounded, size: 20, color: scheme.secondary),
                  ),
                  for (final j in jobs.where((j) => j.hasPosition))
                    Positioned(
                      left: pos(j).dx - 14,
                      top: pos(j).dy - 28,
                      child: Tooltip(
                        message: '${j.title} · ${j.company}',
                        child: GestureDetector(
                          onTap: () => context.push(Routes.jobDetails(j.jobId)),
                          child: Icon(Icons.location_on_rounded, size: 28, color: scheme.tertiary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter(this.center, this.radius, this.color);

  final Offset center;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1;
    for (final f in [0.33, 0.66, 1.0]) {
      canvas.drawCircle(center, radius * f, p);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.radius != radius || old.color != color;
}
