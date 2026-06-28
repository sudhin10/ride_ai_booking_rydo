import 'package:flutter/material.dart';
import '../../screens/onboarding/splash_screen.dart';
import '../../screens/onboarding/voice_prompt_screen.dart';
import '../../screens/auth/sign_in_screen.dart';
import '../../screens/auth/sign_up_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/auth/password_changed_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/booking/select_destination_screen.dart';
import '../../screens/booking/choose_ride_screen.dart';
import '../../screens/booking/tracking_screen.dart';
import '../../screens/booking/ride_complete_screen.dart';
import '../../screens/payment/payment_methods_screen.dart';
import '../../screens/payment/add_card_screen.dart';
import '../../screens/payment/payment_done_screen.dart';
import '../../screens/payment/wallet_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/ai/ai_assistant_screen.dart';

class Routes {
  static const splash = '/';
  static const voicePrompt = '/voice-prompt';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const passwordChanged = '/password-changed';
  static const home = '/home';
  static const selectDestination = '/select-destination';
  static const chooseRide = '/choose-ride';
  static const tracking = '/tracking';
  static const rideComplete = '/ride-complete';
  static const paymentMethods = '/payment-methods';
  static const addCard = '/add-card';
  static const paymentDone = '/payment-done';
  static const wallet = '/wallet';
  static const profile = '/profile';
  static const history = '/history';
  static const settings = '/settings';
  static const aiAssistant = '/ai-assistant';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case Routes.splash:
        page = const SplashScreen();
        break;
      case Routes.voicePrompt:
        page = const VoicePromptScreen();
        break;
      case Routes.signIn:
        page = const SignInScreen();
        break;
      case Routes.signUp:
        page = const SignUpScreen();
        break;
      case Routes.forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case Routes.resetPassword:
        page = ResetPasswordScreen(email: settings.arguments as String? ?? '');
        break;
      case Routes.passwordChanged:
        page = const PasswordChangedScreen();
        break;
      case Routes.home:
        page = const HomeScreen();
        break;
      case Routes.selectDestination:
        page = const SelectDestinationScreen();
        break;
      case Routes.chooseRide:
        page = const ChooseRideScreen();
        break;
      case Routes.tracking:
        page = const TrackingScreen();
        break;
      case Routes.rideComplete:
        page = const RideCompleteScreen();
        break;
      case Routes.paymentMethods:
        page = PaymentMethodsScreen(selectable: settings.arguments == 'select');
        break;
      case Routes.addCard:
        page = const AddCardScreen();
        break;
      case Routes.paymentDone:
        page = const PaymentDoneScreen();
        break;
      case Routes.wallet:
        page = const WalletScreen();
        break;
      case Routes.profile:
        page = const ProfileScreen();
        break;
      case Routes.history:
        page = const HistoryScreen();
        break;
      case Routes.settings:
        page = const SettingsScreen();
        break;
      case Routes.aiAssistant:
        page = const AiAssistantScreen();
        break;
      default:
        page = const SplashScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
