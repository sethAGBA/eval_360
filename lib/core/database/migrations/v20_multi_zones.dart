import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

class V20MultiZones {
  static Future<void> migrate(Database db) async {
    // 1. Créer la table d'association activite_zones
    await db.execute('''
      CREATE TABLE ${DatabaseTables.activiteZones} (
        activite_id INTEGER NOT NULL,
        zone_id INTEGER NOT NULL,
        PRIMARY KEY (activite_id, zone_id),
        FOREIGN KEY (activite_id) REFERENCES ${DatabaseTables.activites} (id) ON DELETE CASCADE,
        FOREIGN KEY (zone_id) REFERENCES ${DatabaseTables.zones} (id) ON DELETE CASCADE
      )
    ''');

    // 2. Migrer les données existantes de activites.zone_id vers activite_zones
    final List<Map<String, dynamic>> existingLinks = await db.rawQuery(
      'SELECT id, zone_id FROM ${DatabaseTables.activites} WHERE zone_id IS NOT NULL',
    );

    for (final link in existingLinks) {
      final activiteId = link['id'];
      final zoneId = link['zone_id'];
      
      await db.insert(DatabaseTables.activiteZones, {
        'activite_id': activiteId,
        'zone_id': zoneId,
      });
    }

    // Note: On garde la colonne zone_id par précaution de rétrocompatibilité pour l'instant,
    // mais on ne l'utilisera plus dans le code.
  }
}
