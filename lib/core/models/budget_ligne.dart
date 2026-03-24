/// Modèle pour une ligne budgétaire de projet
class BudgetLigne {
  final int? id;
  final int projetId;
  final int? bailleurId;
  final String codeLigne;
  final String libelle;
  final String categorie;
  final double budgetInitial;
  final double reallocations;
  final double budgetRevise;
  final int annee;
  final int? trimestre;
  final int? cadreLogiqueId;
  final int? zoneId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetLigne({
    this.id,
    required this.projetId,
    this.bailleurId,
    required this.codeLigne,
    required this.libelle,
    required this.categorie,
    required this.budgetInitial,
    this.reallocations = 0.0,
    required this.budgetRevise,
    required this.annee,
    this.trimestre,
    this.cadreLogiqueId,
    this.zoneId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'bailleur_id': bailleurId,
      'code_ligne': codeLigne,
      'libelle': libelle,
      'categorie': categorie,
      'budget_initial': budgetInitial,
      'reallocations': reallocations,
      'budget_revise': budgetRevise,
      'annee': annee,
      'trimestre': trimestre,
      'cadre_logique_id': cadreLogiqueId,
      'zone_id': zoneId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory BudgetLigne.fromMap(Map<String, dynamic> map) {
    return BudgetLigne(
      id: map['id'] as int?,
      projetId: map['projet_id'] as int,
      bailleurId: map['bailleur_id'] as int?,
      codeLigne: map['code_ligne'] as String,
      libelle: map['libelle'] as String,
      categorie: map['categorie'] as String,
      budgetInitial: (map['budget_initial'] as num).toDouble(),
      reallocations: (map['reallocations'] as num? ?? 0.0).toDouble(),
      budgetRevise: (map['budget_revise'] as num).toDouble(),
      annee: map['annee'] as int,
      trimestre: map['trimestre'] as int?,
      cadreLogiqueId: map['cadre_logique_id'] as int?,
      zoneId: map['zone_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Créer une copie avec modifications
  BudgetLigne copyWith({
    int? id,
    int? projetId,
    int? bailleurId,
    String? codeLigne,
    String? libelle,
    String? categorie,
    double? budgetInitial,
    double? reallocations,
    double? budgetRevise,
    int? annee,
    int? trimestre,
    int? cadreLogiqueId,
    int? zoneId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetLigne(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      bailleurId: bailleurId ?? this.bailleurId,
      codeLigne: codeLigne ?? this.codeLigne,
      libelle: libelle ?? this.libelle,
      categorie: categorie ?? this.categorie,
      budgetInitial: budgetInitial ?? this.budgetInitial,
      reallocations: reallocations ?? this.reallocations,
      budgetRevise: budgetRevise ?? this.budgetRevise,
      annee: annee ?? this.annee,
      trimestre: trimestre ?? this.trimestre,
      cadreLogiqueId: cadreLogiqueId ?? this.cadreLogiqueId,
      zoneId: zoneId ?? this.zoneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BudgetLigne(id: $id, code: $codeLigne, libelle: $libelle, total: $budgetRevise)';
  }
}
