import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> configureVoice({
    required String voicePreset,
    required double speed,
  }) async {
    await _tts.setSpeechRate(speed);

    // Map UI presets to common engines settings.
    switch (voicePreset) {
      case 'Clear':
        await _tts.setPitch(1.1);
        break;
      case 'Slow':
        await _tts.setPitch(0.95);
        break;
      case 'Natural':
      default:
        await _tts.setPitch(1.0);
        break;
    }
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
