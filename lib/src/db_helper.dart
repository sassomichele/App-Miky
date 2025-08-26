
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();
  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final p = join(dir.path, 'aio_v5_start_over.db');
    _db = await openDatabase(p, version: 1, onCreate: (d, v) async {
      await d.execute('CREATE TABLE messages(id TEXT PRIMARY KEY, content TEXT, isRead INTEGER, snoozeUntil INTEGER)');
      await d.execute('CREATE TABLE emails(id TEXT PRIMARY KEY, subject TEXT, isRead INTEGER, snoozeUntil INTEGER)');
      await d.execute('CREATE TABLE contacts(id TEXT PRIMARY KEY, name TEXT, email TEXT, phone TEXT, avatar TEXT)');
      await d.execute('CREATE TABLE events(id TEXT PRIMARY KEY, title TEXT, start INTEGER, end INTEGER, category TEXT, sourceContactId TEXT, attendees TEXT, rsvp TEXT)');
    });
    await _seed();
  }

  Future<void> _seed() async {
    final m = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM messages')) ?? 0;
    if (m == 0) {
      await db.insert('messages', {'id': 'm1', 'content': 'Domani alle 10', 'isRead': 0, 'snoozeUntil': 0});
      await db.insert('messages', {'id': 'm2', 'content': 'Ok, ci vediamo', 'isRead': 1, 'snoozeUntil': 0});
    }
    final e = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM emails')) ?? 0;
    if (e == 0) {
      await db.insert('emails', {'id': 'e1', 'subject': 'Riunione progetto', 'isRead': 0, 'snoozeUntil': 0});
      await db.insert('emails', {'id': 'e2', 'subject': 'Contratto allegato', 'isRead': 1, 'snoozeUntil': 0});
    }
    final c = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM contacts')) ?? 0;
    if (c == 0) {
      await db.insert('contacts', {'id': 'c1', 'name': 'Mario Rossi', 'email': 'mario@example.com', 'phone': '', 'avatar': ''});
      await db.insert('contacts', {'id': 'c2', 'name': 'Lucia Bianchi', 'email': 'lucia@example.com', 'phone': '', 'avatar': ''});
    }
    final ev = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM events')) ?? 0;
    if (ev == 0) {
      final now = DateTime.now();
      await db.insert('events', {
        'id': 'ev1',
        'title': 'Call Progetto',
        'start': now.add(const Duration(hours: 2)).millisecondsSinceEpoch,
        'end': now.add(const Duration(hours: 3)).millisecondsSinceEpoch,
        'category': 'Lavoro',
        'sourceContactId': 'c1',
        'attendees': 'me,c1',
        'rsvp': 'tentative',
      });
    }
  }

  Future<List<Map<String, Object?>>> messages() async => await db.query('messages', orderBy: 'rowid DESC');
  Future<void> deleteMessage(String id) async => await db.delete('messages', where: 'id=?', whereArgs: [id]);
  Future<void> markMessageUnread(String id) async => await db.update('messages', {'isRead': 0}, where: 'id=?', whereArgs: [id]);
  Future<void> snoozeMessage(String id, DateTime until) async => await db.update('messages', {'snoozeUntil': until.millisecondsSinceEpoch}, where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, Object?>>> emails() async => await db.query('emails', orderBy: 'rowid DESC');
  Future<void> deleteEmail(String id) async => await db.delete('emails', where: 'id=?', whereArgs: [id]);
  Future<void> markEmailUnread(String id) async => await db.update('emails', {'isRead': 0}, where: 'id=?', whereArgs: [id]);
  Future<void> snoozeEmail(String id, DateTime until) async => await db.update('emails', {'snoozeUntil': until.millisecondsSinceEpoch}, where: 'id=?', whereArgs: [id]);

  Future<List<Map<String, Object?>>> contacts() async => await db.query('contacts', orderBy: 'name ASC');
  Future<void> insertContact(Map<String, Object?> data) async => await db.insert('contacts', data, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<Map<String, Object?>>> events() async => await db.query('events', orderBy: 'start ASC');
  Future<void> insertEvent(Map<String, Object?> data) async => await db.insert('events', data, conflictAlgorithm: ConflictAlgorithm.replace);
  Future<void> deleteEvents(Set<String> ids) async {
    final b = db.batch();
    for (final id in ids) {
      b.delete('events', where: 'id=?', whereArgs: [id]);
    }
    await b.commit(noResult: true);
  }
  Future<void> moveEvents(Set<String> ids, Duration delta) async {
    final rows = await events();
    final ms = delta.inMilliseconds;
    final b = db.batch();
    for (final r in rows) {
      if (ids.contains(r['id'])) {
        final start = (r['start'] as int) + ms;
        final end = (r['end'] as int) + ms;
        b.update('events', {'start': start, 'end': end}, where: 'id=?', whereArgs: [r['id']]);
      }
    }
    await b.commit(noResult: true);
  }
  Future<void> updateRsvp(String id, String rsvp) async => await db.update('events', {'rsvp': rsvp}, where: 'id=?', whereArgs: [id]);
}
