import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SettingsProvider>().speak('Create account screen.'));
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok =
        await auth.register(_name.text.trim(), _email.text.trim(), _password.text, _phone.text.trim());
    if (!mounted) return;
    if (ok) {
      context.read<SettingsProvider>().speak('Account created. Welcome to Rydo.');
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Sign up failed'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create Account',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Sign up to start booking rides.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                CustomTextField(
                    label: 'Full Name',
                    controller: _name,
                    hint: 'John Doe',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => Validators.required(v, 'Name')),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Email',
                    controller: _email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    validator: Validators.email),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Phone',
                    controller: _phone,
                    hint: '+1 555 000 0000',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Password',
                    controller: _password,
                    hint: '••••••••',
                    obscure: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: Validators.password),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Confirm Password',
                    controller: _confirm,
                    hint: '••••••••',
                    obscure: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: (v) => v != _password.text ? 'Passwords do not match' : null),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Sign Up', loading: auth.loading, onPressed: _submit),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Sign In',
                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
