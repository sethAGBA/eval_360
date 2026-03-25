import 'package:sqflite/sqflite.dart';

/// Migration V17 - Support Multi-Communes pour les Activités
/// Crée une table d'association activite_communes
class V17MultiCommunesActivites {
  static Future<void> migrate(Database db) async {
    // 1. Créer la table d'association
    await db.execute('''
      CREATE TABLE activite_communes (
        activite_id INTEGER NOT NULL,
        commune_id INTEGER NOT NULL,
        PRIMARY KEY (activite_id, commune_id),
        FOREIGN KEY (activite_id) REFERENCES activites (id) ON DELETE CASCADE,
        FOREIGN KEY (commune_id) REFERENCES communes_pdc (id) ON DELETE CASCADE
      )
    ''');

    // 2. Migrer les données existantes de activites.commune_id vers la nouvelle table
    await db.execute('''
      INSERT INTO activite_communes (activite_id, commune_id)
      SELECT id, commune_id FROM activites WHERE commune_id IS NOT NULL
    ''');
    
    print('V17 Multi-Communes migration completed');
  }
}
