/// Modèle pour une activité de projet
class Activite {
  final int? id;
  final int projetId;
  final int? planTravailId;
  final int? cadreLogiqueId;
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
  final int? zoneId;
  final StatutActivite statut;
  final int pourcentageAvancement;
  final double budgetEstime;
  final double budgetEngage;
  final double budgetRealise;
  final int nombreBeneficiairesCibles;
  final int nombreBeneficiairesAtteints;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activite({
    this.id,
    required this.projetId,
    this.planTravailId,
    this.cadreLogiqueId,
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
    this.zoneId,
    this.statut = StatutActivite.planifiee,
    this.pourcentageAvancement = 0,
    this.budgetEstime = 0,
    this.budgetEngage = 0,
    this.budgetRealise = 0,
    this.nombreBeneficiairesCibles = 0,
    this.nombreBeneficiairesAtteints = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'plan_travail_id': planTravailId,
      'cadre_logique_id': cadreLogiqueId,
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
      'zone_id': zoneId,
      'statut': statut.name,
      'pourcentage_avancement': pourcentageAvancement,
      'budget_estime': budgetEstime,
      'budget_engage': budgetEngage,
      'budget_realise': budgetRealise,
      'nombre_beneficiaires_cibles': nombreBeneficiairesCibles,
      'nombre_beneficiaires_atteints': nombreBeneficiairesAtteints,
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
      cadreLogiqueId: map['cadre_logique_id'] as int?,
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
      zoneId: map['zone_id'] as int?,
      statut: StatutActivite.values.firstWhere(
        (e) => e.name == map['statut'],
        orElse: () => StatutActivite.planifiee,
      ),
      pourcentageAvancement: map['pourcentage_avancement'] as int? ?? 0,
      budgetEstime: (map['budget_estime'] as num?)?.toDouble() ?? 0,
      budgetEngage: (map['budget_engage'] as num?)?.toDouble() ?? 0,
      budgetRealise: (map['budget_realise'] as num?)?.toDouble() ?? 0,
      nombreBeneficiairesCibles:
          map['nombre_beneficiaires_cibles'] as int? ?? 0,
      nombreBeneficiairesAtteints:
          map['nombre_beneficiaires_atteints'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Créer une copie avec modifications
  Activite copyWith({
    int? id,
    int? projetId,
    int? planTravailId,
    int? cadreLogiqueId,
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
    int? zoneId,
    StatutActivite? statut,
    int? pourcentageAvancement,
    double? budgetEstime,
    double? budgetEngage,
    double? budgetRealise,
    int? nombreBeneficiairesCibles,
    int? nombreBeneficiairesAtteints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activite(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      planTravailId: planTravailId ?? this.planTravailId,
      cadreLogiqueId: cadreLogiqueId ?? this.cadreLogiqueId,
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
      zoneId: zoneId ?? this.zoneId,
      statut: statut ?? this.statut,
      pourcentageAvancement:
          pourcentageAvancement ?? this.pourcentageAvancement,
      budgetEstime: budgetEstime ?? this.budgetEstime,
      budgetEngage: budgetEngage ?? this.budgetEngage,
      budgetRealise: budgetRealise ?? this.budgetRealise,
      nombreBeneficiairesCibles:
          nombreBeneficiairesCibles ?? this.nombreBeneficiairesCibles,
      nombreBeneficiairesAtteints:
          nombreBeneficiairesAtteints ?? this.nombreBeneficiairesAtteints,
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
