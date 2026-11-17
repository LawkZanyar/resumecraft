import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/data/sample/sample_jobs.dart';
import '../jobs_providers.dart';
import '../widgets/job_card.dart';

/// Search by title, category and location.
class JobSearchScreen extends ConsumerStatefulWidget {
  const JobSearchScreen({super.key});

  @override
  ConsumerState<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends ConsumerState<JobSearchScreen> {
  late final _keywords = TextEditingController(text: ref.read(jobSearchProvider).query.keywords);
  late final _location = TextEditingController(text: ref.read(jobSearchProvider).query.location);
  late String _category = ref.read(jobSearchProvider).query.category;

  @override
  void dispose() {
    _keywords.dispose();
    _location.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    final q = ref.read(jobSearchProvider).query;
    ref
        .read(jobSearchProvider.notifier)
        .search(
          q.copyWith(
            keywords: _keywords.text.trim(),
            location: _location.text.trim(),
            category: _category,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(jobSearchProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Search jobs')),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels > n.metrics.maxScrollExtent - 300) {
            ref.read(jobSearchProvider.notifier).loadMore();
          }
          return false;
        },
        child: ListView(
          padding: AppSpacing.page,
          children: [
            TextField(
              key: const Key('job_keywords'),
              controller: _keywords,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: const InputDecoration(
                labelText: 'Job title or skill',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            AppSpacing.gapMd,
            TextField(
              key: const Key('job_location'),
              controller: _location,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: const InputDecoration(
                labelText: 'City or country (any)',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            AppSpacing.gapMd,
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final c in ['', ...sampleJobCategories])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.isEmpty ? 'All' : c),
                        selected: _category == c,
                        onSelected: (_) {
                          setState(() => _category = c);
                          _search();
                        },
                      ),
                    ),
                ],
              ),
            ),
            AppSpacing.gapMd,
            FilledButton.icon(
              key: const Key('job_search_button'),
              onPressed: _search,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Search'),
            ),
            AppSpacing.gapLg,
            if (s.notice != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(s.notice!, style: Theme.of(context).textTheme.bodySmall),
              ),
            if (s.totalCount != null && !s.loading)
              Text('${s.totalCount} results', style: Theme.of(context).textTheme.labelLarge),
            AppSpacing.gapSm,
            if (s.error != null)
              ErrorView(error: s.error!, onRetry: _search)
            else if (s.jobs.isEmpty && s.loading)
              const LoadingView(message: 'Searching…')
            else if (s.jobs.isEmpty)
              const EmptyView(
                icon: Icons.search_off_rounded,
                title: 'No matching jobs',
                message: 'Try fewer words, another city, or "All" categories.',
              )
            else ...[
              for (final j in s.jobs)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: JobCard(job: j),
                ),
              if (s.loading) const LoadingView(),
            ],
          ],
        ),
      ),
    );
  }
}
