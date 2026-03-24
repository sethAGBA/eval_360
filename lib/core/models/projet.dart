import '../database/database_tables.dart';

/// Modèle de données pour un projet
class Projet {
  final int? id;
  final String codeProjet;
  final String titre;
  final String? description;
  final String? contexte;
  final String secteurIntervention;
  final DateTime dateDebutPrevue;
  final DateTime dateFinPrevue;
  final DateTime? dateDebutReelle;
  final DateTime? dateFinReelle;
  final double budgetTotal;
  final ProjetStatut statut;
  final int? chefProjetId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Projet({
    this.id,
    required this.codeProjet,
    required this.titre,
    this.description,
    this.contexte,
    required this.secteurIntervention,
    required this.dateDebutPrevue,
    required this.dateFinPrevue,
    this.dateDebutReelle,
    this.dateFinReelle,
    required this.budgetTotal,
    required this.statut,
    this.chefProjetId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) ProjetsColumns.id: id,
      ProjetsColumns.codeProjet: codeProjet,
      ProjetsColumns.titre: titre,
      ProjetsColumns.description: description,
      ProjetsColumns.contexte: contexte,
      ProjetsColumns.secteurIntervention: secteurIntervention,
      ProjetsColumns.dateDebutPrevue: dateDebutPrevue.toIso8601String(),
      ProjetsColumns.dateFinPrevue: dateFinPrevue.toIso8601String(),
      ProjetsColumns.dateDebutReelle: dateDebutReelle?.toIso8601String(),
      ProjetsColumns.dateFinReelle: dateFinReelle?.toIso8601String(),
      ProjetsColumns.budgetTotal: budgetTotal,
      ProjetsColumns.statut: statut.name,
      ProjetsColumns.chefProjetId: chefProjetId,
      ProjetsColumns.createdAt: createdAt.toIso8601String(),
      ProjetsColumns.updatedAt: updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Projet.fromMap(Map<String, dynamic> map) {
    return Projet(
      id: map[ProjetsColumns.id] as int?,
      codeProjet: map[ProjetsColumns.codeProjet] as String,
      titre: map[ProjetsColumns.titre] as String,
      description: map[ProjetsColumns.description] as String?,
      contexte: map[ProjetsColumns.contexte] as String?,
      secteurIntervention: map[ProjetsColumns.secteurIntervention] as String,
      dateDebutPrevue: DateTime.parse(
        map[ProjetsColumns.dateDebutPrevue] as String,
      ),
      dateFinPrevue: DateTime.parse(
        map[ProjetsColumns.dateFinPrevue] as String,
      ),
      dateDebutReelle: map[ProjetsColumns.dateDebutReelle] != null
          ? DateTime.parse(map[ProjetsColumns.dateDebutReelle] as String)
          : null,
      dateFinReelle: map[ProjetsColumns.dateFinReelle] != null
          ? DateTime.parse(map[ProjetsColumns.dateFinReelle] as String)
          : null,
      budgetTotal: (map[ProjetsColumns.budgetTotal] as num).toDouble(),
      statut: ProjetStatut.values.firstWhere(
        (e) => e.name == map[ProjetsColumns.statut],
        orElse: () => ProjetStatut.pipeline,
      ),
      chefProjetId: map[ProjetsColumns.chefProjetId] as int?,
      createdAt: DateTime.parse(map[ProjetsColumns.createdAt] as String),
      updatedAt: DateTime.parse(map[ProjetsColumns.updatedAt] as String),
    );
  }

  /// Créer une copie avec modifications
  Projet copyWith({
    int? id,
    String? codeProjet,
    String? titre,
    String? description,
    String? contexte,
    String? secteurIntervention,
    DateTime? dateDebutPrevue,
    DateTime? dateFinPrevue,
    DateTime? dateDebutReelle,
    DateTime? dateFinReelle,
    double? budgetTotal,
    ProjetStatut? statut,
    int? chefProjetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Projet(
      id: id ?? this.id,
      codeProjet: codeProjet ?? this.codeProjet,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      contexte: contexte ?? this.contexte,
      secteurIntervention: secteurIntervention ?? this.secteurIntervention,
      dateDebutPrevue: dateDebutPrevue ?? this.dateDebutPrevue,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
      dateDebutReelle: dateDebutReelle ?? this.dateDebutReelle,
      dateFinReelle: dateFinReelle ?? this.dateFinReelle,
      budgetTotal: budgetTotal ?? this.budgetTotal,
      statut: statut ?? this.statut,
      chefProjetId: chefProjetId ?? this.chefProjetId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculer la durée du projet en jours
  int get dureePrevueJours {
    return dateFinPrevue.difference(dateDebutPrevue).inDays;
  }

  /// Calculer le pourcentage d'avancement temporel
  double get pourcentageAvancementTemporel {
    final now = DateTime.now();
    if (now.isBefore(dateDebutPrevue)) return 0.0;
    if (now.isAfter(dateFinPrevue)) return 100.0;

    final totalDays = dateFinPrevue.difference(dateDebutPrevue).inDays;
    final elapsedDays = now.difference(dateDebutPrevue).inDays;

    return (elapsedDays / totalDays * 100).clamp(0.0, 100.0);
  }

  /// Vérifier si le projet est en retard
  bool get estEnRetard {
    return DateTime.now().isAfter(dateFinPrevue) &&
        statut != ProjetStatut.cloture;
  }

  @override
  String toString() {
    return 'Projet(id: $id, code: $codeProjet, titre: $titre, statut: $statut)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Projet &&
        other.id == id &&
        other.codeProjet == codeProjet &&
        other.titre == titre;
  }

  @override
  int get hashCode => Object.hash(id, codeProjet, titre);
}

/// Statut d'un projet
enum ProjetStatut {
  /// Projet en phase de préparation
  pipeline,

  /// Projet en cours d'exécution
  actif,

  /// Projet temporairement suspendu
  suspendu,

  /// Projet terminé et clôturé
  cloture;

  /// Label lisible du statut
  String get label {
    switch (this) {
      case ProjetStatut.pipeline:
        return 'Pipeline';
      case ProjetStatut.actif:
        return 'Actif';
      case ProjetStatut.suspendu:
        return 'Suspendu';
      case ProjetStatut.cloture:
        return 'Clôturé';
    }
  }

  /// Couleur associée au statut
  String get colorHex {
    switch (this) {
      case ProjetStatut.pipeline:
        return '#FFA726'; // Orange
      case ProjetStatut.actif:
        return '#66BB6A'; // Vert
      case ProjetStatut.suspendu:
        return '#EF5350'; // Rouge
      case ProjetStatut.cloture:
        return '#78909C'; // Gris
    }
  }
}
