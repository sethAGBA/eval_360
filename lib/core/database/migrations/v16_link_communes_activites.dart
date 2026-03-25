import 'package:sqflite/sqflite.dart';

/// Migration V16 - Lien Communes et Activités
/// Ajoute une colonne commune_id à la table activites pour un lien direct
class V16LinkCommunesActivites {
  static Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE activites ADD COLUMN commune_id INTEGER');
    
    print('V16 Link Communes and Activities migration completed');
  }
}
