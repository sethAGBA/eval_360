import 'package:sqflite/sqflite.dart';

/// Migration V2 - Extension du schéma pour Phase 2
/// Ajoute les tables pour le module Gestion des Projets complet
class V2ProjectManagementSchema {
  static Future<void> migrate(Database db) async {
    // =========================================================================
    // BÉNÉFICIAIRES
    // =========================================================================

    await db.execute('''
      CREATE TABLE beneficiaires (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        groupe_cible TEXT NOT NULL,
        nombre_prevu INTEGER DEFAULT 0,
        nombre_atteint INTEGER DEFAULT 0,
        criteres_selection TEXT,
        repartition_sexe_h INTEGER DEFAULT 0,
        repartition_sexe_f INTEGER DEFAULT 0,
        repartition_age_0_18 INTEGER DEFAULT 0,
        repartition_age_19_35 INTEGER DEFAULT 0,
        repartition_age_36_plus INTEGER DEFAULT 0,
        zone_id INTEGER,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (zone_id) REFERENCES zones_intervention(id)
      )
    ''');

    // =========================================================================
    // CADRE LOGIQUE & THÉORIE DU CHANGEMENT
    // =========================================================================

    await db.execute('''
      CREATE TABLE cadre_logique (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        niveau TEXT NOT NULL,
        code TEXT NOT NULL,
        libelle TEXT NOT NULL,
        description TEXT,
        parent_id INTEGER,
        ordre INTEGER DEFAULT 0,
        hypotheses_risques TEXT,
        moyens_verification TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES cadre_logique(id),
        UNIQUE(projet_id, code)
      )
    ''');

    // =========================================================================
    // INDICATEURS
    // =========================================================================

    await db.execute('''
      CREATE TABLE indicateurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        cadre_logique_id INTEGER,
        code_indicateur TEXT NOT NULL,
        libelle TEXT NOT NULL,
        definition TEXT,
        niveau TEXT NOT NULL,
        type TEXT NOT NULL,
        unite_mesure TEXT,
        baseline REAL,
        cible_finale REAL,
        frequence_collecte TEXT NOT NULL,
        responsable_collecte_id INTEGER,
        source_donnees TEXT,
        methode_collecte TEXT,
        desagregation_sexe INTEGER DEFAULT 0,
        desagregation_age INTEGER DEFAULT 0,
        desagregation_zone INTEGER DEFAULT 0,
        seuil_alerte_min REAL,
        seuil_alerte_max REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (cadre_logique_id) REFERENCES cadre_logique(id),
        FOREIGN KEY (responsable_collecte_id) REFERENCES utilisateurs_acces(id),
        UNIQUE(projet_id, code_indicateur)
      )
    ''');

    await db.execute('''
      CREATE TABLE cibles_intermediaires (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        indicateur_id INTEGER NOT NULL,
        periode_type TEXT NOT NULL,
        annee INTEGER NOT NULL,
        trimestre INTEGER,
        mois INTEGER,
        valeur_cible REAL NOT NULL,
        FOREIGN KEY (indicateur_id) REFERENCES indicateurs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE donnees_collecte (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        indicateur_id INTEGER NOT NULL,
        date_collecte TEXT NOT NULL,
        valeur_mesuree REAL NOT NULL,
        valeur_desagregee_h REAL,
        valeur_desagregee_f REAL,
        valeur_desagregee_0_18 REAL,
        valeur_desagregee_19_35 REAL,
        valeur_desagregee_36_plus REAL,
        zone_id INTEGER,
        methode_utilisee TEXT,
        source_verification TEXT,
        commentaire_qualitatif TEXT,
        latitude REAL,
        longitude REAL,
        collecte_par_id INTEGER,
        valide INTEGER DEFAULT 0,
        valide_par_id INTEGER,
        date_validation TEXT,
        pieces_justificatives TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (indicateur_id) REFERENCES indicateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (zone_id) REFERENCES zones_intervention(id),
        FOREIGN KEY (collecte_par_id) REFERENCES utilisateurs_acces(id),
        FOREIGN KEY (valide_par_id) REFERENCES utilisateurs_acces(id)
      )
    ''');

    // =========================================================================
    // PLANIFICATION & ACTIVITÉS
    // =========================================================================

    await db.execute('''
      CREATE TABLE plans_travail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        annee INTEGER NOT NULL,
        trimestre INTEGER,
        mois INTEGER,
        date_debut TEXT NOT NULL,
        date_fin TEXT NOT NULL,
        statut TEXT NOT NULL DEFAULT 'brouillon',
        valide_par_id INTEGER,
        date_validation TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (valide_par_id) REFERENCES utilisateurs_acces(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE activites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        plan_travail_id INTEGER,
        cadre_logique_id INTEGER,
        code_activite TEXT NOT NULL,
        intitule TEXT NOT NULL,
        description TEXT,
        type_activite TEXT,
        priorite TEXT DEFAULT 'moyenne',
        date_debut_prevue TEXT NOT NULL,
        date_fin_prevue TEXT NOT NULL,
        date_debut_reelle TEXT,
        date_fin_reelle TEXT,
        responsable_id INTEGER,
        zone_id INTEGER,
        statut TEXT NOT NULL DEFAULT 'planifiee',
        pourcentage_avancement INTEGER DEFAULT 0,
        budget_estime REAL DEFAULT 0,
        budget_engage REAL DEFAULT 0,
        budget_realise REAL DEFAULT 0,
        nombre_beneficiaires_cibles INTEGER DEFAULT 0,
        nombre_beneficiaires_atteints INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (plan_travail_id) REFERENCES plans_travail(id),
        FOREIGN KEY (cadre_logique_id) REFERENCES cadre_logique(id),
        FOREIGN KEY (responsable_id) REFERENCES utilisateurs_acces(id),
        FOREIGN KEY (zone_id) REFERENCES zones_intervention(id),
        UNIQUE(projet_id, code_activite)
      )
    ''');

    await db.execute('''
      CREATE TABLE projet_zones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        zone_id INTEGER NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (zone_id) REFERENCES zones_intervention(id) ON DELETE CASCADE,
        UNIQUE(projet_id, zone_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE activite_dependances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activite_id INTEGER NOT NULL,
        activite_prerequise_id INTEGER NOT NULL,
        type_dependance TEXT NOT NULL DEFAULT 'finish_to_start',
        FOREIGN KEY (activite_id) REFERENCES activites(id) ON DELETE CASCADE,
        FOREIGN KEY (activite_prerequise_id) REFERENCES activites(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE jalons_livrables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        activite_id INTEGER,
        type TEXT NOT NULL,
        libelle TEXT NOT NULL,
        description TEXT,
        date_prevue TEXT NOT NULL,
        date_reelle TEXT,
        statut TEXT NOT NULL DEFAULT 'planifie',
        responsable_id INTEGER,
        piece_justificative TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (activite_id) REFERENCES activites(id),
        FOREIGN KEY (responsable_id) REFERENCES utilisateurs_acces(id)
      )
    ''');

    // =========================================================================
    // BUDGET & FINANCES
    // =========================================================================

    await db.execute('''
      CREATE TABLE budget_lignes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        bailleur_id INTEGER,
        code_ligne TEXT NOT NULL,
        libelle TEXT NOT NULL,
        categorie TEXT NOT NULL,
        budget_initial REAL NOT NULL DEFAULT 0,
        reallocations REAL DEFAULT 0,
        budget_revise REAL NOT NULL DEFAULT 0,
        annee INTEGER NOT NULL,
        trimestre INTEGER,
        cadre_logique_id INTEGER,
        zone_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (bailleur_id) REFERENCES bailleurs_partenaires(id),
        FOREIGN KEY (cadre_logique_id) REFERENCES cadre_logique(id),
        FOREIGN KEY (zone_id) REFERENCES zones_intervention(id),
        UNIQUE(projet_id, code_ligne)
      )
    ''');

    await db.execute('''
      CREATE TABLE depenses_decaissements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        budget_ligne_id INTEGER NOT NULL,
        activite_id INTEGER,
        type_operation TEXT NOT NULL,
        numero_piece TEXT NOT NULL,
        date_operation TEXT NOT NULL,
        montant REAL NOT NULL,
        devise TEXT DEFAULT 'FCFA',
        fournisseur_prestataire TEXT,
        description TEXT,
        mode_paiement TEXT,
        numero_facture_recu TEXT,
        statut_validation TEXT NOT NULL DEFAULT 'en_attente',
        demande_par_id INTEGER,
        approuve_technique_par_id INTEGER,
        approuve_financier_par_id INTEGER,
        paye_par_id INTEGER,
        date_paiement TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (budget_ligne_id) REFERENCES budget_lignes(id),
        FOREIGN KEY (activite_id) REFERENCES activites(id),
        FOREIGN KEY (demande_par_id) REFERENCES utilisateurs_acces(id),
        FOREIGN KEY (approuve_technique_par_id) REFERENCES utilisateurs_acces(id),
        FOREIGN KEY (approuve_financier_par_id) REFERENCES utilisateurs_acces(id),
        FOREIGN KEY (paye_par_id) REFERENCES utilisateurs_acces(id),
        UNIQUE(projet_id, numero_piece)
      )
    ''');

    // =========================================================================
    // INDEXES POUR PERFORMANCE
    // =========================================================================

    // Beneficiaires
    await db.execute(
      'CREATE INDEX idx_beneficiaires_projet ON beneficiaires(projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_beneficiaires_zone ON beneficiaires(zone_id)',
    );

    // Cadre Logique
    await db.execute(
      'CREATE INDEX idx_cadre_logique_projet ON cadre_logique(projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_cadre_logique_parent ON cadre_logique(parent_id)',
    );
    await db.execute(
      'CREATE INDEX idx_cadre_logique_niveau ON cadre_logique(niveau)',
    );

    // Indicateurs
    await db.execute(
      'CREATE INDEX idx_indicateurs_projet ON indicateurs(projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_indicateurs_cadre ON indicateurs(cadre_logique_id)',
    );
    await db.execute(
      'CREATE INDEX idx_indicateurs_niveau ON indicateurs(niveau)',
    );
    await db.execute(
      'CREATE INDEX idx_cibles_indicateur ON cibles_intermediaires(indicateur_id)',
    );
    await db.execute(
      'CREATE INDEX idx_donnees_indicateur ON donnees_collecte(indicateur_id)',
    );
    await db.execute(
      'CREATE INDEX idx_donnees_date ON donnees_collecte(date_collecte)',
    );

    // Activités
    await db.execute(
      'CREATE INDEX idx_activites_projet ON activites(projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_activites_plan ON activites(plan_travail_id)',
    );
    await db.execute(
      'CREATE INDEX idx_activites_responsable ON activites(responsable_id)',
    );
    await db.execute('CREATE INDEX idx_activites_statut ON activites(statut)');
    await db.execute(
      'CREATE INDEX idx_activites_dates ON activites(date_debut_prevue, date_fin_prevue)',
    );

    // Budget
    await db.execute(
      'CREATE INDEX idx_budget_projet ON budget_lignes(projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_budget_bailleur ON budget_lignes(bailleur_id)',
    );
    await db.execute(
      'CREATE INDEX idx_budget_categorie ON budget_lignes(categorie)',
    );
    await db.execute(
      'CREATE INDEX idx_depenses_projet ON depenses_decaissements(projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_depenses_budget ON depenses_decaissements(budget_ligne_id)',
    );
    await db.execute(
      'CREATE INDEX idx_depenses_statut ON depenses_decaissements(statut_validation)',
    );
    await db.execute(
      'CREATE INDEX idx_depenses_date ON depenses_decaissements(date_operation)',
    );

    print('V2 Project Management Schema migration completed');
  }
}
