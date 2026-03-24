import 'package:sqflite/sqflite.dart';

/// Migration V3 - Correction du schéma
/// Assure que les tables manquantes (comme projet_zones) sont créées
class V3SchemaFixes {
  static Future<void> migrate(Database db) async {
    // Créer la table projet_zones si elle n'existe pas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS projet_zones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        zone_id INTEGER NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (zone_id) REFERENCES zones_intervention(id) ON DELETE CASCADE,
        UNIQUE(projet_id, zone_id)
      )
    ''');

    print('V3 Schema Fixes migration completed');
  }
}
