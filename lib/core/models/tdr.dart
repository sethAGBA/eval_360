/// Modèle pour les Termes de Référence (TdR)
class TdR {
  final int? id;
  final int documentId;
  final String contexteJustification;
  final String objectifsGeneraux;
  final String objectifsSpecifiques;
  final String resultatsAttendus;
  final String methodologie;
  final String? lieuExecution;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final double budgetEstime;
  final String? participantsPrevus;

  const TdR({
    this.id,
    required this.documentId,
    required this.contexteJustification,
    required this.objectifsGeneraux,
    required this.objectifsSpecifiques,
    required this.resultatsAttendus,
    required this.methodologie,
    this.lieuExecution,
    this.dateDebut,
    this.dateFin,
    this.budgetEstime = 0.0,
    this.participantsPrevus,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'document_id': documentId,
      'contexte_justification': contexteJustification,
      'objectifs_generaux': objectifsGeneraux,
      'objectifs_specifiques': objectifsSpecifiques,
      'resultats_attendus': resultatsAttendus,
      'methodologie': methodologie,
      'lieu_execution': lieuExecution,
      'date_debut': dateDebut?.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'budget_estime': budgetEstime,
      'participants_prevus': participantsPrevus,
    };
  }

  factory TdR.fromMap(Map<String, dynamic> map) {
    return TdR(
      id: map['id'] as int?,
      documentId: map['document_id'] as int,
      contexteJustification: map['contexte_justification'] as String? ?? '',
      objectifsGeneraux: map['objectifs_generaux'] as String? ?? '',
      objectifsSpecifiques: map['objectifs_specifiques'] as String? ?? '',
      resultatsAttendus: map['resultats_attendus'] as String? ?? '',
      methodologie: map['methodologie'] as String? ?? '',
      lieuExecution: map['lieu_execution'] as String?,
      dateDebut: map['date_debut'] != null ? DateTime.parse(map['date_debut'] as String) : null,
      dateFin: map['date_fin'] != null ? DateTime.parse(map['date_fin'] as String) : null,
      budgetEstime: (map['budget_estime'] as num? ?? 0.0).toDouble(),
      participantsPrevus: map['participants_prevus'] as String?,
    );
  }
}
