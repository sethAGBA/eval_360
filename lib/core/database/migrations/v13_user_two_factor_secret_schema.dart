import 'package:sqflite/sqflite.dart';

/// Migration V13 - Ajout du secret 2FA pour les Utilisateurs
class V13UserTwoFactorSecretSchema {
  static Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE utilisateurs_acces ADD COLUMN two_factor_secret TEXT');
    print('V13 User Two Factor Secret Schema migration completed');
  }
}
