
import 'package:flutter/material.dart';
import '../../src/db_helper.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, Object?>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    items = await DBHelper.instance.contacts();
    if (mounted) setState(() {});
  }

  Future<void> _addContact() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuovo contatto'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 8),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salva')),
        ],
      ),
    );
    if (ok == true) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await DBHelper.instance.insertContact({'id': id, 'name': nameCtrl.text, 'email': emailCtrl.text, 'phone': '', 'avatar': ''});
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final c = items[i];
          final name = c['name'] as String? ?? '';
          final email = c['email'] as String? ?? '';
          return ListTile(
            leading: CircleAvatar(child: Text(name.isNotEmpty ? name.characters.first : '?')),
            title: Text(name),
            subtitle: Text(email),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContact,
        label: const Text('Nuovo'),
        icon: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
