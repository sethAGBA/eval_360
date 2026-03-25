import 'package:sqflite/sqflite.dart';

/// Migration V11 - Lien entre Projets et Partenaires PTF
class V11ProjetPartenairesSchema {
  static Future<void> migrate(Database db) async {
    await db.execute('''
      CREATE TABLE projet_partenaires (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        partenaire_id INTEGER NOT NULL,
        role TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (partenaire_id) REFERENCES partenaires_ptf(id) ON DELETE CASCADE,
        UNIQUE(projet_id, partenaire_id)
      )
    ''');
    
    await db.execute('CREATE INDEX idx_projet_partenaires_projet ON projet_partenaires(projet_id)');
    
    print('V11 Projet Partenaires Schema migration completed');
  }
}
