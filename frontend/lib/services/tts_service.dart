import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech engine for the accessible Voice Navigation mode.
/// All speech requests no-op silently when [enabled] is false, so screens can
/// call [announce] unconditionally without checking state everywhere.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialised = false;
  bool enabled = false;
  double rate = 0.5;
  String? _last;

  Future<void> init({bool enabled = false, double rate = 0.5}) async {
    this.enabled = enabled;
    this.rate = rate;
    if (_initialised) {
      await _applySettings();
      return;
    }
    try {
      await _tts.setLanguage('en-US');
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _applySettings();
      _initialised = true;
    } catch (e) {
      debugPrint('[tts] init failed: $e');
    }
  }

  Future<void> _applySettings() async {
    try {
      await _tts.setSpeechRate(rate);
    } catch (_) {}
  }

  Future<void> setEnabled(bool value) async {
    enabled = value;
    if (!value) await stop();
  }

  Future<void> setRate(double value) async {
    rate = value;
    await _applySettings();
  }

  /// Speaks [message]. Pass [interrupt] to cut off any current utterance.
  /// Duplicate consecutive messages are suppressed to avoid spamming.
  Future<void> announce(String message, {bool interrupt = false, bool force = false}) async {
    if (!enabled || message.trim().isEmpty) return;
    if (!force && message == _last) return;
    _last = message;
    try {
      if (interrupt) await _tts.stop();
      await _tts.speak(message);
    } catch (e) {
      debugPrint('[tts] speak failed: $e');
    }
  }

  Future<void> stop() async {
    _last = null;
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
