import 'package:sqflite/sqflite.dart';

/// Migration V18 - Ajout de la colonne created_at pour les communes
class V18AddCommunesCreatedAt {
  static Future<void> migrate(Database db) async {
    // Ajouter la colonne created_at
    await db.execute('ALTER TABLE communes_pdc ADD COLUMN created_at TEXT');
    
    // Initialiser created_at avec la valeur de date_maj pour les enregistrements existants
    await db.execute('UPDATE communes_pdc SET created_at = date_maj WHERE created_at IS NULL');
    
    print('V18 Add Communes CreatedAt migration completed');
  }
}
