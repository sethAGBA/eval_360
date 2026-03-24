import '../database/database_tables.dart';

/// Modèle de données pour un bailleur ou partenaire
class Bailleur {
  final int? id;
  final String nom;
  final BailleurType type;
  final String pays;
  final String? contactNom;
  final String? contactEmail;
  final String? contactTelephone;
  final String? adresse;
  final String? siteWeb;
  final DateTime createdAt;

  const Bailleur({
    this.id,
    required this.nom,
    required this.type,
    required this.pays,
    this.contactNom,
    this.contactEmail,
    this.contactTelephone,
    this.adresse,
    this.siteWeb,
    required this.createdAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) BailleursColumns.id: id,
      BailleursColumns.nom: nom,
      BailleursColumns.type: type.name,
      BailleursColumns.pays: pays,
      BailleursColumns.contactNom: contactNom,
      BailleursColumns.contactEmail: contactEmail,
      BailleursColumns.contactTelephone: contactTelephone,
      BailleursColumns.adresse: adresse,
      BailleursColumns.siteWeb: siteWeb,
      BailleursColumns.createdAt: createdAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Bailleur.fromMap(Map<String, dynamic> map) {
    return Bailleur(
      id: map[BailleursColumns.id] as int?,
      nom: map[BailleursColumns.nom] as String,
      type: BailleurType.values.firstWhere(
        (e) => e.name == map[BailleursColumns.type],
        orElse: () => BailleurType.bailleur,
      ),
      pays: map[BailleursColumns.pays] as String,
      contactNom: map[BailleursColumns.contactNom] as String?,
      contactEmail: map[BailleursColumns.contactEmail] as String?,
      contactTelephone: map[BailleursColumns.contactTelephone] as String?,
      adresse: map[BailleursColumns.adresse] as String?,
      siteWeb: map[BailleursColumns.siteWeb] as String?,
      createdAt: DateTime.parse(map[BailleursColumns.createdAt] as String),
    );
  }

  /// Créer une copie avec modifications
  Bailleur copyWith({
    int? id,
    String? nom,
    BailleurType? type,
    String? pays,
    String? contactNom,
    String? contactEmail,
    String? contactTelephone,
    String? adresse,
    String? siteWeb,
    DateTime? createdAt,
  }) {
    return Bailleur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      pays: pays ?? this.pays,
      contactNom: contactNom ?? this.contactNom,
      contactEmail: contactEmail ?? this.contactEmail,
      contactTelephone: contactTelephone ?? this.contactTelephone,
      adresse: adresse ?? this.adresse,
      siteWeb: siteWeb ?? this.siteWeb,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Bailleur(id: $id, nom: $nom, type: ${type.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Bailleur && other.id == id && other.nom == nom;
  }

  @override
  int get hashCode => Object.hash(id, nom);
}

/// Type de bailleur ou partenaire
enum BailleurType {
  /// Bailleur de fonds principal
  bailleur,

  /// Partenaire technique
  partenaire,

  /// Co-financeur
  coFinanceur;

  /// Label lisible du type
  String get label {
    switch (this) {
      case BailleurType.bailleur:
        return 'Bailleur';
      case BailleurType.partenaire:
        return 'Partenaire';
      case BailleurType.coFinanceur:
        return 'Co-financeur';
    }
  }
}

/// Liaison entre un projet et un bailleur
class ProjetBailleur {
  final int? id;
  final int projetId;
  final int bailleurId;
  final String role;
  final double montantContribution;
  final String devise;
  final DateTime? dateConvention;

  const ProjetBailleur({
    this.id,
    required this.projetId,
    required this.bailleurId,
    required this.role,
    required this.montantContribution,
    required this.devise,
    this.dateConvention,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'bailleur_id': bailleurId,
      'role': role,
      'montant_contribution': montantContribution,
      'devise': devise,
      'date_convention': dateConvention?.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory ProjetBailleur.fromMap(Map<String, dynamic> map) {
    return ProjetBailleur(
      id: map['id'] as int?,
      projetId: map['projet_id'] as int,
      bailleurId: map['bailleur_id'] as int,
      role: map['role'] as String,
      montantContribution: (map['montant_contribution'] as num).toDouble(),
      devise: map['devise'] as String,
      dateConvention: map['date_convention'] != null
          ? DateTime.parse(map['date_convention'] as String)
          : null,
    );
  }
}
