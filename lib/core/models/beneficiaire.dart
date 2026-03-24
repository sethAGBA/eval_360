/// Modèle de données pour un bénéficiaire de projet
class Beneficiaire {
  final int? id;
  final int projetId;
  final BeneficiaireType type;
  final String groupeCible;
  final int nombrePrevu;
  final int nombreAtteint;
  final String? criteresSelection;
  final int repartitionSexeH;
  final int repartitionSexeF;
  final int repartitionAge0_18;
  final int repartitionAge19_35;
  final int repartitionAge36Plus;
  final int? zoneId;

  const Beneficiaire({
    this.id,
    required this.projetId,
    required this.type,
    required this.groupeCible,
    this.nombrePrevu = 0,
    this.nombreAtteint = 0,
    this.criteresSelection,
    this.repartitionSexeH = 0,
    this.repartitionSexeF = 0,
    this.repartitionAge0_18 = 0,
    this.repartitionAge19_35 = 0,
    this.repartitionAge36Plus = 0,
    this.zoneId,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'type': type.name,
      'groupe_cible': groupeCible,
      'nombre_prevu': nombrePrevu,
      'nombre_atteint': nombreAtteint,
      'criteres_selection': criteresSelection,
      'repartition_sexe_h': repartitionSexeH,
      'repartition_sexe_f': repartitionSexeF,
      'repartition_age_0_18': repartitionAge0_18,
      'repartition_age_19_35': repartitionAge19_35,
      'repartition_age_36_plus': repartitionAge36Plus,
      'zone_id': zoneId,
    };
  }

  /// Créer depuis Map de la base de données
  factory Beneficiaire.fromMap(Map<String, dynamic> map) {
    return Beneficiaire(
      id: map['id'] as int?,
      projetId: map['projet_id'] as int,
      type: BeneficiaireType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BeneficiaireType.direct,
      ),
      groupeCible: map['groupe_cible'] as String,
      nombrePrevu: map['nombre_prevu'] as int? ?? 0,
      nombreAtteint: map['nombre_atteint'] as int? ?? 0,
      criteresSelection: map['criteres_selection'] as String?,
      repartitionSexeH: map['repartition_sexe_h'] as int? ?? 0,
      repartitionSexeF: map['repartition_sexe_f'] as int? ?? 0,
      repartitionAge0_18: map['repartition_age_0_18'] as int? ?? 0,
      repartitionAge19_35: map['repartition_age_19_35'] as int? ?? 0,
      repartitionAge36Plus: map['repartition_age_36_plus'] as int? ?? 0,
      zoneId: map['zone_id'] as int?,
    );
  }

  /// Créer une copie avec modifications
  Beneficiaire copyWith({
    int? id,
    int? projetId,
    BeneficiaireType? type,
    String? groupeCible,
    int? nombrePrevu,
    int? nombreAtteint,
    String? criteresSelection,
    int? repartitionSexeH,
    int? repartitionSexeF,
    int? repartitionAge0_18,
    int? repartitionAge19_35,
    int? repartitionAge36Plus,
    int? zoneId,
  }) {
    return Beneficiaire(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      type: type ?? this.type,
      groupeCible: groupeCible ?? this.groupeCible,
      nombrePrevu: nombrePrevu ?? this.nombrePrevu,
      nombreAtteint: nombreAtteint ?? this.nombreAtteint,
      criteresSelection: criteresSelection ?? this.criteresSelection,
      repartitionSexeH: repartitionSexeH ?? this.repartitionSexeH,
      repartitionSexeF: repartitionSexeF ?? this.repartitionSexeF,
      repartitionAge0_18: repartitionAge0_18 ?? this.repartitionAge0_18,
      repartitionAge19_35: repartitionAge19_35 ?? this.repartitionAge19_35,
      repartitionAge36Plus: repartitionAge36Plus ?? this.repartitionAge36Plus,
      zoneId: zoneId ?? this.zoneId,
    );
  }

  /// Nombre total de bénéficiaires prévus
  int get totalPrevu => nombrePrevu;

  /// Nombre total de bénéficiaires atteints
  int get totalAtteint => nombreAtteint;

  /// Pourcentage d'atteinte de la cible
  double get tauxAtteinte {
    if (nombrePrevu == 0) return 0.0;
    return (nombreAtteint / nombrePrevu * 100).clamp(0.0, 100.0);
  }

  /// Total de la répartition par sexe
  int get totalSexe => repartitionSexeH + repartitionSexeF;

  /// Pourcentage hommes
  double get pourcentageHommes {
    if (totalSexe == 0) return 0.0;
    return (repartitionSexeH / totalSexe * 100);
  }

  /// Pourcentage femmes
  double get pourcentageFemmes {
    if (totalSexe == 0) return 0.0;
    return (repartitionSexeF / totalSexe * 100);
  }

  /// Total de la répartition par âge
  int get totalAge =>
      repartitionAge0_18 + repartitionAge19_35 + repartitionAge36Plus;

  @override
  String toString() {
    return 'Beneficiaire(id: $id, type: ${type.label}, groupe: $groupeCible, atteint: $nombreAtteint/$nombrePrevu)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Beneficiaire &&
        other.id == id &&
        other.projetId == projetId &&
        other.groupeCible == groupeCible;
  }

  @override
  int get hashCode => Object.hash(id, projetId, groupeCible);
}

/// Type de bénéficiaire
enum BeneficiaireType {
  /// Bénéficiaires directs du projet
  direct,

  /// Bénéficiaires indirects
  indirect;

  /// Label lisible du type
  String get label {
    switch (this) {
      case BeneficiaireType.direct:
        return 'Direct';
      case BeneficiaireType.indirect:
        return 'Indirect';
    }
  }
}
