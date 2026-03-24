import 'package:eval_360/core/models/rapport_hebdo.dart';

/// Modèle pour un rapport mensuel (Module 05)
class RapportMensuel {
  final int? id;
  final int agentId;
  final int mois; // 1-12
  final int annee;
  final double tauxRealisationGlobal;
  final StatutValidationRapport statutValidation;
  final String? commentaireSuperviseur;
  final int? valideParId;
  final DateTime? dateValidation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RapportMensuel({
    this.id,
    required this.agentId,
    required this.mois,
    required this.annee,
    this.tauxRealisationGlobal = 0.0,
    this.statutValidation = StatutValidationRapport.brouillon,
    this.commentaireSuperviseur,
    this.valideParId,
    this.dateValidation,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'agent_id': agentId,
      'mois': mois,
      'annee': annee,
      'taux_realisation_global': tauxRealisationGlobal,
      'statut_validation': statutValidation.name,
      'commentaire_superviseur': commentaireSuperviseur,
      'valide_par_id': valideParId,
      'date_validation': dateValidation?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory RapportMensuel.fromMap(Map<String, dynamic> map) {
    return RapportMensuel(
      id: map['id'] as int?,
      agentId: map['agent_id'] as int,
      mois: map['mois'] as int,
      annee: map['annee'] as int,
      tauxRealisationGlobal: (map['taux_realisation_global'] as num?)?.toDouble() ?? 0.0,
      statutValidation: StatutValidationRapport.values.firstWhere(
        (e) => e.name == map['statut_validation'],
        orElse: () => StatutValidationRapport.brouillon,
      ),
      commentaireSuperviseur: map['commentaire_superviseur'] as String?,
      valideParId: map['valide_par_id'] as int?,
      dateValidation: map['date_validation'] != null 
          ? DateTime.parse(map['date_validation'] as String) 
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Créer une copie avec modifications
  RapportMensuel copyWith({
    int? id,
    int? agentId,
    int? mois,
    int? annee,
    double? tauxRealisationGlobal,
    StatutValidationRapport? statutValidation,
    String? commentaireSuperviseur,
    int? valideParId,
    DateTime? dateValidation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RapportMensuel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      mois: mois ?? this.mois,
      annee: annee ?? this.annee,
      tauxRealisationGlobal: tauxRealisationGlobal ?? this.tauxRealisationGlobal,
      statutValidation: statutValidation ?? this.statutValidation,
      commentaireSuperviseur: commentaireSuperviseur ?? this.commentaireSuperviseur,
      valideParId: valideParId ?? this.valideParId,
      dateValidation: dateValidation ?? this.dateValidation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Nom du mois en français
  String get moisNom {
    const moisNoms = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    if (mois >= 1 && mois <= 12) {
      return moisNoms[mois - 1];
    }
    return 'Inconnu';
  }
}
