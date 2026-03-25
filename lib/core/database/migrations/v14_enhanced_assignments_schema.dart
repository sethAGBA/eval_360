import 'package:sqflite/sqflite.dart';

/// Migration V14 - Multi-assignation et enrichissement des activités
class V14EnhancedAssignmentsSchema {
  static Future<void> migrate(Database db) async {
    // 1. Enrichir la table activites
    await db.execute('ALTER TABLE activites ADD COLUMN livrables TEXT');
    await db.execute('ALTER TABLE activites ADD COLUMN indicateurs_reussite TEXT');
    await db.execute('ALTER TABLE activites ADD COLUMN risques TEXT');
    await db.execute('ALTER TABLE activites ADD COLUMN observations TEXT');
    await db.execute('ALTER TABLE activites ADD COLUMN lieu TEXT');

    // 2. Créer la table de liaison tache_assignations
    await db.execute('''
      CREATE TABLE tache_assignations (
        tache_id INTEGER NOT NULL,
        agent_id INTEGER NOT NULL,
        PRIMARY KEY (tache_id, agent_id),
        FOREIGN KEY (tache_id) REFERENCES taches(id) ON DELETE CASCADE,
        FOREIGN KEY (agent_id) REFERENCES utilisateurs_acces(id) ON DELETE CASCADE
      )
    ''');

    // 3. Créer la table de liaison activite_assignations
    await db.execute('''
      CREATE TABLE activite_assignations (
        activite_id INTEGER NOT NULL,
        agent_id INTEGER NOT NULL,
        PRIMARY KEY (activite_id, agent_id),
        FOREIGN KEY (activite_id) REFERENCES activites(id) ON DELETE CASCADE,
        FOREIGN KEY (agent_id) REFERENCES utilisateurs_acces(id) ON DELETE CASCADE
      )
    ''');

    // 4. Migrer les données existantes des tâches (agent_id -> tache_assignations)
    await db.execute('''
      INSERT INTO tache_assignations (tache_id, agent_id)
      SELECT id, agent_id FROM taches WHERE agent_id IS NOT NULL
    ''');

    // 5. Migrer les responsables des activités (responsable_id -> activite_assignations)
    await db.execute('''
      INSERT INTO activite_assignations (activite_id, agent_id)
      SELECT id, responsable_id FROM activites WHERE responsable_id IS NOT NULL
    ''');

    print('V14 Enhanced Assignments Schema migration completed');
  }
}
