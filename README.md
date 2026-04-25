# SignBridge

SignBridge is a Flutter app for sign and speech translation workflows.

## Speech Modules (Ready to use)

- **Speech to Text** uses `speech_to_text` for live on-device transcription.
- **Text to Speech** uses `flutter_tts` for real voice synthesis.

### Setup

1. Install dependencies:
   - `flutter pub get`
2. Run the app:
   - `flutter run`
3. On first microphone use, allow device/browser microphone permission.

## Notes

- Current defaults use English (`en_US` / `en-US`).
- For cloud-grade voices and transcription (Google Cloud, Azure, etc.), keep this UI and swap service implementations under `lib/core/services/`.
