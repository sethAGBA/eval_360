import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

/// Migration pour ajouter les tables de rapports mensuels (Module 05)
class V5MonthlyReportsSchema {
  static Future<void> migrate(Database db) async {
    // 1. Table des rapports mensuels
    await db.execute('''
      CREATE TABLE ${DatabaseTables.rapportsMensuels} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        agent_id INTEGER NOT NULL,
        mois INTEGER NOT NULL,
        annee INTEGER NOT NULL,
        taux_realisation_global REAL DEFAULT 0,
        statut_validation TEXT NOT NULL DEFAULT 'brouillon',
        commentaire_superviseur TEXT,
        valide_par_id INTEGER,
        date_validation TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (agent_id) REFERENCES ${DatabaseTables.utilisateurs} (id) ON DELETE CASCADE
      )
    ''');

    // 2. Table de synthèse par axe PTBA
    await db.execute('''
      CREATE TABLE ${DatabaseTables.syntheseAxesMensuels} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rapport_mensuel_id INTEGER NOT NULL,
        axe_id INTEGER,
        libelle_axe TEXT NOT NULL,
        taux_realisation REAL DEFAULT 0,
        nombre_activites_prevues INTEGER DEFAULT 0,
        nombre_activites_realisees INTEGER DEFAULT 0,
        FOREIGN KEY (rapport_mensuel_id) REFERENCES ${DatabaseTables.rapportsMensuels} (id) ON DELETE CASCADE
      )
    ''');

    // 3. Index pour recherche rapide
    await db.execute('CREATE INDEX idx_rapport_mensuel_agent ON ${DatabaseTables.rapportsMensuels} (agent_id, annee, mois)');
  }
}

/// Colonnes de la table rapports_mensuels
class RapportsMensuelsColumns {
  RapportsMensuelsColumns._();
  static const String id = 'id';
  static const String agentId = 'agent_id';
  static const String mois = 'mois';
  static const String annee = 'annee';
  static const String tauxRealisationGlobal = 'taux_realisation_global';
  static const String statutValidation = 'statut_validation';
  static const String commentaireSuperviseur = 'commentaire_superviseur';
  static const String valideParId = 'valide_par_id';
  static const String dateValidation = 'date_validation';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Colonnes de la table synthese_axes_mensuels
class SyntheseAxesMensuelsColumns {
  SyntheseAxesMensuelsColumns._();
  static const String id = 'id';
  static const String rapportMensuelId = 'rapport_mensuel_id';
  static const String axeId = 'axe_id';
  static const String libelleAxe = 'libelle_axe';
  static const String tauxRealisation = 'taux_realisation';
  static const String nombreActivitesPrevues = 'nombre_activites_prevues';
  static const String nombreActivitesRealisees = 'nombre_activites_realisees';
}
