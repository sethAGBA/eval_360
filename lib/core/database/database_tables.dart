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
  static const String projetPartenaires = 'projet_partenaires';
  static const String zones = 'zones_intervention';
  static const String auditLogs = 'audit_logs';

  // Bénéficiaires
  static const String beneficiaires = 'beneficiaires';

  // Cadre Logique & Indicateurs
  static const String cadreLogique = 'cadre_logique';
  static const String activiteCommunes = 'activite_communes';
  static const String activiteCadreLogique = 'activite_cadre_logique';
  static const String activiteZones = 'activite_zones';
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
  static const String tacheAssignations = 'tache_assignations';
  static const String activiteAssignations = 'activite_assignations';
  static const String appConfig = 'app_config';
}

/// Colonnes de la table utilisateurs_acces
class UtilisateursColumns {
  UtilisateursColumns._();

  static const String id = 'id';
  static const String matricule = 'matricule';
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
  static const String twoFactorSecret = 'two_factor_secret';
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
  static const String communeId = 'commune_id';
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

/// Colonnes de la table jalons_livrables
class JalonsLivrablesColumns {
  JalonsLivrablesColumns._();

  static const String id = 'id';
  static const String activiteId = 'activite_id';
  static const String titre = 'titre';
  static const String description = 'description';
  static const String dateEcheance = 'date_echeance';
  static const String statut = 'statut';
  static const String lienDocument = 'lien_document';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
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
  static const String agentId = 'agent_id'; // Note: maintained for backward compat or primary resp
  static const String activiteId = 'activite_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Colonnes de la table activites (Enrichies V14)
class ActivitesColumns {
  ActivitesColumns._();

  static const String id = 'id';
  static const String projetId = 'projet_id';
  static const String planTravailId = 'plan_travail_id';
  static const String cadreLogiqueId = 'cadre_logique_id';
  static const String codeActivite = 'code_activite';
  static const String intitule = 'intitule';
  static const String description = 'description';
  static const String typeActivite = 'type_activite';
  static const String priorite = 'priorite';
  static const String dateDebutPrevue = 'date_debut_prevue';
  static const String dateFinPrevue = 'date_fin_prevue';
  static const String dateDebutReelle = 'date_debut_reelle';
  static const String dateFinReelle = 'date_fin_reelle';
  static const String responsableId = 'responsable_id';
  static const String zoneId = 'zone_id';
  static const String communeId = 'commune_id';
  static const String statut = 'statut';
  static const String pourcentageAvancement = 'pourcentage_avancement';
  static const String budgetEstime = 'budget_estime';
  static const String budgetEtat = 'budget_etat'; // Nouveau (PTBA)
  static const String budgetPtf = 'budget_ptf';   // Nouveau (PTBA)
  static const String budgetEngage = 'budget_engage';
  static const String budgetRealise = 'budget_realise';
  static const String nombreBeneficiairesCibles = 'nombre_beneficiaires_cibles';
  static const String nombreBeneficiairesAtteints = 'nombre_beneficiaires_atteints';
  static const String livrables = 'livrables'; // Deprecated in favor of JalonsLivrables
  static const String indicateursReussite = 'indicateurs_reussite';
  static const String risques = 'risques';
  static const String observations = 'observations';
  static const String lieu = 'lieu';
  // Mois planifiés (PTBA)
  static const String mois1 = 'mois_1';
  static const String mois2 = 'mois_2';
  static const String mois3 = 'mois_3';
  static const String mois4 = 'mois_4';
  static const String mois5 = 'mois_5';
  static const String mois6 = 'mois_6';
  static const String mois7 = 'mois_7';
  static const String mois8 = 'mois_8';
  static const String mois9 = 'mois_9';
  static const String mois10 = 'mois_10';
  static const String mois11 = 'mois_11';
  static const String mois12 = 'mois_12';
  
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Colonnes de la table plans_travail (PTBA)
class PlansTravailColumns {
  PlansTravailColumns._();

  static const String id = 'id';
  static const String projetId = 'projet_id';
  static const String type = 'type';
  static const String annee = 'annee';
  static const String trimestre = 'trimestre';
  static const String mois = 'mois';
  static const String dateDebut = 'date_debut';
  static const String dateFin = 'date_fin';
  static const String statut = 'statut';
  static const String valideParId = 'valide_par_id';
  static const String dateValidation = 'date_validation';
  static const String budgetTotal = 'budget_total';
  static const String budgetEtat = 'budget_etat';
  static const String budgetPtf = 'budget_ptf';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
