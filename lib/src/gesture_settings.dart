
import 'package:shared_preferences/shared_preferences.dart';

enum GestureAction { delete, snooze, markUnread }

class GestureSettings {
  static const chatLeft = 'chat_left';
  static const chatRight = 'chat_right';
  static const mailLeft = 'mail_left';
  static const mailRight = 'mail_right';

  static String label(GestureAction a) {
    switch (a) {
      case GestureAction.delete: return 'Elimina';
      case GestureAction.snooze: return 'Posticipa';
      case GestureAction.markUnread: return 'Segna non letto';
    }
  }

  static Future<Map<String, GestureAction>> load() async {
    final sp = await SharedPreferences.getInstance();
    GestureAction g(String k, GestureAction d) => GestureAction.values[sp.getInt(k) ?? d.index];
    return {
      chatLeft: g(chatLeft, GestureAction.delete),
      chatRight: g(chatRight, GestureAction.snooze),
      mailLeft: g(mailLeft, GestureAction.delete),
      mailRight: g(mailRight, GestureAction.snooze),
    };
  }

  static Future<void> save(String key, GestureAction a) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(key, a.index);
  }
}
