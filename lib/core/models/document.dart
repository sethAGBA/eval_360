/// Types de documents gérés par la GED
enum TypeDocument {
  tdr,
  ordreMission,
  rapportHebdo,
  rapportMensuel,
  compteRendu,
  rapportStage,
  autre;

  String get label {
    switch (this) {
      case TypeDocument.tdr: return 'Termes de Référence';
      case TypeDocument.ordreMission: return 'Ordre de Mission';
      case TypeDocument.rapportHebdo: return 'Rapport Hebdomadaire';
      case TypeDocument.rapportMensuel: return 'Rapport Mensuel';
      case TypeDocument.compteRendu: return 'Compte-Rendu';
      case TypeDocument.rapportStage: return 'Rapport de Stage';
      case TypeDocument.autre: return 'Autre Document';
    }
  }
}

/// Statuts de validation des documents
enum StatutDocument {
  brouillon,
  enRevue,
  valide,
  rejete;

  String get label {
    switch (this) {
      case StatutDocument.brouillon: return 'Brouillon';
      case StatutDocument.enRevue: return 'En Revue';
      case StatutDocument.valide: return 'Validé';
      case StatutDocument.rejete: return 'Rejeté';
    }
  }
}

/// Modèle pour un document dans la GED
class Document {
  final int? id;
  final String titre;
  final TypeDocument type;
  final String? filePath;
  final String? extension;
  final int? taille;
  final int? projetId;
  final int? activiteId;
  final int? agentId;
  final DateTime dateDocument;
  final StatutDocument statut;
  final String? referenceBoite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Document({
    this.id,
    required this.titre,
    required this.type,
    this.filePath,
    this.extension,
    this.taille,
    this.projetId,
    this.activiteId,
    this.agentId,
    required this.dateDocument,
    this.statut = StatutDocument.brouillon,
    this.referenceBoite,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'type_document': type.name,
      'file_path': filePath,
      'extension': extension,
      'taille': taille,
      'projet_id': projetId,
      'activite_id': activiteId,
      'agent_id': agentId,
      'date_document': dateDocument.toIso8601String(),
      'statut_validation': statut.name,
      'reference_boite': referenceBoite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as int?,
      titre: map['titre'] as String,
      type: TypeDocument.values.firstWhere((e) => e.name == map['type_document']),
      filePath: map['file_path'] as String?,
      extension: map['extension'] as String?,
      taille: map['taille'] as int?,
      projetId: map['projet_id'] as int?,
      activiteId: map['activite_id'] as int?,
      agentId: map['agent_id'] as int?,
      dateDocument: DateTime.parse(map['date_document'] as String),
      statut: StatutDocument.values.firstWhere((e) => e.name == map['statut_validation']),
      referenceBoite: map['reference_boite'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
