import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/payment_method_tile.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/payment_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/primary_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  /// When true, tapping a method selects it for the current booking and pops.
  final bool selectable;
  const PaymentMethodsScreen({super.key, this.selectable = false});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadCards();
      context.read<SettingsProvider>().speak('Payment methods.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentProvider>();
    final ride = context.watch<RideProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment methods')),
      body: SafeArea(
        child: payment.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cash option
                  PaymentMethodTile(
                    cashLabel: 'Cash',
                    selected: widget.selectable && ride.paymentMethod == 'cash',
                    onTap: () {
                      if (widget.selectable) {
                        ride.setPaymentMethod('cash');
                        context.read<SettingsProvider>().speak('Cash selected.');
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  ...payment.cards.map((c) => PaymentMethodTile(
                        card: c,
                        selected: widget.selectable &&
                            ride.paymentMethod == 'card' &&
                            payment.defaultCard?.id == c.id,
                        onTap: () async {
                          if (widget.selectable) {
                            await payment.setDefault(c.id);
                            ride.setPaymentMethod('card');
                            if (!context.mounted) return;
                            context.read<SettingsProvider>().speak('Card ending ${c.last4} selected.');
                            Navigator.pop(context);
                          } else {
                            await payment.setDefault(c.id);
                          }
                        },
                        onDelete: widget.selectable ? null : () => payment.removeCard(c.id),
                      )),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Add new card',
                    icon: Icons.add_rounded,
                    outlined: true,
                    onPressed: () => Navigator.pushNamed(context, Routes.addCard),
                  ),
                ],
              ),
      ),
    );
  }
}
