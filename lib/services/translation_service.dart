import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TranslationService {
  final SpeechToText _speech = SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _tts = FlutterTts();

  bool _speechAvailable = false;
  bool _isListening = false;
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;

  bool get isListening => _isListening;
  bool get speechAvailable => _speechAvailable;

  // ===== INITIALIZE =====
  Future<bool> initialize() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
    await _tts.awaitSpeakCompletion(true);

    return _speechAvailable;
  }

  // ===== START LISTENING =====
  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String text) onPartialResult,
  }) async {
    if (!_speechAvailable || _isListening) return;

    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        } else {
          onPartialResult(result.recognizedWords);
        }
      },
      localeId: 'ur-PK',        // Urdu Pakistan
      listenMode: ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  // ===== STOP LISTENING =====
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  // ===== TRANSLATE URDU TO ENGLISH =====
  Future<String> translateToEnglish(String urduText) async {
    if (urduText.trim().isEmpty) return '';
    try {
      final translation = await _translator.translate(
        urduText,
        from: 'ur',
        to: 'en',
      );
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return 'Translation failed. Please try again.';
    }
  }

  // ===== SPEAK ENGLISH TEXT =====
  Future<void> speakEnglish(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  // ===== STOP SPEAKING =====
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // ===== UPDATE TTS SETTINGS =====
  Future<void> updateTtsSettings({
    double? rate,
    double? volume,
    double? pitch,
  }) async {
    if (rate != null) {
      _speechRate = rate;
      await _tts.setSpeechRate(rate);
    }
    if (volume != null) {
      _volume = volume;
      await _tts.setVolume(volume);
    }
    if (pitch != null) {
      _pitch = pitch;
      await _tts.setPitch(pitch);
    }
  }

  // ===== GET AVAILABLE LOCALES =====
  Future<List<dynamic>> getAvailableLanguages() async {
    return await _tts.getLanguages;
  }

  // ===== DISPOSE =====
  Future<void> dispose() async {
    await _speech.stop();
    await _tts.stop();
  }

  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
}
