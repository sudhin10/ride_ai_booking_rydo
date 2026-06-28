import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../providers/payment_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SettingsProvider>().speak('Add a new card. Sandbox mode, no real charges.'));
  }

  @override
  void dispose() {
    for (final c in [_holder, _number, _expiry, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final parts = _expiry.text.split('/');
    final month = int.tryParse(parts[0]) ?? 1;
    final year = parts.length > 1 ? 2000 + (int.tryParse(parts[1]) ?? 30) : 2030;

    setState(() => _loading = true);
    final ok = await context.read<PaymentProvider>().addCard(
          holderName: _holder.text.trim(),
          number: _number.text,
          expMonth: month,
          expYear: year,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.read<SettingsProvider>().speak('Card added successfully.');
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add card'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add card')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _cardPreview(),
                const SizedBox(height: 24),
                CustomTextField(
                    label: 'Cardholder name',
                    controller: _holder,
                    hint: 'John Doe',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => Validators.required(v, 'Name')),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Card number',
                  controller: _number,
                  hint: '4242 4242 4242 4242',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.credit_card_rounded,
                  validator: Validators.cardNumber,
                  onChanged: (v) {
                    final formatted = Formatters.cardNumberInput(v);
                    if (formatted != v) {
                      _number.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Expiry',
                      controller: _expiry,
                      hint: 'MM/YY',
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(5)],
                      validator: (v) =>
                          (v == null || !v.contains('/')) ? 'MM/YY' : null,
                      onChanged: (v) {
                        if (v.length == 2 && !v.contains('/')) {
                          _expiry.text = '$v/';
                          _expiry.selection =
                              TextSelection.collapsed(offset: _expiry.text.length);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'CVV',
                      controller: _cvv,
                      hint: '123',
                      obscure: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(4)],
                      validator: (v) => (v == null || v.length < 3) ? 'CVV' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Save card', loading: _loading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardPreview() {
    final number = _number.text.isEmpty ? '•••• •••• •••• ••••' : _number.text;
    return Container(
      height: 190,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.contactless_rounded, color: Colors.white70),
              Text('Rydo',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2)),
            ],
          ),
          const Spacer(),
          Text(number,
              style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_holder.text.isEmpty ? 'CARDHOLDER' : _holder.text.toUpperCase(),
                  style: const TextStyle(color: Colors.white70)),
              Text(_expiry.text.isEmpty ? 'MM/YY' : _expiry.text,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
