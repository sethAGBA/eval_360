import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

class V22AppConfigSchema {
  static Future<void> migrate(Database db) async {
    // Création de la table app_config
    await db.execute('''
      CREATE TABLE ${DatabaseTables.appConfig} (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        republique TEXT,
        ministere TEXT,
        entite TEXT,
        direction TEXT,
        sigle TEXT,
        logo_path TEXT
      )
    ''');

    // Insertion de la configuration par défaut (Togo)
    await db.insert(DatabaseTables.appConfig, {
      'id': 1,
      'republique': 'RÉPUBLIQUE TOGOLAISE',
      'ministere': 'MDDL',
      'entite': 'CPDSE-CT',
      'direction': 'Cellule de Programmation, de Développement et de Suivi Evaluation des Communes et Territoires',
      'sigle': 'CPDSE-CT / MDDL',
      'logo_path': null,
    });
  }
}
