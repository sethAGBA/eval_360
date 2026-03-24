/// Modèle pour une donnée de collecte (mesure d'un indicateur)
class DonneeCollecte {
  final int? id;
  final int indicateurId;
  final DateTime dateCollecte;
  final double valeurMesuree;
  final double? valeurDesagregeeH;
  final double? valeurDesagregeeF;
  final double? valeurDesagregee0_18;
  final double? valeurDesagregee19_35;
  final double? valeurDesagregee36Plus;
  final int? zoneId;
  final String? methodeUtilisee;
  final String? sourceVerification;
  final String? commentaireQualitatif;
  final double? latitude;
  final double? longitude;
  final int? collecteParId;
  final bool valide;
  final int? valideParId;
  final DateTime? dateValidation;
  final String? piecesJustificatives;
  final DateTime createdAt;

  const DonneeCollecte({
    this.id,
    required this.indicateurId,
    required this.dateCollecte,
    required this.valeurMesuree,
    this.valeurDesagregeeH,
    this.valeurDesagregeeF,
    this.valeurDesagregee0_18,
    this.valeurDesagregee19_35,
    this.valeurDesagregee36Plus,
    this.zoneId,
    this.methodeUtilisee,
    this.sourceVerification,
    this.commentaireQualitatif,
    this.latitude,
    this.longitude,
    this.collecteParId,
    this.valide = false,
    this.valideParId,
    this.dateValidation,
    this.piecesJustificatives,
    required this.createdAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'indicateur_id': indicateurId,
      'date_collecte': dateCollecte.toIso8601String(),
      'valeur_mesuree': valeurMesuree,
      'valeur_desagregee_h': valeurDesagregeeH,
      'valeur_desagregee_f': valeurDesagregeeF,
      'valeur_desagregee_0_18': valeurDesagregee0_18,
      'valeur_desagregee_19_35': valeurDesagregee19_35,
      'valeur_desagregee_36_plus': valeurDesagregee36Plus,
      'zone_id': zoneId,
      'methode_utilisee': methodeUtilisee,
      'source_verification': sourceVerification,
      'commentaire_qualitatif': commentaireQualitatif,
      'latitude': latitude,
      'longitude': longitude,
      'collecte_par_id': collecteParId,
      'valide': valide ? 1 : 0,
      'valide_par_id': valideParId,
      'date_validation': dateValidation?.toIso8601String(),
      'pieces_justificatives': piecesJustificatives,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory DonneeCollecte.fromMap(Map<String, dynamic> map) {
    return DonneeCollecte(
      id: map['id'] as int?,
      indicateurId: map['indicateur_id'] as int,
      dateCollecte: DateTime.parse(map['date_collecte'] as String),
      valeurMesuree: (map['valeur_mesuree'] as num).toDouble(),
      valeurDesagregeeH: (map['valeur_desagregee_h'] as num?)?.toDouble(),
      valeurDesagregeeF: (map['valeur_desagregee_f'] as num?)?.toDouble(),
      valeurDesagregee0_18: (map['valeur_desagregee_0_18'] as num?)?.toDouble(),
      valeurDesagregee19_35: (map['valeur_desagregee_19_35'] as num?)
          ?.toDouble(),
      valeurDesagregee36Plus: (map['valeur_desagregee_36_plus'] as num?)
          ?.toDouble(),
      zoneId: map['zone_id'] as int?,
      methodeUtilisee: map['methode_utilisee'] as String?,
      sourceVerification: map['source_verification'] as String?,
      commentaireQualitatif: map['commentaire_qualitatif'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      collecteParId: map['collecte_par_id'] as int?,
      valide: map['valide'] == 1,
      valideParId: map['valide_par_id'] as int?,
      dateValidation: map['date_validation'] != null
          ? DateTime.parse(map['date_validation'] as String)
          : null,
      piecesJustificatives: map['pieces_justificatives'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  DonneeCollecte copyWith({
    int? id,
    int? indicateurId,
    DateTime? dateCollecte,
    double? valeurMesuree,
    double? valeurDesagregeeH,
    double? valeurDesagregeeF,
    double? valeurDesagregee0_18,
    double? valeurDesagregee19_35,
    double? valeurDesagregee36Plus,
    int? zoneId,
    String? methodeUtilisee,
    String? sourceVerification,
    String? commentaireQualitatif,
    double? latitude,
    double? longitude,
    int? collecteParId,
    bool? valide,
    int? valideParId,
    DateTime? dateValidation,
    String? piecesJustificatives,
    DateTime? createdAt,
  }) {
    return DonneeCollecte(
      id: id ?? this.id,
      indicateurId: indicateurId ?? this.indicateurId,
      dateCollecte: dateCollecte ?? this.dateCollecte,
      valeurMesuree: valeurMesuree ?? this.valeurMesuree,
      valeurDesagregeeH: valeurDesagregeeH ?? this.valeurDesagregeeH,
      valeurDesagregeeF: valeurDesagregeeF ?? this.valeurDesagregeeF,
      valeurDesagregee0_18: valeurDesagregee0_18 ?? this.valeurDesagregee0_18,
      valeurDesagregee19_35:
          valeurDesagregee19_35 ?? this.valeurDesagregee19_35,
      valeurDesagregee36Plus:
          valeurDesagregee36Plus ?? this.valeurDesagregee36Plus,
      zoneId: zoneId ?? this.zoneId,
      methodeUtilisee: methodeUtilisee ?? this.methodeUtilisee,
      sourceVerification: sourceVerification ?? this.sourceVerification,
      commentaireQualitatif:
          commentaireQualitatif ?? this.commentaireQualitatif,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      collecteParId: collecteParId ?? this.collecteParId,
      valide: valide ?? this.valide,
      valideParId: valideParId ?? this.valideParId,
      dateValidation: dateValidation ?? this.dateValidation,
      piecesJustificatives: piecesJustificatives ?? this.piecesJustificatives,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
