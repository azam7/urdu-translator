import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/translation_service.dart';

class SettingsScreen extends StatefulWidget {
  final TranslationService service;
  const SettingsScreen({super.key, required this.service});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  bool _autoSpeak = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
      _volume = prefs.getDouble('volume') ?? 1.0;
      _pitch = prefs.getDouble('pitch') ?? 1.0;
      _autoSpeak = prefs.getBool('auto_speak') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speech_rate', _speechRate);
    await prefs.setDouble('volume', _volume);
    await prefs.setDouble('pitch', _pitch);
    await prefs.setBool('auto_speak', _autoSpeak);

    await widget.service.updateTtsSettings(
      rate: _speechRate,
      volume: _volume,
      pitch: _pitch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== VOICE SETTINGS =====
          _SectionHeader(title: 'Voice Output', icon: Icons.volume_up),
          const SizedBox(height: 12),

          _SettingCard(
            children: [
              _SliderTile(
                label: 'Speech Speed',
                icon: Icons.speed,
                value: _speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                displayValue: _speechRate < 0.3
                    ? 'Slow'
                    : _speechRate < 0.7
                        ? 'Normal'
                        : 'Fast',
                onChanged: (v) {
                  setState(() => _speechRate = v);
                  _saveSettings();
                },
              ),
              const Divider(height: 1),
              _SliderTile(
                label: 'Volume',
                icon: Icons.volume_up_outlined,
                value: _volume,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                displayValue: '${(_volume * 100).round()}%',
                onChanged: (v) {
                  setState(() => _volume = v);
                  _saveSettings();
                },
              ),
              const Divider(height: 1),
              _SliderTile(
                label: 'Pitch',
                icon: Icons.music_note_outlined,
                value: _pitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                displayValue: _pitch < 0.9
                    ? 'Low'
                    : _pitch > 1.1
                        ? 'High'
                        : 'Normal',
                onChanged: (v) {
                  setState(() => _pitch = v);
                  _saveSettings();
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Test voice button
          FilledButton.tonal(
            onPressed: () => widget.service.speakEnglish(
              'Hello! The translator is working correctly.',
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline),
                SizedBox(width: 8),
                Text('Test Voice'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== BEHAVIOR =====
          _SectionHeader(title: 'Behavior', icon: Icons.tune),
          const SizedBox(height: 12),

          _SettingCard(
            children: [
              SwitchListTile(
                title: const Text('Auto Speak'),
                subtitle: const Text(
                  'Automatically speak English translation after detecting Urdu',
                ),
                value: _autoSpeak,
                onChanged: (v) {
                  setState(() => _autoSpeak = v);
                  _saveSettings();
                },
                secondary: const Icon(Icons.auto_mode),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ===== INFO =====
          _SectionHeader(title: 'About', icon: Icons.info_outline),
          const SizedBox(height: 12),

          _SettingCard(
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Translation Engine'),
                trailing: const Text('Google Translate',
                    style: TextStyle(color: Colors.grey)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Speech Recognition'),
                trailing: const Text('Google STT',
                    style: TextStyle(color: Colors.grey)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Source Language'),
                trailing: const Text('Urdu (ur-PK)',
                    style: TextStyle(color: Colors.grey)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Target Language'),
                trailing: const Text('English (en-US)',
                    style: TextStyle(color: Colors.grey)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: const Text('Audio Output'),
                trailing: const Text('Bluetooth / Speaker',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 15)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
