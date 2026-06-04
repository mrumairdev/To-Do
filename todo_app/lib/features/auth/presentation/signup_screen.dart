import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_info_banner.dart';
import 'widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    auth.clearError();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await auth.signUp(
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Color _strengthColor(BuildContext context, PasswordStrength strength) {
    final scheme = Theme.of(context).colorScheme;
    return switch (strength.colorHint) {
      ColorHint.error => scheme.error,
      ColorHint.warning => scheme.tertiary,
      ColorHint.success => scheme.primary,
      ColorHint.neutral => scheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);
    final strength = Validators.passwordStrength(_passwordController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full name',
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.fullName,
                      onChanged: (_) => auth.clearError(),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                      onChanged: (_) => auth.clearError(),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      enableObscureToggle: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                      onChanged: (_) => setState(() => auth.clearError()),
                    ),
                    if (strength != PasswordStrength.empty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: switch (strength) {
                                PasswordStrength.weak => 0.33,
                                PasswordStrength.good => 0.66,
                                PasswordStrength.strong => 1,
                                PasswordStrength.empty => 0,
                              },
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              color: _strengthColor(context, strength),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            strength.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: _strengthColor(context, strength),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      obscureText: true,
                      enableObscureToggle: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      onChanged: (_) => auth.clearError(),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      AuthErrorBanner(message: auth.errorMessage!),
                    ],
                    if (auth.infoMessage != null) ...[
                      const SizedBox(height: 12),
                      AuthInfoBanner(message: auth.infoMessage!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
