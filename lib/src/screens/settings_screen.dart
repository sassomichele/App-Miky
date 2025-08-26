
import 'package:flutter/material.dart';
import '../../src/gesture_settings.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChange;
  const SettingsScreen({super.key, required this.onThemeChange});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, GestureAction>? g;
  ThemeMode _mode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    g = await GestureSettings.load();
    if (mounted) setState(() {});
  }

  DropdownButton<GestureAction> _dropdown(String key) {
    final val = g![key]!;
    return DropdownButton<GestureAction>(
      value: val,
      items: GestureAction.values.map((a) => DropdownMenuItem(value: a, child: Text(GestureSettings.label(a)))).toList(),
      onChanged: (v) async {
        if (v == null) return;
        await GestureSettings.save(key, v);
        await _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Aspetto', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('Chiaro'), icon: Icon(Icons.light_mode_outlined)),
            ButtonSegment(value: ThemeMode.dark, label: Text('Scuro'), icon: Icon(Icons.dark_mode_outlined)),
            ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.settings_suggest_outlined)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) {
            setState(() => _mode = s.first);
            widget.onThemeChange(_mode);
          },
        ),
        const SizedBox(height: 24),
        const Text('Swipe Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (g == null) const Center(child: CircularProgressIndicator()) else
          Column(children: [
            ListTile(title: const Text('Sinistra'), trailing: _dropdown(GestureSettings.chatLeft)),
            ListTile(title: const Text('Destra'), trailing: _dropdown(GestureSettings.chatRight)),
          ]),
        const SizedBox(height: 16),
        const Text('Swipe Mail', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (g == null) const Center(child: CircularProgressIndicator()) else
          Column(children: [
            ListTile(title: const Text('Sinistra'), trailing: _dropdown(GestureSettings.mailLeft)),
            ListTile(title: const Text('Destra'), trailing: _dropdown(GestureSettings.mailRight)),
          ]),
      ],
    );
  }
}
