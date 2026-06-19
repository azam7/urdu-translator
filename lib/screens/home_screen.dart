import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/translation_service.dart';
import '../widgets/mic_button.dart';
import '../widgets/translation_card.dart';
import '../widgets/status_bar.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TranslationService _service = TranslationService();

  String _urduText = '';
  String _englishText = '';
  String _partialUrdu = '';
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isSpeaking = false;
  bool _initialized = false;
  bool _autoSpeak = true;
  String _statusMessage = 'Tap mic to start';

  final List<Map<String, String>> _history = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _requestPermissions();
    final ok = await _service.initialize();
    await _loadPreferences();
    setState(() {
      _initialized = ok;
      _statusMessage = ok ? 'Ready — tap mic to speak' : 'Mic not available';
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSpeak = prefs.getBool('auto_speak') ?? true;
    });
  }

  // ===== START / STOP LISTENING =====
  Future<void> _toggleListening() async {
    if (!_initialized) return;

    if (_isListening) {
      await _service.stopListening();
      setState(() {
        _isListening = false;
        _statusMessage = 'Processing...';
      });
    } else {
      setState(() {
        _isListening = true;
        _urduText = '';
        _englishText = '';
        _partialUrdu = '';
        _statusMessage = 'Listening... Speak in Urdu';
      });

      await _service.startListening(
        onPartialResult: (text) {
          setState(() => _partialUrdu = text);
        },
        onResult: (text) async {
          setState(() {
            _urduText = text;
            _partialUrdu = '';
            _isListening = false;
            _isTranslating = true;
            _statusMessage = 'Translating...';
          });

          await _translateAndSpeak(text);
        },
      );
    }
  }

  Future<void> _translateAndSpeak(String urduText) async {
    final english = await _service.translateToEnglish(urduText);

    setState(() {
      _englishText = english;
      _isTranslating = false;
      _statusMessage = 'Done — tap mic for more';
    });

    // Save to history
    if (urduText.isNotEmpty && english.isNotEmpty) {
      setState(() {
        _history.insert(0, {'urdu': urduText, 'english': english});
        if (_history.length > 20) _history.removeLast();
      });
    }

    // Auto speak
    if (_autoSpeak && english.isNotEmpty) {
      setState(() => _isSpeaking = true);
      await _service.speakEnglish(english);
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _speakAgain() async {
    if (_englishText.isEmpty || _isSpeaking) return;
    setState(() => _isSpeaking = true);
    await _service.speakEnglish(_englishText);
    setState(() => _isSpeaking = false);
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _urduText = '';
      _englishText = '';
      _partialUrdu = '';
      _statusMessage = 'Cleared — tap mic to start';
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(service: _service),
      ),
    ).then((_) => _loadPreferences());
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text('No history yet'))
                  : ListView.builder(
                      controller: controller,
                      itemCount: _history.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(
                          _history[i]['english'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _history[i]['urdu'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'NotoNastaliqUrdu',
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _urduText = _history[i]['urdu'] ?? '';
                            _englishText = _history[i]['english'] ?? '';
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'اردو → English',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: _showHistory,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          StatusBar(
            message: _statusMessage,
            isListening: _isListening,
            isTranslating: _isTranslating,
            isSpeaking: _isSpeaking,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // URDU INPUT CARD
                  TranslationCard(
                    label: 'Urdu (heard)',
                    labelIcon: Icons.mic_none,
                    text: _isListening && _partialUrdu.isNotEmpty
                        ? _partialUrdu
                        : _urduText,
                    isPartial: _isListening,
                    placeholder: 'Urdu speech will appear here...',
                    textAlign: TextAlign.right,
                    onCopy: () => _copyToClipboard(_urduText),
                    accentColor: colorScheme.primary,
                  ),

                  const SizedBox(height: 12),

                  // ARROW
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isTranslating)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_downward,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isTranslating ? 'Translating...' : 'Translation',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ENGLISH OUTPUT CARD
                  TranslationCard(
                    label: 'English (output)',
                    labelIcon: Icons.volume_up,
                    text: _englishText,
                    placeholder: 'English translation will appear here...',
                    onCopy: () => _copyToClipboard(_englishText),
                    accentColor: colorScheme.secondary,
                    showSpeakButton: _englishText.isNotEmpty,
                    isSpeaking: _isSpeaking,
                    onSpeak: _speakAgain,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // BOTTOM CONTROLS
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Clear button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.outlined(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.clear_all),
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(52, 52),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                // BIG MIC BUTTON
                MicButton(
                  isListening: _isListening,
                  isEnabled: _initialized,
                  pulseController: _pulseController,
                  onPressed: _toggleListening,
                ),

                // Auto-speak toggle
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.outlined(
                      onPressed: () async {
                        setState(() => _autoSpeak = !_autoSpeak);
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('auto_speak', _autoSpeak);
                      },
                      icon: Icon(
                        _autoSpeak ? Icons.volume_up : Icons.volume_off,
                        color: _autoSpeak ? colorScheme.primary : null,
                      ),
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(52, 52),
                        backgroundColor: _autoSpeak
                            ? colorScheme.primaryContainer
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _autoSpeak ? 'Auto ON' : 'Auto OFF',
                      style: TextStyle(
                        fontSize: 11,
                        color: _autoSpeak
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
