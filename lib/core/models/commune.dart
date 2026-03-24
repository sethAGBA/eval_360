/// Modèle pour une Commune du Togo
class Commune {
  final int? id;
  final String nom;
  final String region; // Maritime, Plateaux, Centrale, Kara, Savanes
  final String prefecture;
  final double tauxAvancementPdc; // Taux d'avancement du Plan de Développement Communal
  final String? contactMaire;
  final DateTime? dateDerniereMiseAJour;

  const Commune({
    this.id,
    required this.nom,
    required this.region,
    required this.prefecture,
    this.tauxAvancementPdc = 0.0,
    this.contactMaire,
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
      dateDerniereMiseAJour: map['date_maj'] != null ? DateTime.parse(map['date_maj'] as String) : null,
    );
  }
}
