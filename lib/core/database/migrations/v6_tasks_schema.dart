import 'package:sqflite/sqflite.dart';

class V6TasksSchema {
  static Future<void> migrate(Database db) async {
    // 1. Création de la table des tâches
    await db.execute('''
      CREATE TABLE taches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT,
        priorite TEXT NOT NULL DEFAULT 'moyenne',
        statut TEXT NOT NULL DEFAULT 'a_faire',
        date_echeance TEXT,
        pourcentage_avancement REAL DEFAULT 0.0,
        agent_id INTEGER NOT NULL,
        activite_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (agent_id) REFERENCES utilisateurs_acces (id) ON DELETE CASCADE,
        FOREIGN KEY (activite_id) REFERENCES activites (id) ON DELETE SET NULL
      )
    ''');

    // 2. Index pour optimiser les recherches par agent ou par statut
    await db.execute('CREATE INDEX idx_taches_agent ON taches (agent_id)');
    await db.execute('CREATE INDEX idx_taches_statut ON taches (statut)');
  }
}

/// Énumérations pour les tâches
class TachePriorite {
  static const String basse = 'basse';
  static const String moyenne = 'moyenne';
  static const String haute = 'haute';
}

class TacheStatut {
  static const String aFaire = 'a_faire';
  static const String enCours = 'en_cours';
  static const String termine = 'termine';
  static const String suspendu = 'suspendu';
}
