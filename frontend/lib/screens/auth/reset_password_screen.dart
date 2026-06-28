import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context
        .read<SettingsProvider>()
        .speak('Enter the reset code and your new password. For the demo, the code is 1 2 3 4 5 6.'));
  }

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.resetPassword(widget.email, _code.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.passwordChanged);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('Resetting for ${widget.email}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                CustomTextField(
                    label: 'Reset Code',
                    controller: _code,
                    hint: '6-digit code',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_rounded,
                    validator: (v) => Validators.required(v, 'Code')),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'New Password',
                    controller: _password,
                    hint: '••••••••',
                    obscure: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: Validators.password),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Reset Password', loading: _loading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
