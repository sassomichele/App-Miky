
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../src/db_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Map<String, Object?>> events = [];
  final selected = <String>{};
  final df = DateFormat('EEE dd MMM HH:mm');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    events = await DBHelper.instance.events();
    if (mounted) setState(() {});
  }

  Future<void> _addQuick() async {
    final now = DateTime.now();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await DBHelper.instance.insertEvent({
      'id': id,
      'title': 'Nuovo evento',
      'start': now.millisecondsSinceEpoch,
      'end': now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
      'category': 'Generale',
      'sourceContactId': null,
      'attendees': 'me',
      'rsvp': 'tentative',
    });
    await _load();
  }

  Future<void> _deleteSel() async {
    await DBHelper.instance.deleteEvents(selected);
    selected.clear();
    await _load();
  }

  Future<void> _moveSel(Duration d) async {
    await DBHelper.instance.moveEvents(selected, d);
    await _load();
  }

  Future<void> _setRsvp(String id, String r) async {
    await DBHelper.instance.updateRsvp(id, r);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: _addQuick, icon: const Icon(Icons.add), label: const Text('Nuovo')),
          const SizedBox(width: 8),
          if (selected.isNotEmpty) ...[
            FilledButton.icon(onPressed: ()=> _moveSel(const Duration(days: 1)), icon: const Icon(Icons.arrow_forward), label: const Text('+1 g')),
            const SizedBox(width: 8),
            FilledButton.icon(onPressed: ()=> _moveSel(const Duration(days: -1)), icon: const Icon(Icons.arrow_back), label: const Text('-1 g')),
            const SizedBox(width: 8),
            FilledButton.icon(onPressed: _deleteSel, icon: const Icon(Icons.delete_outline), label: const Text('Elimina')),
          ]
        ]),
        const Divider(),
        Expanded(child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (_, i) {
            final e = events[i];
            final id = e['id'] as String;
            final title = e['title'] as String? ?? '';
            final start = DateTime.fromMillisecondsSinceEpoch(e['start'] as int);
            final end = DateTime.fromMillisecondsSinceEpoch(e['end'] as int);
            final cat = e['category'] as String? ?? '—';
            final sel = selected.contains(id);
            return ListTile(
              selected: sel,
              onLongPress: () => setState(() { sel ? selected.remove(id) : selected.add(id); }),
              leading: Icon(sel ? Icons.check_circle : Icons.event_available_outlined),
              title: Text(title),
              subtitle: Text('${df.format(start)} → ${df.format(end)} · $cat'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) => _setRsvp(id, v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'accepted', child: Text('Accetta')),
                  PopupMenuItem(value: 'tentative', child: Text('Forse')),
                  PopupMenuItem(value: 'declined', child: Text('Rifiuta')),
                  PopupMenuItem(value: 'proposed', child: Text('Proponi data')),
                ],
              ),
            );
          },
        )),
      ],
    );
  }
}
