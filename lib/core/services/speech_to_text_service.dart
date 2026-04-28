import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechToTextService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize({
    required void Function(String status) onStatus,
    required void Function(String message) onError,
  }) async {
    if (_initialized) return true;

    _initialized = await _speech.initialize(
      onStatus: onStatus,
      onError: (error) => onError(error.errorMsg),
      debugLogging: true,
    );
    return _initialized;
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening({
    required void Function(SpeechRecognitionResult result) onResult,
  }) async {
    if (!_initialized) return;
    await _speech.listen(
      onResult: onResult,
      localeId: 'en_US',
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }
}
