import 'package:sqflite/sqflite.dart';

/// Migration V9 - Suivi des PDC (Communes du Togo)
/// Ajoute la table pour les Communes et le suivi des Plans de Développement Communaux
class V9CommunesSchema {
  static Future<void> migrate(Database db) async {
    await db.execute('''
      CREATE TABLE communes_pdc (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        region TEXT NOT NULL, -- Savanes, Kara, Centrale, Plateaux, Maritime
        prefecture TEXT NOT NULL,
        taux_avancement_pdc REAL DEFAULT 0,
        contact_maire TEXT,
        date_maj TEXT
      )
    ''');

    // Insertion de quelques communes de référence pour le Togo
    final List<Map<String, dynamic>> initialCommunes = [
      {'nom': 'Golfe 1', 'region': 'Maritime', 'prefecture': 'Golfe', 'taux_avancement_pdc': 45.0},
      {'nom': 'Agoè-Nyivé 1', 'region': 'Maritime', 'prefecture': 'Agoè-Nyivé', 'taux_avancement_pdc': 30.0},
      {'nom': 'Ogou 1', 'region': 'Plateaux', 'prefecture': 'Ogou', 'taux_avancement_pdc': 60.0},
      {'nom': 'Tchaoudjo 1', 'region': 'Centrale', 'prefecture': 'Tchaoudjo', 'taux_avancement_pdc': 25.0},
      {'nom': 'Kozah 1', 'region': 'Kara', 'prefecture': 'Kozah', 'taux_avancement_pdc': 80.0},
      {'nom': 'Tône 1', 'region': 'Savanes', 'prefecture': 'Tône', 'taux_avancement_pdc': 15.0},
    ];

    for (var commune in initialCommunes) {
      await db.insert('communes_pdc', {
        ...commune,
        'date_maj': DateTime.now().toIso8601String(),
      });
    }

    await db.execute('CREATE INDEX idx_communes_region ON communes_pdc(region)');
    
    print('V9 Communes Schema migration completed');
  }
}
