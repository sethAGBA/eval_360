/// Modèle pour une Commune du Togo
class Commune {
  final int? id;
  final String nom;
  final String region; // Maritime, Plateaux, Centrale, Kara, Savanes
  final String prefecture;
  final double tauxAvancementPdc; // Taux d'avancement du Plan de Développement Communal
  final String? contactMaire;
  final String? contactEmail;
  final String? contactTelephone;
  final int? pdcPeriodeDebut;
  final int? pdcPeriodeFin;
  final String? pdcDocumentUrl;
  final String? description;
  final int? nbHabitants;
  final DateTime? dateDerniereMiseAJour;

  const Commune({
    this.id,
    required this.nom,
    required this.region,
    required this.prefecture,
    this.tauxAvancementPdc = 0.0,
    this.contactMaire,
    this.contactEmail,
    this.contactTelephone,
    this.pdcPeriodeDebut,
    this.pdcPeriodeFin,
    this.pdcDocumentUrl,
    this.description,
    this.nbHabitants,
    this.dateDerniereMiseAJour,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'region': region,
      'prefecture': prefecture,
      'taux_avancement_pdc': tauxAvancementPdc,
      'contact_maire': contactMaire,
      'contact_email': contactEmail,
      'contact_telephone': contactTelephone,
      'pdc_periode_debut': pdcPeriodeDebut,
      'pdc_periode_fin': pdcPeriodeFin,
      'pdc_document_url': pdcDocumentUrl,
      'description': description,
      'nb_habitants': nbHabitants,
      'date_maj': dateDerniereMiseAJour?.toIso8601String(),
    };
  }

  factory Commune.fromMap(Map<String, dynamic> map) {
    return Commune(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      region: map['region'] as String,
      prefecture: map['prefecture'] as String,
      tauxAvancementPdc: (map['taux_avancement_pdc'] as num? ?? 0.0).toDouble(),
      contactMaire: map['contact_maire'] as String?,
      contactEmail: map['contact_email'] as String?,
      contactTelephone: map['contact_telephone'] as String?,
      pdcPeriodeDebut: map['pdc_periode_debut'] as int?,
      pdcPeriodeFin: map['pdc_periode_fin'] as int?,
      pdcDocumentUrl: map['pdc_document_url'] as String?,
      description: map['description'] as String?,
      nbHabitants: map['nb_habitants'] as int?,
      dateDerniereMiseAJour: map['date_maj'] != null ? DateTime.parse(map['date_maj'] as String) : null,
    );
  }
}
