/// Type de partenaire
enum TypePartenaire {
  bilateral,
  multilateral,
  ong,
  secteurPrive,
  autre;

  String get label {
    switch (this) {
      case TypePartenaire.bilateral: return 'Bilatéral';
      case TypePartenaire.multilateral: return 'Multilatéral';
      case TypePartenaire.ong: return 'ONG';
      case TypePartenaire.secteurPrive: return 'Secteur Privé';
      case TypePartenaire.autre: return 'Autre';
    }
  }
}

/// Modèle pour un Partenaire Technique et Financier (PTF)
class Partenaire {
  final int? id;
  final String nom;
  final TypePartenaire type;
  final String? pays;
  final String? secteur;
  final String? contactNom;
  final String? contactEmail;
  final String? contactTelephone;
  final double? financementTotal;
  final String? description;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final bool actif;
  final DateTime createdAt;

  const Partenaire({
    this.id,
    required this.nom,
    required this.type,
    this.pays,
    this.secteur,
    this.contactNom,
    this.contactEmail,
    this.contactTelephone,
    this.financementTotal,
    this.description,
    this.dateDebut,
    this.dateFin,
    this.actif = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'type': type.name,
      'pays': pays,
      'secteur': secteur,
      'contact_nom': contactNom,
      'contact_email': contactEmail,
      'contact_telephone': contactTelephone,
      'financement_total': financementTotal,
      'description': description,
      'date_debut': dateDebut?.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'actif': actif ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Partenaire.fromMap(Map<String, dynamic> map) {
    return Partenaire(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      type: TypePartenaire.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TypePartenaire.autre,
      ),
      pays: map['pays'] as String?,
      secteur: map['secteur'] as String?,
      contactNom: map['contact_nom'] as String?,
      contactEmail: map['contact_email'] as String?,
      contactTelephone: map['contact_telephone'] as String?,
      financementTotal: (map['financement_total'] as num?)?.toDouble(),
      description: map['description'] as String?,
      dateDebut: map['date_debut'] != null ? DateTime.parse(map['date_debut'] as String) : null,
      dateFin: map['date_fin'] != null ? DateTime.parse(map['date_fin'] as String) : null,
      actif: (map['actif'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
