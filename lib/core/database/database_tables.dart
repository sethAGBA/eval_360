/// Noms des tables de la base de données
class DatabaseTables {
  DatabaseTables._();

  // Tables principales
  static const String utilisateurs = 'utilisateurs_acces';
  static const String parametres = 'parametres_systeme';
  static const String projets = 'projets';
  static const String bailleurs = 'bailleurs_partenaires';
  static const String projetBailleurs = 'projet_bailleurs';
  static const String projetZones = 'projet_zones';
  static const String zones = 'zones_intervention';
  static const String auditLogs = 'audit_logs';

  // Bénéficiaires
  static const String beneficiaires = 'beneficiaires';

  // Cadre Logique & Indicateurs
  static const String cadreLogique = 'cadre_logique';
  static const String indicateurs = 'indicateurs';
  static const String ciblesIntermediaires = 'cibles_intermediaires';
  static const String donneesCollecte = 'donnees_collecte';

  // Planification & Activités
  static const String plansTravail = 'plans_travail';
  static const String activites = 'activites';
  static const String activiteDependances = 'activite_dependances';
  static const String jalonsLivrables = 'jalons_livrables';

  // Budget & Finances
  static const String budgetLignes = 'budget_lignes';
  static const String depensesDecaissements = 'depenses_decaissements';

  // Rapports Hebdomadaires (Module 04)
  static const String rapportsHebdo = 'rapports_hebdo';
  static const String lignesRapport = 'lignes_rapport';

  // Rapports Mensuels (Module 05)
  static const String rapportsMensuels = 'rapports_mensuels';
  static const String syntheseAxesMensuels = 'synthese_axes_mensuels';

  // Tâches (Module 06)
  static const String taches = 'taches';

  // Digitalisation & GED (Phase 3)
  static const String documents = 'documents';
  static const String termesDeReference = 'termes_de_reference';
  static const String ordresMission = 'ordres_mission';
  static const String rapportsStage = 'rapports_stage';
  static const String communesPdc = 'communes_pdc';
  static const String partenaniresPtf = 'partenaires_ptf';
}

/// Colonnes de la table utilisateurs_acces
class UtilisateursColumns {
  UtilisateursColumns._();

  static const String id = 'id';
  static const String username = 'username';
  static const String email = 'email';
  static const String passwordHash = 'password_hash';
  static const String nom = 'nom';
  static const String prenom = 'prenom';
  static const String role = 'role';
  static const String projetsAssignes = 'projets_assignes';
  static const String permissions = 'permissions';
  static const String actif = 'actif';
  static const String derniereConnexion = 'derniere_connexion';
  static const String twoFactorEnabled = 'two_factor_enabled';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Colonnes de la table projets
class ProjetsColumns {
  ProjetsColumns._();

  static const String id = 'id';
  static const String codeProjet = 'code_projet';
  static const String titre = 'titre';
  static const String description = 'description';
  static const String contexte = 'contexte';
  static const String secteurIntervention = 'secteur_intervention';
  static const String dateDebutPrevue = 'date_debut_prevue';
  static const String dateFinPrevue = 'date_fin_prevue';
  static const String dateDebutReelle = 'date_debut_reelle';
  static const String dateFinReelle = 'date_fin_reelle';
  static const String budgetTotal = 'budget_total';
  static const String statut = 'statut';
  static const String chefProjetId = 'chef_projet_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Colonnes de la table bailleurs_partenaires
class BailleursColumns {
  BailleursColumns._();

  static const String id = 'id';
  static const String nom = 'nom';
  static const String type = 'type';
  static const String pays = 'pays';
  static const String contactNom = 'contact_nom';
  static const String contactEmail = 'contact_email';
  static const String contactTelephone = 'contact_telephone';
  static const String adresse = 'adresse';
  static const String siteWeb = 'site_web';
  static const String createdAt = 'created_at';
}

/// Colonnes de la table zones_intervention
class ZonesColumns {
  ZonesColumns._();

  static const String id = 'id';
  static const String pays = 'pays';
  static const String region = 'region';
  static const String provinceDepartement = 'province_departement';
  static const String communeDistrict = 'commune_district';
  static const String villageQuartier = 'village_quartier';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String populationTotale = 'population_totale';
}

/// Colonnes de la table rapports_hebdo
class RapportsHebdoColumns {
  RapportsHebdoColumns._();

  static const String id = 'id';
  static const String agentId = 'agent_id';
  static const String semaineNumero = 'semaine_numero';
  static const String annee = 'annee';
  static const String dateDebut = 'date_debut';
  static const String dateFin = 'date_fin';
  static const String statutValidation = 'statut_validation';
  static const String commentaireSuperviseur = 'commentaire_superviseur';
  static const String valideParId = 'valide_par_id';
  static const String dateValidation = 'date_validation';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Colonnes de la table lignes_rapport
class LignesRapportColumns {
  LignesRapportColumns._();

  static const String id = 'id';
  static const String rapportId = 'rapport_id';
  static const String activiteId = 'activite_id';
  static const String description = 'description';
  static const String evenementConnexe = 'evenement_connexe';
  static const String lieu = 'lieu';
  static const String structureId = 'structure_id';
  static const String responsable = 'responsable';
  static const String dateDebut = 'date_debut';
  static const String dateFin = 'date_fin';
  static const String statutActivite = 'statut_activite';
  static const String resultatsAtteints = 'resultats_atteints';
  static const String difficultesRencontrees = 'difficultes_rencontrees';
  static const String prochainesEtapes = 'prochaines_etapes';
}

/// Colonnes de la table taches
class TachesColumns {
  TachesColumns._();

  static const String id = 'id';
  static const String titre = 'titre';
  static const String description = 'description';
  static const String priorite = 'priorite';
  static const String statut = 'statut';
  static const String dateEcheance = 'date_echeance';
  static const String pourcentageAvancement = 'pourcentage_avancement';
  static const String agentId = 'agent_id';
  static const String activiteId = 'activite_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
