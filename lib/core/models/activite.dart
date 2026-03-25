/// Modèle pour une activité de projet
class Activite {
  final int? id;
  final int projetId;
  final int? planTravailId;
  final List<int> cadreLogiqueIds;
  final String codeActivite;
  final String intitule;
  final String? description;
  final String? typeActivite;
  final PrioriteActivite priorite;
  final DateTime dateDebutPrevue;
  final DateTime dateFinPrevue;
  final DateTime? dateDebutReelle;
  final DateTime? dateFinReelle;
  final int? responsableId;
  final List<int> zoneIds;
  final List<int> communeIds;
  final StatutActivite statut;
  final int pourcentageAvancement;
  final double budgetEstime;
  final double budgetEtat; // PTBA
  final double budgetPtf;  // PTBA
  final double budgetEngage;
  final double budgetRealise;
  final int nombreBeneficiairesCibles;
  final int nombreBeneficiairesAtteints;
  final String? livrables; // Deprecated, use JalonsLivrables
  final String? indicateursReussite;
  final String? risques;
  final String? observations;
  final String? lieu;
  final List<int> agentIds;
  // Planification mensuelle PTBA
  final bool mois1;
  final bool mois2;
  final bool mois3;
  final bool mois4;
  final bool mois5;
  final bool mois6;
  final bool mois7;
  final bool mois8;
  final bool mois9;
  final bool mois10;
  final bool mois11;
  final bool mois12;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activite({
    this.id,
    required this.projetId,
    this.planTravailId,
    this.cadreLogiqueIds = const [],
    required this.codeActivite,
    required this.intitule,
    this.description,
    this.typeActivite,
    this.priorite = PrioriteActivite.moyenne,
    required this.dateDebutPrevue,
    required this.dateFinPrevue,
    this.dateDebutReelle,
    this.dateFinReelle,
    this.responsableId,
    this.zoneIds = const [],
    this.communeIds = const [],
    this.statut = StatutActivite.planifiee,
    this.pourcentageAvancement = 0,
    this.budgetEstime = 0,
    this.budgetEtat = 0,
    this.budgetPtf = 0,
    this.budgetEngage = 0,
    this.budgetRealise = 0,
    this.nombreBeneficiairesCibles = 0,
    this.nombreBeneficiairesAtteints = 0,
    this.livrables,
    this.indicateursReussite,
    this.risques,
    this.observations,
    this.lieu,
    this.agentIds = const [],
    this.mois1 = false,
    this.mois2 = false,
    this.mois3 = false,
    this.mois4 = false,
    this.mois5 = false,
    this.mois6 = false,
    this.mois7 = false,
    this.mois8 = false,
    this.mois9 = false,
    this.mois10 = false,
    this.mois11 = false,
    this.mois12 = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'plan_travail_id': planTravailId,
      // cadre_logique_ids est géré par une table d'association
      'code_activite': codeActivite,
      'intitule': intitule,
      'description': description,
      'type_activite': typeActivite,
      'priorite': priorite.name,
      'date_debut_prevue': dateDebutPrevue.toIso8601String(),
      'date_fin_prevue': dateFinPrevue.toIso8601String(),
      'date_debut_reelle': dateDebutReelle?.toIso8601String(),
      'date_fin_reelle': dateFinReelle?.toIso8601String(),
      'responsable_id': responsableId,
      // zone_ids est géré par une table d'association
      'statut': statut.name,
      'pourcentage_avancement': pourcentageAvancement,
      'budget_estime': budgetEstime,
      'budget_etat': budgetEtat,
      'budget_ptf': budgetPtf,
      'budget_engage': budgetEngage,
      'budget_realise': budgetRealise,
      'nombre_beneficiaires_cibles': nombreBeneficiairesCibles,
      'nombre_beneficiaires_atteints': nombreBeneficiairesAtteints,
      'livrables': livrables,
      'indicateurs_reussite': indicateursReussite,
      'risques': risques,
      'observations': observations,
      'lieu': lieu,
      // Boolean to 0/1 for SQLite
      'mois_1': mois1 ? 1 : 0,
      'mois_2': mois2 ? 1 : 0,
      'mois_3': mois3 ? 1 : 0,
      'mois_4': mois4 ? 1 : 0,
      'mois_5': mois5 ? 1 : 0,
      'mois_6': mois6 ? 1 : 0,
      'mois_7': mois7 ? 1 : 0,
      'mois_8': mois8 ? 1 : 0,
      'mois_9': mois9 ? 1 : 0,
      'mois_10': mois10 ? 1 : 0,
      'mois_11': mois11 ? 1 : 0,
      'mois_12': mois12 ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Activite.fromMap(Map<String, dynamic> map) {
    return Activite(
      id: map['id'] as int?,
      projetId: map['projet_id'] as int,
      planTravailId: map['plan_travail_id'] as int?,
      cadreLogiqueIds: (map['cadre_logique_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      codeActivite: map['code_activite'] as String,
      intitule: map['intitule'] as String,
      description: map['description'] as String?,
      typeActivite: map['type_activite'] as String?,
      priorite: PrioriteActivite.values.firstWhere(
        (e) => e.name == map['priorite'],
        orElse: () => PrioriteActivite.moyenne,
      ),
      dateDebutPrevue: DateTime.parse(map['date_debut_prevue'] as String),
      dateFinPrevue: DateTime.parse(map['date_fin_prevue'] as String),
      dateDebutReelle: map['date_debut_reelle'] != null
          ? DateTime.parse(map['date_debut_reelle'] as String)
          : null,
      dateFinReelle: map['date_fin_reelle'] != null
          ? DateTime.parse(map['date_fin_reelle'] as String)
          : null,
      responsableId: map['responsable_id'] as int?,
      zoneIds: (map['zone_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      communeIds: (map['commune_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      statut: StatutActivite.values.firstWhere(
        (e) => e.name == map['statut'],
        orElse: () => StatutActivite.planifiee,
      ),
      pourcentageAvancement: map['pourcentage_avancement'] as int? ?? 0,
      budgetEstime: (map['budget_estime'] as num?)?.toDouble() ?? 0,
      budgetEtat: (map['budget_etat'] as num?)?.toDouble() ?? 0,
      budgetPtf: (map['budget_ptf'] as num?)?.toDouble() ?? 0,
      budgetEngage: (map['budget_engage'] as num?)?.toDouble() ?? 0,
      budgetRealise: (map['budget_realise'] as num?)?.toDouble() ?? 0,
      nombreBeneficiairesCibles:
          map['nombre_beneficiaires_cibles'] as int? ?? 0,
      nombreBeneficiairesAtteints:
          map['nombre_beneficiaires_atteints'] as int? ?? 0,
      livrables: map['livrables'] as String?,
      indicateursReussite: map['indicateurs_reussite'] as String?,
      risques: map['risques'] as String?,
      observations: map['observations'] as String?,
      lieu: map['lieu'] as String?,
      // Handle integer from SQLite back to booleans
      mois1: (map['mois_1'] as int? ?? 0) == 1,
      mois2: (map['mois_2'] as int? ?? 0) == 1,
      mois3: (map['mois_3'] as int? ?? 0) == 1,
      mois4: (map['mois_4'] as int? ?? 0) == 1,
      mois5: (map['mois_5'] as int? ?? 0) == 1,
      mois6: (map['mois_6'] as int? ?? 0) == 1,
      mois7: (map['mois_7'] as int? ?? 0) == 1,
      mois8: (map['mois_8'] as int? ?? 0) == 1,
      mois9: (map['mois_9'] as int? ?? 0) == 1,
      mois10: (map['mois_10'] as int? ?? 0) == 1,
      mois11: (map['mois_11'] as int? ?? 0) == 1,
      mois12: (map['mois_12'] as int? ?? 0) == 1,
      agentIds: map['agent_ids'] != null 
          ? List<int>.from(map['agent_ids']) 
          : (map['responsable_id'] != null ? [map['responsable_id'] as int] : []),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Créer une copie avec modifications
  Activite copyWith({
    int? id,
    int? projetId,
    int? planTravailId,
    List<int>? cadreLogiqueIds,
    String? codeActivite,
    String? intitule,
    String? description,
    String? typeActivite,
    PrioriteActivite? priorite,
    DateTime? dateDebutPrevue,
    DateTime? dateFinPrevue,
    DateTime? dateDebutReelle,
    DateTime? dateFinReelle,
    int? responsableId,
    List<int>? zoneIds,
    List<int>? communeIds,
    StatutActivite? statut,
    int? pourcentageAvancement,
    double? budgetEstime,
    double? budgetEtat,
    double? budgetPtf,
    double? budgetEngage,
    double? budgetRealise,
    int? nombreBeneficiairesCibles,
    int? nombreBeneficiairesAtteints,
    bool? mois1,
    bool? mois2,
    bool? mois3,
    bool? mois4,
    bool? mois5,
    bool? mois6,
    bool? mois7,
    bool? mois8,
    bool? mois9,
    bool? mois10,
    bool? mois11,
    bool? mois12,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activite(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      planTravailId: planTravailId ?? this.planTravailId,
      cadreLogiqueIds: cadreLogiqueIds ?? this.cadreLogiqueIds,
      codeActivite: codeActivite ?? this.codeActivite,
      intitule: intitule ?? this.intitule,
      description: description ?? this.description,
      typeActivite: typeActivite ?? this.typeActivite,
      priorite: priorite ?? this.priorite,
      dateDebutPrevue: dateDebutPrevue ?? this.dateDebutPrevue,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
      dateDebutReelle: dateDebutReelle ?? this.dateDebutReelle,
      dateFinReelle: dateFinReelle ?? this.dateFinReelle,
      responsableId: responsableId ?? this.responsableId,
      zoneIds: zoneIds ?? this.zoneIds,
      communeIds: communeIds ?? this.communeIds,
      statut: statut ?? this.statut,
      pourcentageAvancement:
          pourcentageAvancement ?? this.pourcentageAvancement,
      budgetEstime: budgetEstime ?? this.budgetEstime,
      budgetEtat: budgetEtat ?? this.budgetEtat,
      budgetPtf: budgetPtf ?? this.budgetPtf,
      budgetEngage: budgetEngage ?? this.budgetEngage,
      budgetRealise: budgetRealise ?? this.budgetRealise,
      nombreBeneficiairesCibles:
          nombreBeneficiairesCibles ?? this.nombreBeneficiairesCibles,
      nombreBeneficiairesAtteints:
          nombreBeneficiairesAtteints ?? this.nombreBeneficiairesAtteints,
      mois1: mois1 ?? this.mois1,
      mois2: mois2 ?? this.mois2,
      mois3: mois3 ?? this.mois3,
      mois4: mois4 ?? this.mois4,
      mois5: mois5 ?? this.mois5,
      mois6: mois6 ?? this.mois6,
      mois7: mois7 ?? this.mois7,
      mois8: mois8 ?? this.mois8,
      mois9: mois9 ?? this.mois9,
      mois10: mois10 ?? this.mois10,
      mois11: mois11 ?? this.mois11,
      mois12: mois12 ?? this.mois12,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Durée prévue en jours
  int get dureePrevueJours {
    return dateFinPrevue.difference(dateDebutPrevue).inDays;
  }

  /// Vérifier si l'activité est en retard
  bool get estEnRetard {
    final now = DateTime.now();
    return now.isAfter(dateFinPrevue) && statut != StatutActivite.terminee;
  }

  /// Taux d'exécution budgétaire
  double get tauxExecutionBudget {
    if (budgetEstime == 0) return 0.0;
    return (budgetRealise / budgetEstime * 100).clamp(0.0, 100.0);
  }

  /// Taux d'atteinte des bénéficiaires
  double get tauxAtteinteBeneficiaires {
    if (nombreBeneficiairesCibles == 0) return 0.0;
    return (nombreBeneficiairesAtteints / nombreBeneficiairesCibles * 100)
        .clamp(0.0, 100.0);
  }

  @override
  String toString() {
    return 'Activite(id: $id, code: $codeActivite, intitule: $intitule, statut: ${statut.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Activite &&
        other.id == id &&
        other.codeActivite == codeActivite;
  }

  @override
  int get hashCode => Object.hash(id, codeActivite);
}

/// Priorité d'une activité
enum PrioriteActivite {
  haute,
  moyenne,
  basse;

  String get label {
    switch (this) {
      case PrioriteActivite.haute:
        return 'Haute';
      case PrioriteActivite.moyenne:
        return 'Moyenne';
      case PrioriteActivite.basse:
        return 'Basse';
    }
  }

  String get colorHex {
    switch (this) {
      case PrioriteActivite.haute:
        return '#F44336'; // Red
      case PrioriteActivite.moyenne:
        return '#FF9800'; // Orange
      case PrioriteActivite.basse:
        return '#4CAF50'; // Green
    }
  }
}

/// Statut d'une activité
enum StatutActivite {
  planifiee,
  enCours,
  terminee,
  retard,
  annulee;

  String get label {
    switch (this) {
      case StatutActivite.planifiee:
        return 'Planifiée';
      case StatutActivite.enCours:
        return 'En cours';
      case StatutActivite.terminee:
        return 'Terminée';
      case StatutActivite.retard:
        return 'En retard';
      case StatutActivite.annulee:
        return 'Annulée';
    }
  }

  String get colorHex {
    switch (this) {
      case StatutActivite.planifiee:
        return '#9E9E9E'; // Grey
      case StatutActivite.enCours:
        return '#2196F3'; // Blue
      case StatutActivite.terminee:
        return '#4CAF50'; // Green
      case StatutActivite.retard:
        return '#F44336'; // Red
      case StatutActivite.annulee:
        return '#607D8B'; // Blue Grey
    }
  }
}
