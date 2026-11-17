import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/data/fakes/fake_auth_repository.dart';
import '../auth_providers.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await ref.read(authFormControllerProvider.notifier).run(
          (repo) => repo.signIn(
            email: _email.text.trim(),
            password: _password.text,
          ),
        );
    if (ok && mounted) context.go(Routes.home);
  }

  void _useSample() {
    _email.text = FakeAuthRepository.sampleEmail;
    _password.text = FakeAuthRepository.samplePassword;
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
      title: 'Welcome back',
      subtitle: 'Sign in to continue building your career.',
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('login_email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: Validators.email,
              ),
              AppSpacing.gapLg,
              PasswordField(
                key: const Key('login_password'),
                controller: _password,
                onSubmitted: (_) => _submit(),
                validator: (v) => Validators.required(v, field: 'Password'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(Routes.resetPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              AppSpacing.gapSm,
              PrimaryButton(
                key: const Key('login_submit'),
                label: 'Sign in',
                loading: state.isLoading,
                onPressed: _submit,
              ),
              AppSpacing.gapLg,
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('New to ResumeCraft?'),
                  TextButton(
                    key: const Key('go_register'),
                    onPressed: () => context.push(Routes.register),
                    child: const Text('Create an account'),
                  ),
                ],
              ),
              if (AppConfig.useFakes) ...[
                AppSpacing.gapLg,
                AppCard(
                  onTap: _useSample,
                  child: const Row(
                    children: [
                      Icon(Icons.person_outline_rounded),
                      AppSpacing.gapMd,
                      Expanded(
                        child: Text('Fill in the sample account for a demo'),
                      ),
                      SampleBadge(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
