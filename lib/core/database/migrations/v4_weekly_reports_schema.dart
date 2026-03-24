import 'package:sqflite/sqflite.dart';

/// Migration V4 - Rapports Hebdomadaires
/// Ajoute les tables pour le module 04 du cahier des charges
class V4WeeklyReportsSchema {
  static Future<void> migrate(Database db) async {
    // =========================================================================
    // RAPPORTS HEBDOMADAIRES
    // =========================================================================

    await db.execute('''
      CREATE TABLE rapports_hebdo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        agent_id INTEGER NOT NULL,
        semaine_numero INTEGER NOT NULL,
        annee INTEGER NOT NULL,
        date_debut TEXT NOT NULL,
        date_fin TEXT NOT NULL,
        statut_validation TEXT NOT NULL DEFAULT 'brouillon',
        commentaire_superviseur TEXT,
        valide_par_id INTEGER,
        date_validation TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (agent_id) REFERENCES utilisateurs_acces(id),
        FOREIGN KEY (valide_par_id) REFERENCES utilisateurs_acces(id)
      )
    ''');

    // =========================================================================
    // LIGNES DE RAPPORT (DÉTAILS DES ACTIVITÉS)
    // =========================================================================

    await db.execute('''
      CREATE TABLE lignes_rapport (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rapport_id INTEGER NOT NULL,
        activite_id INTEGER,
        description TEXT NOT NULL,
        evenement_connexe TEXT,
        lieu TEXT,
        structure_id INTEGER,
        responsable TEXT,
        date_debut TEXT NOT NULL,
        date_fin TEXT NOT NULL,
        statut_activite TEXT NOT NULL,
        resultats_atteints TEXT,
        difficultes_rencontrees TEXT,
        prochaines_etapes TEXT,
        FOREIGN KEY (rapport_id) REFERENCES rapports_hebdo(id) ON DELETE CASCADE,
        FOREIGN KEY (activite_id) REFERENCES activites(id)
      )
    ''');

    // Index pour performance
    await db.execute(
      'CREATE INDEX idx_rapports_agent ON rapports_hebdo(agent_id)',
    );
    await db.execute(
      'CREATE INDEX idx_rapports_semaine ON rapports_hebdo(semaine_numero, annee)',
    );
    await db.execute(
      'CREATE INDEX idx_lignes_rapport ON lignes_rapport(rapport_id)',
    );

    print('V4 Weekly Reports Schema migration completed');
  }
}
