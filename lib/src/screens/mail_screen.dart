
import 'package:flutter/material.dart';
import '../../src/db_helper.dart';
import '../../src/gesture_settings.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});
  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  List<Map<String, Object?>> items = [];
  Map<String, GestureAction>? g;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    g = await GestureSettings.load();
    final raw = await DBHelper.instance.emails();
    final now = DateTime.now().millisecondsSinceEpoch;
    items = raw.where((e) {
      final s = (e['snoozeUntil'] as int?) ?? 0;
      return s == 0 || s <= now;
    }).toList();
    if (mounted) setState(() {});
  }

  Future<void> _apply(GestureAction a, String id) async {
    switch (a) {
      case GestureAction.delete:
        await DBHelper.instance.deleteEmail(id);
        break;
      case GestureAction.snooze:
        await DBHelper.instance.snoozeEmail(id, DateTime.now().add(const Duration(hours: 1)));
        break;
      case GestureAction.markUnread:
        await DBHelper.instance.markEmailUnread(id);
        break;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (g == null) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final e = items[i];
        final id = e['id'] as String;
        final subj = e['subject'] as String;
        final isRead = (e['isRead'] as int) == 1;
        return Dismissible(
          key: ValueKey(id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.orange,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.snooze, color: Colors.white),
          ),
          confirmDismiss: (d) async {
            if (d == DismissDirection.startToEnd) {
              await _apply(g![GestureSettings.mailLeft]!, id);
            } else {
              await _apply(g![GestureSettings.mailRight]!, id);
            }
            return false;
          },
          child: ListTile(
            leading: const CircleAvatar(child: Text('C')),
            title: Text(subj, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
            subtitle: const Text('Mittente demo'),
            onLongPress: () => _apply(GestureAction.markUnread, id),
          ),
        );
      },
    );
  }
}
