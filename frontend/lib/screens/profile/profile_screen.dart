import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SettingsProvider>().speak('Profile.'));
  }

  Future<void> _editProfile() async {
    final auth = context.read<AuthProvider>();
    final name = TextEditingController(text: auth.user?.name);
    final phone = TextEditingController(text: auth.user?.phone);
    final home = TextEditingController(text: auth.user?.homeAddress);
    final work = TextEditingController(text: auth.user?.workAddress);
    final emergency = TextEditingController(text: auth.user?.emergencyContact);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Name', controller: name),
            const SizedBox(height: 12),
            CustomTextField(label: 'Phone', controller: phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            CustomTextField(label: 'Home address', controller: home),
            const SizedBox(height: 12),
            CustomTextField(label: 'Work address', controller: work),
            const SizedBox(height: 12),
            CustomTextField(
                label: 'Emergency contact (for SOS)',
                controller: emergency,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Save',
              onPressed: () async {
                await auth.updateProfile({
                  'name': name.text.trim(),
                  'phone': phone.text.trim(),
                  'homeAddress': home.text.trim(),
                  'workAddress': work.text.trim(),
                  'emergencyContact': emergency.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Routes.signIn, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: !widget.embedded,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.accentSoft,
                  child: Text(
                    (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _tile(Icons.edit_rounded, 'Edit profile', _editProfile),
          _tile(Icons.account_balance_wallet_rounded, 'Wallet',
              () => Navigator.pushNamed(context, Routes.wallet)),
          _tile(Icons.credit_card_rounded, 'Payment methods',
              () => Navigator.pushNamed(context, Routes.paymentMethods)),
          _tile(Icons.receipt_long_rounded, 'My trips',
              () => Navigator.pushNamed(context, Routes.history)),
          _tile(Icons.settings_rounded, 'Settings',
              () => Navigator.pushNamed(context, Routes.settings)),
          const SizedBox(height: 16),
          _tile(Icons.logout_rounded, 'Log out', _logout, color: AppColors.danger),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap, {Color color = AppColors.primary}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
