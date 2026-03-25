import 'package:sqflite/sqflite.dart';

/// Migration V19 - Support Multi-Cadre Logique pour les Activités
class V19MultiCadreLogique {
  static Future<void> migrate(Database db) async {
    // 1. Créer la table d'association
    await db.execute('''
      CREATE TABLE activite_cadre_logique (
        activite_id INTEGER NOT NULL,
        cadre_logique_id INTEGER NOT NULL,
        PRIMARY KEY (activite_id, cadre_logique_id),
        FOREIGN KEY (activite_id) REFERENCES activites (id) ON DELETE CASCADE,
        FOREIGN KEY (cadre_logique_id) REFERENCES cadre_logique (id) ON DELETE CASCADE
      )
    ''');

    // 2. Migrer les données existantes
    await db.execute('''
      INSERT INTO activite_cadre_logique (activite_id, cadre_logique_id)
      SELECT id, cadre_logique_id FROM activites WHERE cadre_logique_id IS NOT NULL
    ''');
    
    print('V19 Multi-Cadre Logique migration completed');
  }
}
