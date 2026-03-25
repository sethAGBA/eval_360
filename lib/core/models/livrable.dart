import '../database/database_tables.dart';

/// Modèle de données pour un Livrable (ou Jalon) lié à une activité
class Livrable {
  final int? id;
  final int activiteId;
  final String titre;
  final String? description;
  final DateTime dateEcheance;
  final StatutLivrable statut;
  final String? lienDocument;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Livrable({
    this.id,
    required this.activiteId,
    required this.titre,
    this.description,
    required this.dateEcheance,
    this.statut = StatutLivrable.en_attente,
    this.lienDocument,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) JalonsLivrablesColumns.id: id,
      JalonsLivrablesColumns.activiteId: activiteId,
      JalonsLivrablesColumns.titre: titre,
      JalonsLivrablesColumns.description: description,
      JalonsLivrablesColumns.dateEcheance: dateEcheance.toIso8601String(),
      JalonsLivrablesColumns.statut: statut.name,
      JalonsLivrablesColumns.lienDocument: lienDocument,
      JalonsLivrablesColumns.createdAt: createdAt.toIso8601String(),
      JalonsLivrablesColumns.updatedAt: updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Livrable.fromMap(Map<String, dynamic> map) {
    return Livrable(
      id: map[JalonsLivrablesColumns.id] as int?,
      activiteId: map[JalonsLivrablesColumns.activiteId] as int,
      titre: map[JalonsLivrablesColumns.titre] as String,
      description: map[JalonsLivrablesColumns.description] as String?,
      dateEcheance: DateTime.parse(map[JalonsLivrablesColumns.dateEcheance] as String),
      statut: StatutLivrable.values.firstWhere(
        (e) => e.name == map[JalonsLivrablesColumns.statut],
        orElse: () => StatutLivrable.en_attente,
      ),
      lienDocument: map[JalonsLivrablesColumns.lienDocument] as String?,
      createdAt: DateTime.parse(map[JalonsLivrablesColumns.createdAt] as String),
      updatedAt: DateTime.parse(map[JalonsLivrablesColumns.updatedAt] as String),
    );
  }

  /// Créer une copie avec modifications
  Livrable copyWith({
    int? id,
    int? activiteId,
    String? titre,
    String? description,
    DateTime? dateEcheance,
    StatutLivrable? statut,
    String? lienDocument,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Livrable(
      id: id ?? this.id,
      activiteId: activiteId ?? this.activiteId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      statut: statut ?? this.statut,
      lienDocument: lienDocument ?? this.lienDocument,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Statut d'un Livrable
enum StatutLivrable {
  en_attente,
  en_cours,
  termine,
  annule;

  String get label {
    switch (this) {
      case StatutLivrable.en_attente:
        return 'En attente';
      case StatutLivrable.en_cours:
        return 'En cours';
      case StatutLivrable.termine:
        return 'Terminé';
      case StatutLivrable.annule:
        return 'Annulé';
    }
  }

  String get colorHex {
    switch (this) {
      case StatutLivrable.en_attente:
        return '#9E9E9E'; // Gris
      case StatutLivrable.en_cours:
        return '#2196F3'; // Bleu
      case StatutLivrable.termine:
        return '#4CAF50'; // Vert
      case StatutLivrable.annule:
        return '#F44336'; // Rouge
    }
  }
}
