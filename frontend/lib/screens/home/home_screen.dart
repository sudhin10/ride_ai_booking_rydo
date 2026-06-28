import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';
import '../history/history_screen.dart';
import '../payment/wallet_screen.dart';
import '../profile/profile_screen.dart';
import 'dashboard_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _tabs = const [
    DashboardTab(),
    HistoryScreen(embedded: true),
    WalletScreen(embedded: true),
    ProfileScreen(embedded: true),
  ];

  final _labels = const ['Home', 'Trips', 'Wallet', 'Profile'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().initLocation();
    });
  }

  void _onTap(int i) {
    setState(() => _index = i);
    context.read<SettingsProvider>().speak('${_labels[i]} tab');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        selectedItemColor: AppColors.accent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
