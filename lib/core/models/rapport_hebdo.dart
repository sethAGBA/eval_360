import '../database/database_tables.dart';

/// Statut de validation d'un rapport
enum StatutValidationRapport {
  brouillon,
  enAttente,
  valide,
  rejete;

  String get label {
    switch (this) {
      case StatutValidationRapport.brouillon:
        return 'Brouillon';
      case StatutValidationRapport.enAttente:
        return 'En attente';
      case StatutValidationRapport.valide:
        return 'Validé';
      case StatutValidationRapport.rejete:
        return 'Rejeté';
    }
  }

  String get colorHex {
    switch (this) {
      case StatutValidationRapport.brouillon:
        return '#9E9E9E'; // Grey
      case StatutValidationRapport.enAttente:
        return '#FF9800'; // Orange
      case StatutValidationRapport.valide:
        return '#4CAF50'; // Green
      case StatutValidationRapport.rejete:
        return '#F44336'; // Red
    }
  }
}

/// Modèle pour l'entête d'un rapport hebdomadaire
class RapportHebdo {
  final int? id;
  final int agentId;
  final int semaineNumero;
  final int annee;
  final DateTime dateDebut;
  final DateTime dateFin;
  final StatutValidationRapport statutValidation;
  final String? commentaireSuperviseur;
  final int? valideParId;
  final DateTime? dateValidation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RapportHebdo({
    this.id,
    required this.agentId,
    required this.semaineNumero,
    required this.annee,
    required this.dateDebut,
    required this.dateFin,
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
      if (id != null) RapportsHebdoColumns.id: id,
      RapportsHebdoColumns.agentId: agentId,
      RapportsHebdoColumns.semaineNumero: semaineNumero,
      RapportsHebdoColumns.annee: annee,
      RapportsHebdoColumns.dateDebut: dateDebut.toIso8601String(),
      RapportsHebdoColumns.dateFin: dateFin.toIso8601String(),
      RapportsHebdoColumns.statutValidation: statutValidation.name,
      RapportsHebdoColumns.commentaireSuperviseur: commentaireSuperviseur,
      RapportsHebdoColumns.valideParId: valideParId,
      RapportsHebdoColumns.dateValidation: dateValidation?.toIso8601String(),
      RapportsHebdoColumns.createdAt: createdAt.toIso8601String(),
      RapportsHebdoColumns.updatedAt: updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory RapportHebdo.fromMap(Map<String, dynamic> map) {
    return RapportHebdo(
      id: map[RapportsHebdoColumns.id] as int?,
      agentId: map[RapportsHebdoColumns.agentId] as int,
      semaineNumero: map[RapportsHebdoColumns.semaineNumero] as int,
      annee: map[RapportsHebdoColumns.annee] as int,
      dateDebut: DateTime.parse(map[RapportsHebdoColumns.dateDebut] as String),
      dateFin: DateTime.parse(map[RapportsHebdoColumns.dateFin] as String),
      statutValidation: StatutValidationRapport.values.firstWhere(
        (e) => e.name == map[RapportsHebdoColumns.statutValidation],
        orElse: () => StatutValidationRapport.brouillon,
      ),
      commentaireSuperviseur:
          map[RapportsHebdoColumns.commentaireSuperviseur] as String?,
      valideParId: map[RapportsHebdoColumns.valideParId] as int?,
      dateValidation: map[RapportsHebdoColumns.dateValidation] != null
          ? DateTime.parse(map[RapportsHebdoColumns.dateValidation] as String)
          : null,
      createdAt: DateTime.parse(map[RapportsHebdoColumns.createdAt] as String),
      updatedAt: DateTime.parse(map[RapportsHebdoColumns.updatedAt] as String),
    );
  }

  RapportHebdo copyWith({
    int? id,
    int? agentId,
    int? semaineNumero,
    int? annee,
    DateTime? dateDebut,
    DateTime? dateFin,
    StatutValidationRapport? statutValidation,
    String? commentaireSuperviseur,
    int? valideParId,
    DateTime? dateValidation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RapportHebdo(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      semaineNumero: semaineNumero ?? this.semaineNumero,
      annee: annee ?? this.annee,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statutValidation: statutValidation ?? this.statutValidation,
      commentaireSuperviseur:
          commentaireSuperviseur ?? this.commentaireSuperviseur,
      valideParId: valideParId ?? this.valideParId,
      dateValidation: dateValidation ?? this.dateValidation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RapportHebdo(id: $id, semaine: $semaineNumero/$annee, statut: ${statutValidation.label})';
  }
}
