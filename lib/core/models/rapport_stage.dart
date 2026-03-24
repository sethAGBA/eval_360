/// Modèle pour le Rapport de Stage Probatoire
class RapportStage {
  final int? id;
  final int documentId;
  final String introduction;
  final String presentationStructure;
  final String activitesRealisees;
  final String competencesAcquises;
  final String difficultesRencontrees;
  final String solutionsApportees;
  final String conclusionRecommandations;
  final DateTime dateSoumission;

  const RapportStage({
    this.id,
    required this.documentId,
    required this.introduction,
    required this.presentationStructure,
    required this.activitesRealisees,
    required this.competencesAcquises,
    required this.difficultesRencontrees,
    required this.solutionsApportees,
    required this.conclusionRecommandations,
    required this.dateSoumission,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'document_id': documentId,
      'introduction': introduction,
      'presentation_structure': presentationStructure,
      'activites_realisees': activitesRealisees,
      'competences_acquises': competencesAcquises,
      'difficultes_rencontrees': difficultesRencontrees,
      'solutions_apportees': solutionsApportees,
      'conclusion_recommandations': conclusionRecommandations,
      'date_soumission': dateSoumission.toIso8601String(),
    };
  }

  factory RapportStage.fromMap(Map<String, dynamic> map) {
    return RapportStage(
      id: map['id'] as int?,
      documentId: map['document_id'] as int,
      introduction: map['introduction'] as String? ?? '',
      presentationStructure: map['presentation_structure'] as String? ?? '',
      activitesRealisees: map['activites_realisees'] as String? ?? '',
      competencesAcquises: map['competences_acquises'] as String? ?? '',
      difficultesRencontrees: map['difficultes_rencontrees'] as String? ?? '',
      solutionsApportees: map['solutions_apportees'] as String? ?? '',
      conclusionRecommandations: map['conclusion_recommandations'] as String? ?? '',
      dateSoumission: DateTime.parse(map['date_soumission'] as String),
    );
  }
}
