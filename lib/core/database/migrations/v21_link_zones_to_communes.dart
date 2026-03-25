import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

/// Migration V21 - Lien entre Zones d'Intervention et Communes
/// Ajoute une colonne commune_id à la table zones_intervention
class V21LinkZonesToCommunes {
  static Future<void> migrate(Database db) async {
    // Note: SQLite ne supporte pas l'ajout d'une colonne avec une contrainte FOREIGN KEY directe via ALTER TABLE.
    // Cependant, nous pouvons l'ajouter et la contrainte sera vérifiée si PRAGMA foreign_keys = ON est activé.
    
    await db.execute('ALTER TABLE ${DatabaseTables.zones} ADD COLUMN commune_id INTEGER REFERENCES communes_pdc(id) ON DELETE SET NULL');
    
    print('V21 Link Zones to Communes migration completed');
  }
}
