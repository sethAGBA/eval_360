import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';

class V23PtbaSchema {
  static Future<void> migrate(Database db) async {
    // 1. Create plans_travail table (PTBA)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.plansTravail} (
        ${PlansTravailColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PlansTravailColumns.projetId} INTEGER NOT NULL,
        ${PlansTravailColumns.type} TEXT NOT NULL DEFAULT 'annuel',
        ${PlansTravailColumns.annee} INTEGER NOT NULL,
        ${PlansTravailColumns.trimestre} INTEGER,
        ${PlansTravailColumns.mois} INTEGER,
        ${PlansTravailColumns.dateDebut} TEXT NOT NULL,
        ${PlansTravailColumns.dateFin} TEXT NOT NULL,
        ${PlansTravailColumns.statut} TEXT NOT NULL,
        ${PlansTravailColumns.valideParId} INTEGER,
        ${PlansTravailColumns.dateValidation} TEXT,
        ${PlansTravailColumns.budgetTotal} REAL DEFAULT 0.0,
        ${PlansTravailColumns.budgetEtat} REAL DEFAULT 0.0,
        ${PlansTravailColumns.budgetPtf} REAL DEFAULT 0.0,
        ${PlansTravailColumns.createdAt} TEXT NOT NULL,
        ${PlansTravailColumns.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${PlansTravailColumns.projetId}) REFERENCES ${DatabaseTables.projets} (${ProjetsColumns.id}) ON DELETE CASCADE,
        UNIQUE (${PlansTravailColumns.projetId}, ${PlansTravailColumns.annee})
      )
    ''');

    // 2. Create jalons_livrables table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.jalonsLivrables} (
        ${JalonsLivrablesColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${JalonsLivrablesColumns.activiteId} INTEGER NOT NULL,
        ${JalonsLivrablesColumns.titre} TEXT NOT NULL,
        ${JalonsLivrablesColumns.description} TEXT,
        ${JalonsLivrablesColumns.dateEcheance} TEXT NOT NULL,
        ${JalonsLivrablesColumns.statut} TEXT NOT NULL,
        ${JalonsLivrablesColumns.lienDocument} TEXT,
        ${JalonsLivrablesColumns.createdAt} TEXT NOT NULL,
        ${JalonsLivrablesColumns.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${JalonsLivrablesColumns.activiteId}) REFERENCES ${DatabaseTables.activites} (${ActivitesColumns.id}) ON DELETE CASCADE
      )
    ''');

    // 3. Add PTBA columns to activites table
    final columnsToAdd = [
      '${ActivitesColumns.budgetEtat} REAL DEFAULT 0.0',
      '${ActivitesColumns.budgetPtf} REAL DEFAULT 0.0',
      '${ActivitesColumns.mois1} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois2} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois3} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois4} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois5} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois6} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois7} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois8} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois9} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois10} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois11} INTEGER DEFAULT 0',
      '${ActivitesColumns.mois12} INTEGER DEFAULT 0',
    ];

    for (var colDef in columnsToAdd) {
      try {
        await db.execute('ALTER TABLE ${DatabaseTables.activites} ADD COLUMN $colDef;');
      } catch (e) {
        // Ignorer si la colonne existe déjà
      }
    }
  }
}
