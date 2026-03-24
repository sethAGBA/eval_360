import 'package:sqflite/sqflite.dart';

/// Migration V8 - Rapport de Stage Probatoire
/// Ajoute la table pour le canevas numérique du rapport de stage
class V8InternshipSchema {
  static Future<void> migrate(Database db) async {
    await db.execute('''
      CREATE TABLE rapports_stage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id INTEGER NOT NULL,
        introduction TEXT,
        presentation_structure TEXT,
        activites_realisees TEXT,
        competences_acquises TEXT,
        difficultes_rencontrees TEXT,
        solutions_apportees TEXT,
        conclusion_recommandations TEXT,
        date_soumission TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_rapport_stage_document ON rapports_stage(document_id)');
    
    print('V8 Internship Schema migration completed');
  }
}
