import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../application_providers.dart';
import '../widgets/application_widgets.dart';

/// Change status, dates and notes of one application.
class ApplicationDetailsScreen extends ConsumerStatefulWidget {
  const ApplicationDetailsScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  ConsumerState<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends ConsumerState<ApplicationDetailsScreen> {
  final _notes = TextEditingController();
  bool _notesLoaded = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save(JobApplication updated, {String? message}) async {
    final r = await ref.read(applicationRepositoryProvider).updateApplication(updated);
    if (!mounted) return;
    if (!r.isOk) {
      showAppSnackBar(context, 'Could not save the change.', error: true);
    } else if (message != null) {
      showAppSnackBar(context, message);
    }
  }

  Future<DateTime?> _pickDateTime(DateTime? initial, {bool withTime = true}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return null;
    if (!withTime) return DateTime(date.year, date.month, date.day, 9);
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime(now.year, now.month, now.day, 10)),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _delete(JobApplication a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove from tracker?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(applicationRepositoryProvider).deleteApplication(a.applicationId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(applicationByIdProvider(widget.applicationId));
    return Scaffold(
      appBar: AppBar(title: const Text('Application')),
      body: AsyncValueView<JobApplication?>(
        value: app,
        data: (a) {
          if (a == null) {
            return const EmptyView(icon: Icons.search_off_rounded, title: 'Application not found');
          }
          if (!_notesLoaded) {
            _notes.text = a.notes;
            _notesLoaded = true;
          }
          final text = Theme.of(context).textTheme;
          return ListView(
            padding: AppSpacing.page,
            children: [
              AppCard(
                onTap: () => context.push(Routes.jobDetails(a.jobId)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.jobSnapshot.title, style: text.titleMedium),
                    Text('${a.jobSnapshot.company} · ${a.jobSnapshot.location}'),
                  ],
                ),
              ),
              const SectionHeader('Status'),
              DropdownButtonFormField<ApplicationStatus>(
                key: const Key('status_dropdown'),
                initialValue: a.status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final s in ApplicationStatus.values)
                    DropdownMenuItem(value: s, child: StatusPill(s)),
                ],
                onChanged: (s) {
                  if (s == null || s == a.status) return;
                  final applied = s == ApplicationStatus.applied && a.applicationDate == null
                      ? DateTime.now()
                      : null;
                  _save(
                    a.copyWith(status: s, applicationDate: applied),
                    message: 'Status: ${s.label}',
                  );
                },
              ),
              const SectionHeader('Dates'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _DateTile(
                      icon: Icons.send_outlined,
                      label: 'Application date',
                      value: Formatters.date(a.applicationDate),
                      onTap: () async {
                        final d = await _pickDateTime(a.applicationDate, withTime: false);
                        if (d != null) await _save(a.copyWith(applicationDate: d));
                      },
                    ),
                    _DateTile(
                      key: const Key('interview_date_tile'),
                      icon: Icons.event_available_rounded,
                      label: 'Interview',
                      value: Formatters.dateTime(a.interviewDate),
                      onClear: a.interviewDate == null
                          ? null
                          : () => _save(a.copyWith(clearInterviewDate: true)),
                      onTap: () async {
                        final d = await _pickDateTime(a.interviewDate);
                        if (d != null) {
                          await _save(
                            a.copyWith(
                              interviewDate: d,
                              status: ApplicationStatus.interviewScheduled,
                            ),
                            message: 'Interview date saved',
                          );
                        }
                      },
                    ),
                    _DateTile(
                      icon: Icons.mark_email_unread_outlined,
                      label: 'Follow-up',
                      value: Formatters.dateTime(a.followUpDate),
                      onClear: a.followUpDate == null
                          ? null
                          : () => _save(a.copyWith(clearFollowUpDate: true)),
                      onTap: () async {
                        final d = await _pickDateTime(a.followUpDate);
                        if (d != null) {
                          await _save(a.copyWith(followUpDate: d), message: 'Follow-up date saved');
                        }
                      },
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,
              const PhaseLockedTile(
                phase: 4,
                icon: Icons.notifications_active_outlined,
                title: 'Reminders for these dates',
              ),
              const SectionHeader('Notes'),
              TextField(
                key: const Key('application_notes'),
                controller: _notes,
                maxLines: 5,
                minLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Contacts, questions to ask, salary notes…',
                ),
              ),
              AppSpacing.gapSm,
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: const Key('save_notes'),
                  onPressed: () => _save(a.copyWith(notes: _notes.text), message: 'Notes saved'),
                  child: const Text('Save notes'),
                ),
              ),
              const SectionHeader('Follow-up message'),
              const PhaseLockedButton(
                phase: 4,
                label: 'Write a follow-up message with AI',
                icon: Icons.auto_awesome,
              ),
              AppSpacing.gapXl,
              TextButton.icon(
                onPressed: () => _delete(a),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove from tracker'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value),
    onTap: onTap,
    trailing: onClear == null
        ? const Icon(Icons.edit_calendar_outlined)
        : IconButton(tooltip: 'Clear', icon: const Icon(Icons.close_rounded), onPressed: onClear),
  );
}
