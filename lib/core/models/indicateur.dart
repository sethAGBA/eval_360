/// Modèle pour un indicateur de suivi et évaluation
class Indicateur {
  final int? id;
  final int projetId;
  final int? cadreLogiqueId;
  final String codeIndicateur;
  final String libelle;
  final String? definition;
  final NiveauIndicateur niveau;
  final TypeIndicateur type;
  final String? uniteMesure;
  final double? baseline;
  final double? cibleFinale;
  final FrequenceCollecte frequenceCollecte;
  final int? responsableCollecteId;
  final String? sourceDonnees;
  final String? methodeCollecte;
  final bool desagregationSexe;
  final bool desagregationAge;
  final bool desagregationZone;
  final double? seuilAlerteMin;
  final double? seuilAlerteMax;
  final double valeurActuelle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Indicateur({
    this.id,
    required this.projetId,
    this.cadreLogiqueId,
    required this.codeIndicateur,
    required this.libelle,
    this.definition,
    required this.niveau,
    required this.type,
    this.uniteMesure,
    this.baseline,
    this.cibleFinale,
    required this.frequenceCollecte,
    this.responsableCollecteId,
    this.sourceDonnees,
    this.methodeCollecte,
    this.desagregationSexe = false,
    this.desagregationAge = false,
    this.desagregationZone = false,
    this.seuilAlerteMin,
    this.seuilAlerteMax,
    this.valeurActuelle = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'projet_id': projetId,
      'cadre_logique_id': cadreLogiqueId,
      'code_indicateur': codeIndicateur,
      'libelle': libelle,
      'definition': definition,
      'niveau': niveau.name,
      'type': type.name,
      'unite_mesure': uniteMesure,
      'baseline': baseline,
      'cible_finale': cibleFinale,
      'frequence_collecte': frequenceCollecte.name,
      'responsable_collecte_id': responsableCollecteId,
      'source_donnees': sourceDonnees,
      'methode_collecte': methodeCollecte,
      'desagregation_sexe': desagregationSexe ? 1 : 0,
      'desagregation_age': desagregationAge ? 1 : 0,
      'desagregation_zone': desagregationZone ? 1 : 0,
      'seuil_alerte_min': seuilAlerteMin,
      'seuil_alerte_max': seuilAlerteMax,
      // valeur_actuelle n'est pas persistée dans la table indicateurs directement
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Indicateur.fromMap(Map<String, dynamic> map) {
    return Indicateur(
      id: map['id'] as int?,
      projetId: map['projet_id'] as int,
      cadreLogiqueId: map['cadre_logique_id'] as int?,
      codeIndicateur: map['code_indicateur'] as String,
      libelle: map['libelle'] as String,
      definition: map['definition'] as String?,
      niveau: NiveauIndicateur.values.firstWhere(
        (e) => e.name == map['niveau'],
        orElse: () => NiveauIndicateur.output,
      ),
      type: TypeIndicateur.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TypeIndicateur.quantitatif,
      ),
      uniteMesure: map['unite_mesure'] as String?,
      baseline: map['baseline'] as double?,
      cibleFinale: map['cible_finale'] as double?,
      frequenceCollecte: FrequenceCollecte.values.firstWhere(
        (e) => e.name == map['frequence_collecte'],
        orElse: () => FrequenceCollecte.trimestrielle,
      ),
      responsableCollecteId: map['responsable_collecte_id'] as int?,
      sourceDonnees: map['source_donnees'] as String?,
      methodeCollecte: map['methode_collecte'] as String?,
      desagregationSexe: map['desagregation_sexe'] == 1,
      desagregationAge: map['desagregation_age'] == 1,
      desagregationZone: map['desagregation_zone'] == 1,
      seuilAlerteMin: (map['seuil_alerte_min'] as num?)?.toDouble(),
      seuilAlerteMax: (map['seuil_alerte_max'] as num?)?.toDouble(),
      valeurActuelle: (map['valeur_actuelle'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Créer une copie avec modifications
  Indicateur copyWith({
    int? id,
    int? projetId,
    int? cadreLogiqueId,
    String? codeIndicateur,
    String? libelle,
    String? definition,
    NiveauIndicateur? niveau,
    TypeIndicateur? type,
    String? uniteMesure,
    double? baseline,
    double? cibleFinale,
    FrequenceCollecte? frequenceCollecte,
    int? responsableCollecteId,
    String? sourceDonnees,
    String? methodeCollecte,
    bool? desagregationSexe,
    bool? desagregationAge,
    bool? desagregationZone,
    double? seuilAlerteMin,
    double? seuilAlerteMax,
    double? valeurActuelle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Indicateur(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      cadreLogiqueId: cadreLogiqueId ?? this.cadreLogiqueId,
      codeIndicateur: codeIndicateur ?? this.codeIndicateur,
      libelle: libelle ?? this.libelle,
      definition: definition ?? this.definition,
      niveau: niveau ?? this.niveau,
      type: type ?? this.type,
      uniteMesure: uniteMesure ?? this.uniteMesure,
      baseline: baseline ?? this.baseline,
      cibleFinale: cibleFinale ?? this.cibleFinale,
      frequenceCollecte: frequenceCollecte ?? this.frequenceCollecte,
      responsableCollecteId:
          responsableCollecteId ?? this.responsableCollecteId,
      sourceDonnees: sourceDonnees ?? this.sourceDonnees,
      methodeCollecte: methodeCollecte ?? this.methodeCollecte,
      desagregationSexe: desagregationSexe ?? this.desagregationSexe,
      desagregationAge: desagregationAge ?? this.desagregationAge,
      desagregationZone: desagregationZone ?? this.desagregationZone,
      seuilAlerteMin: seuilAlerteMin ?? this.seuilAlerteMin,
      seuilAlerteMax: seuilAlerteMax ?? this.seuilAlerteMax,
      valeurActuelle: valeurActuelle ?? this.valeurActuelle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Indicateur(id: $id, code: $codeIndicateur, libelle: $libelle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Indicateur &&
        other.id == id &&
        other.codeIndicateur == codeIndicateur;
  }

  @override
  int get hashCode => Object.hash(id, codeIndicateur);
}

/// Niveau de l'indicateur
enum NiveauIndicateur {
  impact,
  outcome,
  output;

  String get label {
    switch (this) {
      case NiveauIndicateur.impact:
        return 'Impact';
      case NiveauIndicateur.outcome:
        return 'Résultat';
      case NiveauIndicateur.output:
        return 'Produit';
    }
  }
}

/// Type d'indicateur
enum TypeIndicateur {
  quantitatif,
  qualitatif,
  processus;

  String get label {
    switch (this) {
      case TypeIndicateur.quantitatif:
        return 'Quantitatif';
      case TypeIndicateur.qualitatif:
        return 'Qualitatif';
      case TypeIndicateur.processus:
        return 'Processus';
    }
  }
}

/// Fréquence de collecte des données
enum FrequenceCollecte {
  mensuelle,
  trimestrielle,
  semestrielle,
  annuelle;

  String get label {
    switch (this) {
      case FrequenceCollecte.mensuelle:
        return 'Mensuelle';
      case FrequenceCollecte.trimestrielle:
        return 'Trimestrielle';
      case FrequenceCollecte.semestrielle:
        return 'Semestrielle';
      case FrequenceCollecte.annuelle:
        return 'Annuelle';
    }
  }
}
