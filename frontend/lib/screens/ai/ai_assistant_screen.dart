import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ai_models.dart';
import '../../models/place_model.dart';
import '../../providers/ride_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/ai_service.dart';
import '../../services/geocoding_service.dart';
import '../../services/tts_service.dart';

class _ChatMessage {
  final String text;
  final bool fromUser;
  final AssistantResult? result;
  _ChatMessage(this.text, this.fromUser, [this.result]);
}

/// AI ride assistant — natural-language (typed or spoken) booking + Q&A.
/// Backend uses OpenAI when an API key is configured, otherwise a rule-based
/// fallback. Replies are spoken aloud when Voice Navigation is on.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _ai = AiService();
  final _geo = GeocodingService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  final List<_ChatMessage> _messages = [];
  bool _sending = false;
  bool _listening = false;
  bool _speechAvailable = false;
  bool _aiEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _messages.add(_ChatMessage(
      "Hi! I'm your Rydo assistant. Try: \"Book a comfort ride to the airport\" "
      "or ask \"how much is a ride downtown?\"",
      false,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) => context
        .read<SettingsProvider>()
        .speak('AI assistant. Ask me to book a ride or estimate a fare.'));
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize();
      if (mounted) setState(() {});
    } catch (_) {
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice input is not available on this device.')),
      );
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (r) {
        setState(() => _controller.text = r.recognizedWords);
        if (r.finalResult) {
          setState(() => _listening = false);
          if (_controller.text.trim().isNotEmpty) _send();
        }
      },
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _controller.clear();
      _sending = true;
    });
    _scrollToEnd();

    try {
      final res = await _ai.assistant(text);
      _aiEnabled = res.aiEnabled;
      setState(() => _messages.add(_ChatMessage(res.result.reply, false, res.result)));
      if (!mounted) return;
      context.read<SettingsProvider>().speak(res.result.reply, interrupt: true);
      // Also speak via TTS even if voice nav off? Keep tied to setting for consistency.
    } catch (e) {
      setState(() => _messages.add(_ChatMessage('Sorry, I had trouble: $e', false)));
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _proceedToBooking(AssistantResult r) async {
    final ride = context.read<RideProvider>();
    final settings = context.read<SettingsProvider>();
    settings.speak('Finding ${r.dropoff}.');

    final matches = await _geo.search(r.dropoff!);
    if (!mounted || matches.isEmpty) return;
    final dest = matches.first;
    final origin = ride.currentLatLng;
    ride.setPickup(Place(
      address: 'Current location',
      lat: origin?.latitude ?? dest.lat,
      lng: origin?.longitude ?? dest.lng,
    ));
    ride.setDropoff(dest);
    if (r.rideType != null) ride.setRideType(r.rideType!);
    if (!mounted) return;
    Navigator.pushNamed(context, Routes.chooseRide);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (_aiEnabled ? AppColors.success : AppColors.textMuted).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _aiEnabled ? 'GPT' : 'Smart',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _aiEnabled ? AppColors.success : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Assistant is thinking…', style: TextStyle(color: AppColors.textMuted)),
            ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(_ChatMessage m) {
    final align = m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = m.fromUser ? AppColors.accent : Theme.of(context).cardColor;
    final textColor = m.fromUser ? Colors.white : AppColors.textPrimary;
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: m.fromUser ? null : Border.all(color: AppColors.border),
          ),
          child: Text(m.text, style: TextStyle(color: textColor, height: 1.35)),
        ),
        if (m.result?.isBooking ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ElevatedButton.icon(
              onPressed: () => _proceedToBooking(m.result!),
              icon: const Icon(Icons.local_taxi_rounded, size: 18),
              label: Text('Book ${m.result!.rideType ?? 'ride'} to ${m.result!.dropoff}'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, minimumSize: const Size(10, 44)),
            ),
          ),
      ],
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _toggleMic,
              tooltip: 'Speak',
              icon: Icon(_listening ? Icons.mic : Icons.mic_none_rounded,
                  color: _listening ? AppColors.danger : AppColors.accent),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Ask me to book a ride…',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
