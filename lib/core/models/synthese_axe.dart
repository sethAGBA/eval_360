/// Modèle pour la synthèse par axe d'un rapport mensuel
class SyntheseAxe {
  final int? id;
  final int rapportMensuelId;
  final int? axeId;
  final String libelleAxe;
  final double tauxRealisation;
  final int nombreActivitesPrevues;
  final int nombreActivitesRealisees;

  const SyntheseAxe({
    this.id,
    required this.rapportMensuelId,
    this.axeId,
    required this.libelleAxe,
    this.tauxRealisation = 0.0,
    this.nombreActivitesPrevues = 0,
    this.nombreActivitesRealisees = 0,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'rapport_mensuel_id': rapportMensuelId,
      'axe_id': axeId,
      'libelle_axe': libelleAxe,
      'taux_realisation': tauxRealisation,
      'nombre_activites_prevues': nombreActivitesPrevues,
      'nombre_activites_realisees': nombreActivitesRealisees,
    };
  }

  /// Créer depuis Map de la base de données
  factory SyntheseAxe.fromMap(Map<String, dynamic> map) {
    return SyntheseAxe(
      id: map['id'] as int?,
      rapportMensuelId: map['rapport_mensuel_id'] as int,
      axeId: map['axe_id'] as int?,
      libelleAxe: map['libelle_axe'] as String,
      tauxRealisation: (map['taux_realisation'] as num?)?.toDouble() ?? 0.0,
      nombreActivitesPrevues: map['nombre_activites_prevues'] as int? ?? 0,
      nombreActivitesRealisees: map['nombre_activites_realisees'] as int? ?? 0,
    );
  }

  /// Créer une copie avec modifications
  SyntheseAxe copyWith({
    int? id,
    int? rapportMensuelId,
    int? axeId,
    String? libelleAxe,
    double? tauxRealisation,
    int? nombreActivitesPrevues,
    int? nombreActivitesRealisees,
  }) {
    return SyntheseAxe(
      id: id ?? this.id,
      rapportMensuelId: rapportMensuelId ?? this.rapportMensuelId,
      axeId: axeId ?? this.axeId,
      libelleAxe: libelleAxe ?? this.libelleAxe,
      tauxRealisation: tauxRealisation ?? this.tauxRealisation,
      nombreActivitesPrevues: nombreActivitesPrevues ?? this.nombreActivitesPrevues,
      nombreActivitesRealisees: nombreActivitesRealisees ?? this.nombreActivitesRealisees,
    );
  }
}
