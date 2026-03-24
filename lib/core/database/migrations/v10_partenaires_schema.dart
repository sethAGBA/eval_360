import 'package:sqflite/sqflite.dart';

/// Migration V10 - Partenaires Techniques et Financiers (PTF)
class V10PartenairesSchema {
  static Future<void> migrate(Database db) async {
    await db.execute('''
      CREATE TABLE partenaires_ptf (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        pays TEXT,
        secteur TEXT,
        contact_nom TEXT,
        contact_email TEXT,
        contact_telephone TEXT,
        financement_total REAL,
        description TEXT,
        date_debut TEXT,
        date_fin TEXT,
        actif INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Quelques PTF de référence au Togo
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> seeds = [
      {'nom': 'Union Européenne', 'type': 'multilateral', 'pays': 'Europe', 'secteur': 'Développement local', 'actif': 1},
      {'nom': 'Banque Mondiale', 'type': 'multilateral', 'pays': 'International', 'secteur': 'Finance & Gouvernance', 'actif': 1},
      {'nom': 'PNUD Togo', 'type': 'multilateral', 'pays': 'International', 'secteur': 'Gouvernance & Décentralisation', 'actif': 1},
      {'nom': 'GIZ', 'type': 'bilateral', 'pays': 'Allemagne', 'secteur': 'Développement durable', 'actif': 1},
      {'nom': 'AFD', 'type': 'bilateral', 'pays': 'France', 'secteur': 'Infrastructure', 'actif': 1},
    ];

    for (final seed in seeds) {
      await db.insert('partenaires_ptf', {...seed, 'created_at': now});
    }

    await db.execute('CREATE INDEX idx_partenaires_type ON partenaires_ptf(type)');
    print('V10 Partenaires Schema migration completed');
  }
}
