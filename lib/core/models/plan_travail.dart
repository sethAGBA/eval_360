import '../database/database_tables.dart';

/// Modèle de données pour un Plan de Travail Annuel (PTBA)
class PlanTravail {
  final int? id;
  final int projetId;
  final String type; // 'annuel', 'trimestriel', 'mensuel'
  final int annee;
  final int? trimestre; // 1-4 pour trimestriel
  final int? mois; // 1-12 pour mensuel
  final DateTime dateDebut;
  final DateTime dateFin;
  final StatutPTBA statut;
  final int? valideParId;
  final DateTime? dateValidation;
  final double budgetTotal;
  final double budgetEtat;
  final double budgetPtf;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlanTravail({
    this.id,
    required this.projetId,
    this.type = 'annuel',
    required this.annee,
    this.trimestre,
    this.mois,
    required this.dateDebut,
    required this.dateFin,
    this.statut = StatutPTBA.brouillon,
    this.valideParId,
    this.dateValidation,
    this.budgetTotal = 0,
    this.budgetEtat = 0,
    this.budgetPtf = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) PlansTravailColumns.id: id,
      PlansTravailColumns.projetId: projetId,
      PlansTravailColumns.type: type,
      PlansTravailColumns.annee: annee,
      PlansTravailColumns.trimestre: trimestre,
      PlansTravailColumns.mois: mois,
      PlansTravailColumns.dateDebut: dateDebut.toIso8601String(),
      PlansTravailColumns.dateFin: dateFin.toIso8601String(),
      PlansTravailColumns.statut: statut.name,
      PlansTravailColumns.valideParId: valideParId,
      PlansTravailColumns.dateValidation: dateValidation?.toIso8601String(),
      PlansTravailColumns.budgetTotal: budgetTotal,
      PlansTravailColumns.budgetEtat: budgetEtat,
      PlansTravailColumns.budgetPtf: budgetPtf,
      PlansTravailColumns.createdAt: createdAt.toIso8601String(),
      PlansTravailColumns.updatedAt: updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory PlanTravail.fromMap(Map<String, dynamic> map) {
    return PlanTravail(
      id: map[PlansTravailColumns.id] as int?,
      projetId: map[PlansTravailColumns.projetId] as int,
      type: map[PlansTravailColumns.type] as String? ?? 'annuel',
      annee: map[PlansTravailColumns.annee] as int,
      trimestre: map[PlansTravailColumns.trimestre] as int?,
      mois: map[PlansTravailColumns.mois] as int?,
      dateDebut: DateTime.parse(map[PlansTravailColumns.dateDebut] as String),
      dateFin: DateTime.parse(map[PlansTravailColumns.dateFin] as String),
      statut: StatutPTBA.values.firstWhere(
        (e) => e.name == map[PlansTravailColumns.statut],
        orElse: () => StatutPTBA.brouillon,
      ),
      valideParId: map[PlansTravailColumns.valideParId] as int?,
      dateValidation: map[PlansTravailColumns.dateValidation] != null
          ? DateTime.parse(map[PlansTravailColumns.dateValidation] as String)
          : null,
      budgetTotal: (map[PlansTravailColumns.budgetTotal] as num?)?.toDouble() ?? 0,
      budgetEtat: (map[PlansTravailColumns.budgetEtat] as num?)?.toDouble() ?? 0,
      budgetPtf: (map[PlansTravailColumns.budgetPtf] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map[PlansTravailColumns.createdAt] as String),
      updatedAt: DateTime.parse(map[PlansTravailColumns.updatedAt] as String),
    );
  }

  /// Créer une copie avec modifications
  PlanTravail copyWith({
    int? id,
    int? projetId,
    String? type,
    int? annee,
    int? trimestre,
    int? mois,
    DateTime? dateDebut,
    DateTime? dateFin,
    StatutPTBA? statut,
    int? valideParId,
    DateTime? dateValidation,
    double? budgetTotal,
    double? budgetEtat,
    double? budgetPtf,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanTravail(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      type: type ?? this.type,
      annee: annee ?? this.annee,
      trimestre: trimestre ?? this.trimestre,
      mois: mois ?? this.mois,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      valideParId: valideParId ?? this.valideParId,
      dateValidation: dateValidation ?? this.dateValidation,
      budgetTotal: budgetTotal ?? this.budgetTotal,
      budgetEtat: budgetEtat ?? this.budgetEtat,
      budgetPtf: budgetPtf ?? this.budgetPtf,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Statut d'un Plan de Travail (PTBA)
enum StatutPTBA {
  brouillon,
  en_attente,
  valide,
  cloture;

  String get label {
    switch (this) {
      case StatutPTBA.brouillon:
        return 'Brouillon';
      case StatutPTBA.en_attente:
        return 'En attente de validation';
      case StatutPTBA.valide:
        return 'Validé';
      case StatutPTBA.cloture:
        return 'Clôturé';
    }
  }

  String get colorHex {
    switch (this) {
      case StatutPTBA.brouillon:
        return '#9E9E9E'; // Gris
      case StatutPTBA.en_attente:
        return '#FF9800'; // Orange
      case StatutPTBA.valide:
        return '#4CAF50'; // Vert
      case StatutPTBA.cloture:
        return '#F44336'; // Rouge
    }
  }
}
