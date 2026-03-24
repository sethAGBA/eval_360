import 'package:sqflite/sqflite.dart';

/// Migration V7 - Digitalisation & GED
/// Ajoute les tables pour les TdR, Ordres de Mission et la Gestion Documentaire
class V7DigitalizationSchema {
  static Future<void> migrate(Database db) async {
    // =========================================================================
    // GESTION DOCUMENTAIRE (GED)
    // =========================================================================
    
    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        type_document TEXT NOT NULL, -- TdR, ORD, Rapport, CR, Autre
        file_path TEXT,
        extension TEXT,
        taille INTEGER,
        projet_id INTEGER,
        activite_id INTEGER,
        agent_id INTEGER,
        date_document TEXT NOT NULL,
        statut_validation TEXT NOT NULL DEFAULT 'brouillon',
        reference_boite TEXT, -- Archivage physique
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE SET NULL,
        FOREIGN KEY (activite_id) REFERENCES activites(id) ON DELETE SET NULL,
        FOREIGN KEY (agent_id) REFERENCES utilisateurs_acces(id) ON DELETE SET NULL
      )
    ''');

    // =========================================================================
    // TERMES DE RÉFÉRENCE (TdR)
    // =========================================================================
    
    await db.execute('''
      CREATE TABLE termes_de_reference (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id INTEGER NOT NULL,
        contexte_justification TEXT,
        objectifs_generaux TEXT,
        objectifs_specifiques TEXT,
        resultats_attendus TEXT,
        methodologie TEXT,
        lieu_execution TEXT,
        date_debut TEXT,
        date_fin TEXT,
        budget_estime REAL DEFAULT 0,
        participants_prevus TEXT, -- JSON ou liste
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''');

    // =========================================================================
    // ORDRES DE MISSION (ORD)
    // =========================================================================
    
    await db.execute('''
      CREATE TABLE ordres_mission (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id INTEGER NOT NULL,
        objet_mission TEXT NOT NULL,
        itineraire TEXT,
        date_depart TEXT NOT NULL,
        date_retour TEXT NOT NULL,
        moyen_transport TEXT,
        vehicule_id TEXT, -- Ou référence table véhicules si existait
        accompagnateurs TEXT,
        observation TEXT,
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''');

    // =========================================================================
    // INDEXES
    // =========================================================================
    
    await db.execute('CREATE INDEX idx_documents_projet ON documents(projet_id)');
    await db.execute('CREATE INDEX idx_documents_type ON documents(type_document)');
    await db.execute('CREATE INDEX idx_tdr_document ON termes_de_reference(document_id)');
    await db.execute('CREATE INDEX idx_ord_document ON ordres_mission(document_id)');

    print('V7 Digitalization Schema migration completed');
  }
}
