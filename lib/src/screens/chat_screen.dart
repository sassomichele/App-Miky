
import 'package:flutter/material.dart';
import '../../src/db_helper.dart';
import '../../src/gesture_settings.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, Object?>> items = [];
  Map<String, GestureAction>? g;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    g = await GestureSettings.load();
    final raw = await DBHelper.instance.messages();
    final now = DateTime.now().millisecondsSinceEpoch;
    items = raw.where((m) {
      final s = (m['snoozeUntil'] as int?) ?? 0;
      return s == 0 || s <= now;
    }).toList();
    if (mounted) setState(() {});
  }

  Future<void> _apply(GestureAction a, String id) async {
    switch (a) {
      case GestureAction.delete:
        await DBHelper.instance.deleteMessage(id);
        break;
      case GestureAction.snooze:
        await DBHelper.instance.snoozeMessage(id, DateTime.now().add(const Duration(hours: 1)));
        break;
      case GestureAction.markUnread:
        await DBHelper.instance.markMessageUnread(id);
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
        final m = items[i];
        final id = m['id'] as String;
        final content = m['content'] as String;
        final isRead = (m['isRead'] as int) == 1;
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
              await _apply(g![GestureSettings.chatLeft]!, id);
            } else {
              await _apply(g![GestureSettings.chatRight]!, id);
            }
            return false;
          },
          child: ListTile(
            leading: const CircleAvatar(child: Text('C')),
            title: Text(isRead ? 'Contatto demo' : 'Contatto demo (nuovo)'),
            subtitle: Text(content),
            trailing: isRead ? null : const CircleAvatar(radius: 10, child: Text('1', style: TextStyle(fontSize: 12))),
            onLongPress: () => _apply(GestureAction.markUnread, id),
          ),
        );
      },
    );
  }
}
