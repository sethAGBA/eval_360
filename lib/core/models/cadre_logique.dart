/// Modèle pour un élément du cadre logique
class CadreLogique {
  final int? id;
  final int projetId;
  final NiveauCadreLogique niveau;
  final String code;
  final String libelle;
  final String? description;
  final int? parentId;
  final int ordre;
  final String? hypothesesRisques;
  final String? moyensVerification;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CadreLogique({
    this.id,
    required this.projetId,
    required this.niveau,
    required this.code,
    required this.libelle,
    this.description,
    this.parentId,
    this.ordre = 0,
    this.hypothesesRisques,
    this.moyensVerification,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'niveau': niveau.name,
      'code': code,
      'libelle': libelle,
      'description': description,
      'parent_id': parentId,
      'ordre': ordre,
      'hypotheses_risques': hypothesesRisques,
      'moyens_verification': moyensVerification,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory CadreLogique.fromMap(Map<String, dynamic> map) {
    return CadreLogique(
      id: map['id'] as int?,
      projetId: map['projet_id'] as int,
      niveau: NiveauCadreLogique.values.firstWhere(
        (e) => e.name == map['niveau'],
        orElse: () => NiveauCadreLogique.activite,
      ),
      code: map['code'] as String,
      libelle: map['libelle'] as String,
      description: map['description'] as String?,
      parentId: map['parent_id'] as int?,
      ordre: map['ordre'] as int? ?? 0,
      hypothesesRisques: map['hypotheses_risques'] as String?,
      moyensVerification: map['moyens_verification'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Créer une copie avec modifications
  CadreLogique copyWith({
    int? id,
    int? projetId,
    NiveauCadreLogique? niveau,
    String? code,
    String? libelle,
    String? description,
    int? parentId,
    int? ordre,
    String? hypothesesRisques,
    String? moyensVerification,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CadreLogique(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      niveau: niveau ?? this.niveau,
      code: code ?? this.code,
      libelle: libelle ?? this.libelle,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      ordre: ordre ?? this.ordre,
      hypothesesRisques: hypothesesRisques ?? this.hypothesesRisques,
      moyensVerification: moyensVerification ?? this.moyensVerification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Vérifier si c'est un élément racine (sans parent)
  bool get isRoot => parentId == null;

  @override
  String toString() {
    return 'CadreLogique(id: $id, niveau: ${niveau.label}, code: $code, libelle: $libelle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CadreLogique && other.id == id && other.code == code;
  }

  @override
  int get hashCode => Object.hash(id, code);
}

/// Niveaux du cadre logique
enum NiveauCadreLogique {
  /// Impact global du projet
  impact,

  /// Résultats attendus (outcomes)
  outcome,

  /// Produits livrables (outputs)
  output,

  /// Activités à réaliser
  activite;

  /// Label lisible du niveau
  String get label {
    switch (this) {
      case NiveauCadreLogique.impact:
        return 'Impact';
      case NiveauCadreLogique.outcome:
        return 'Résultat (Outcome)';
      case NiveauCadreLogique.output:
        return 'Produit (Output)';
      case NiveauCadreLogique.activite:
        return 'Activité';
    }
  }

  /// Description du niveau
  String get description {
    switch (this) {
      case NiveauCadreLogique.impact:
        return 'Changement à long terme visé par le projet';
      case NiveauCadreLogique.outcome:
        return 'Changements de comportement ou de pratiques';
      case NiveauCadreLogique.output:
        return 'Produits et services livrés par le projet';
      case NiveauCadreLogique.activite:
        return 'Actions concrètes à réaliser';
    }
  }

  /// Couleur associée au niveau
  String get colorHex {
    switch (this) {
      case NiveauCadreLogique.impact:
        return '#9C27B0'; // Purple
      case NiveauCadreLogique.outcome:
        return '#2196F3'; // Blue
      case NiveauCadreLogique.output:
        return '#4CAF50'; // Green
      case NiveauCadreLogique.activite:
        return '#FF9800'; // Orange
    }
  }
}
