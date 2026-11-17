import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/state_views.dart';
import '../auth_providers.dart';
import '../widgets/auth_scaffold.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await ref
        .read(authFormControllerProvider.notifier)
        .run((repo) => repo.sendPasswordReset(_email.text.trim()));
    if (ok && mounted) setState(() => _sent = true);
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
      title: 'Reset password',
      subtitle: 'We will email you a link to choose a new password.',
      child: _sent
          ? EmptyView(
              icon: Icons.mark_email_read_outlined,
              title: 'Check your inbox',
              message:
                  'If an account exists for ${_email.text.trim()}, a reset link is on its way.',
              action: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Back to sign in'),
              ),
            )
          : Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: Validators.email,
                  ),
                  AppSpacing.gapXl,
                  PrimaryButton(
                    label: 'Send reset link',
                    loading: state.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}
