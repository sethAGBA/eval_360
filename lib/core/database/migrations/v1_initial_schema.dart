import 'package:sqflite/sqflite.dart';

/// Migration initiale - Version 1
/// Crée les tables essentielles pour le démarrage de l'application
class V1InitialSchema {
  static Future<void> migrate(Database db) async {
    // Table utilisateurs_acces
    await db.execute('''
      CREATE TABLE utilisateurs_acces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        role TEXT NOT NULL,
        projets_assignes TEXT DEFAULT '[]',
        permissions TEXT DEFAULT '{}',
        actif INTEGER DEFAULT 1,
        derniere_connexion TEXT,
        two_factor_enabled INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table parametres_systeme
    await db.execute('''
      CREATE TABLE parametres_systeme (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cle TEXT NOT NULL UNIQUE,
        valeur TEXT NOT NULL,
        categorie TEXT NOT NULL,
        description TEXT,
        modifie_at TEXT NOT NULL
      )
    ''');

    // Table projets
    await db.execute('''
      CREATE TABLE projets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code_projet TEXT NOT NULL UNIQUE,
        titre TEXT NOT NULL,
        description TEXT,
        contexte TEXT,
        secteur_intervention TEXT,
        date_debut_prevue TEXT NOT NULL,
        date_fin_prevue TEXT NOT NULL,
        date_debut_reelle TEXT,
        date_fin_reelle TEXT,
        budget_total REAL NOT NULL DEFAULT 0,
        statut TEXT NOT NULL DEFAULT 'pipeline',
        chef_projet_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (chef_projet_id) REFERENCES utilisateurs_acces(id)
      )
    ''');

    // Table bailleurs_partenaires
    await db.execute('''
      CREATE TABLE bailleurs_partenaires (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        pays TEXT,
        contact_nom TEXT,
        contact_email TEXT,
        contact_telephone TEXT,
        adresse TEXT,
        site_web TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Table projet_bailleurs (many-to-many)
    await db.execute('''
      CREATE TABLE projet_bailleurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projet_id INTEGER NOT NULL,
        bailleur_id INTEGER NOT NULL,
        role TEXT NOT NULL,
        montant_contribution REAL,
        devise TEXT DEFAULT 'USD',
        date_convention TEXT,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE CASCADE,
        FOREIGN KEY (bailleur_id) REFERENCES bailleurs_partenaires(id),
        UNIQUE(projet_id, bailleur_id)
      )
    ''');

    // Table zones_intervention
    await db.execute('''
      CREATE TABLE zones_intervention (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pays TEXT NOT NULL,
        region TEXT,
        province_departement TEXT,
        commune_district TEXT,
        village_quartier TEXT,
        latitude REAL,
        longitude REAL,
        population_totale INTEGER
      )
    ''');

    // Table audit_logs
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER,
        action TEXT NOT NULL,
        entite_type TEXT NOT NULL,
        entite_id INTEGER,
        donnees_avant TEXT,
        donnees_apres TEXT,
        ip_address TEXT,
        user_agent TEXT,
        timestamp TEXT NOT NULL,
        resultat TEXT NOT NULL,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs_acces(id)
      )
    ''');

    // Créer les indexes pour améliorer les performances
    await db.execute('CREATE INDEX idx_projets_statut ON projets(statut)');
    await db.execute(
      'CREATE INDEX idx_projets_chef ON projets(chef_projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_audit_utilisateur ON audit_logs(utilisateur_id)',
    );
    await db.execute(
      'CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_projet_bailleurs_projet ON projet_bailleurs(projet_id)',
    );
    await db.execute(
      'CREATE INDEX idx_projet_bailleurs_bailleur ON projet_bailleurs(bailleur_id)',
    );

    print('V1 Initial Schema migration completed');
  }
}
