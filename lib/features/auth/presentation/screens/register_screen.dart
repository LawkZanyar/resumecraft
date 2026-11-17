import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../auth_providers.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final profiles = ref.read(profileRepositoryProvider);
    final ok = await ref.read(authFormControllerProvider.notifier).run((repo) async {
      final result = await repo.register(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      final user = result.valueOrNull;
      if (user != null) {
        await profiles.saveProfile(
          UserProfile(
            userId: user.uid,
            fullName: _name.text.trim(),
            email: user.email,
            createdAt: DateTime.now(),
          ),
        );
      }
      return result;
    });
    if (ok && mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFormControllerProvider);
    ref.listen(authFormControllerProvider, (_, next) {
      if (next is AsyncError) {
        showAppSnackBar(context, ErrorView.messageFor(next.error), error: true);
      }
    });
    return AuthScaffold(
      showBack: true,
      title: 'Create your account',
      subtitle: 'Your resumes and applications stay private to you.',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('register_name'),
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: Validators.name,
            ),
            AppSpacing.gapLg,
            TextFormField(
              key: const Key('register_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: Validators.email,
            ),
            AppSpacing.gapLg,
            PasswordField(
              key: const Key('register_password'),
              controller: _password,
              newPassword: true,
              validator: Validators.password,
            ),
            AppSpacing.gapLg,
            PasswordField(
              key: const Key('register_confirm'),
              controller: _confirm,
              label: 'Confirm password',
              newPassword: true,
              validator: (v) => Validators.confirmPassword(v, _password.text),
              onSubmitted: (_) => _submit(),
            ),
            AppSpacing.gapSm,
            Text(
              'At least 8 characters, with letters and numbers.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            AppSpacing.gapXl,
            PrimaryButton(
              key: const Key('register_submit'),
              label: 'Create account',
              loading: state.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
