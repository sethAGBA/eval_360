import '../database/database_tables.dart';

enum TachePriorite {
  basse('basse', 'Basse'),
  moyenne('moyenne', 'Moyenne'),
  haute('haute', 'Haute');

  final String value;
  final String label;
  const TachePriorite(this.value, this.label);

  static TachePriorite fromString(String value) {
    return TachePriorite.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TachePriorite.moyenne,
    );
  }
}

enum TacheStatut {
  aFaire('a_faire', 'À faire'),
  enCours('en_cours', 'En cours'),
  termine('termine', 'Terminé'),
  suspendu('suspendu', 'Suspendu');

  final String value;
  final String label;
  const TacheStatut(this.value, this.label);

  static TacheStatut fromString(String value) {
    return TacheStatut.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TacheStatut.aFaire,
    );
  }
}

class Tache {
  final int? id;
  final String titre;
  final String? description;
  final TachePriorite priorite;
  final TacheStatut statut;
  final DateTime? dateEcheance;
  final double pourcentageAvancement;
  final List<int> agentIds;
  final int? activiteId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tache({
    this.id,
    required this.titre,
    this.description,
    this.priorite = TachePriorite.moyenne,
    this.statut = TacheStatut.aFaire,
    this.dateEcheance,
    this.pourcentageAvancement = 0.0,
    this.agentIds = const [],
    this.activiteId,
    this.createdAt,
    this.updatedAt,
  });

  factory Tache.fromMap(Map<String, dynamic> map) {
    return Tache(
      id: map[TachesColumns.id],
      titre: map[TachesColumns.titre],
      description: map[TachesColumns.description],
      priorite: TachePriorite.fromString(map[TachesColumns.priorite]),
      statut: TacheStatut.fromString(map[TachesColumns.statut]),
      dateEcheance: map[TachesColumns.dateEcheance] != null 
          ? DateTime.parse(map[TachesColumns.dateEcheance]) 
          : null,
      pourcentageAvancement: (map[TachesColumns.pourcentageAvancement] as num?)?.toDouble() ?? 0.0,
      agentIds: map['agent_ids'] != null 
          ? List<int>.from(map['agent_ids']) 
          : (map[TachesColumns.agentId] != null ? [map[TachesColumns.agentId] as int] : []),
      activiteId: map[TachesColumns.activiteId],
      createdAt: map[TachesColumns.createdAt] != null 
          ? DateTime.parse(map[TachesColumns.createdAt]) 
          : null,
      updatedAt: map[TachesColumns.updatedAt] != null 
          ? DateTime.parse(map[TachesColumns.updatedAt]) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) TachesColumns.id: id,
      TachesColumns.titre: titre,
      TachesColumns.description: description,
      TachesColumns.priorite: priorite.value,
      TachesColumns.statut: statut.value,
      TachesColumns.dateEcheance: dateEcheance?.toIso8601String(),
      TachesColumns.pourcentageAvancement: pourcentageAvancement,
      TachesColumns.activiteId: activiteId,
      // agentIds handles via join table in DatabaseService
    };
  }

  Tache copyWith({
    int? id,
    String? titre,
    String? description,
    TachePriorite? priorite,
    TacheStatut? statut,
    DateTime? dateEcheance,
    double? pourcentageAvancement,
    List<int>? agentIds,
    int? activiteId,
  }) {
    return Tache(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      priorite: priorite ?? this.priorite,
      statut: statut ?? this.statut,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      pourcentageAvancement: pourcentageAvancement ?? this.pourcentageAvancement,
      agentIds: agentIds ?? this.agentIds,
      activiteId: activiteId ?? this.activiteId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
