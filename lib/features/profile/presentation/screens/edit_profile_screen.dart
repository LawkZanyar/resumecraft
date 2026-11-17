import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save(UserProfile profile) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final result = await ref.read(profileRepositoryProvider).saveProfile(
          profile.copyWith(
            fullName: _name.text.trim(),
            location: _location.text.trim(),
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      ok: (_) {
        showAppSnackBar(context, 'Profile saved');
        Navigator.of(context).maybePop();
      },
      err: (f) => showAppSnackBar(context, f.message, error: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: AsyncValueView(
        value: profile,
        data: (p) {
          if (p == null) {
            return const EmptyView(icon: Icons.person_off_outlined, title: 'Not signed in');
          }
          if (!_loaded) {
            _name.text = p.fullName;
            _location.text = p.location ?? '';
            _loaded = true;
          }
          return Form(
            key: _form,
            child: ListView(
              padding: AppSpacing.page,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: Validators.name,
                ),
                AppSpacing.gapLg,
                TextFormField(
                  initialValue: p.email,
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                AppSpacing.gapLg,
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(
                    labelText: 'City or country',
                    hintText: 'For example: Erbil, Iraq',
                  ),
                  validator: (v) => Validators.maxLength(v, 80),
                ),
                AppSpacing.gapXl,
                PrimaryButton(
                  label: 'Save changes',
                  loading: _saving,
                  onPressed: () => _save(p),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
