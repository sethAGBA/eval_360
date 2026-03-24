import '../database/database_tables.dart';

/// Modèle pour une ligne de détail dans un rapport hebdomadaire
class LigneRapport {
  final int? id;
  final int rapportId;
  final int? activiteId;
  final String description;
  final String? evenementConnexe;
  final String? lieu;
  final int? structureId;
  final String? responsable;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String statutActivite;
  final String? resultatsAtteints;
  final String? difficultesRencontrees;
  final String? prochainesEtapes;

  const LigneRapport({
    this.id,
    required this.rapportId,
    this.activiteId,
    required this.description,
    this.evenementConnexe,
    this.lieu,
    this.structureId,
    this.responsable,
    required this.dateDebut,
    required this.dateFin,
    required this.statutActivite,
    this.resultatsAtteints,
    this.difficultesRencontrees,
    this.prochainesEtapes,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) LignesRapportColumns.id: id,
      LignesRapportColumns.rapportId: rapportId,
      LignesRapportColumns.activiteId: activiteId,
      LignesRapportColumns.description: description,
      LignesRapportColumns.evenementConnexe: evenementConnexe,
      LignesRapportColumns.lieu: lieu,
      LignesRapportColumns.structureId: structureId,
      LignesRapportColumns.responsable: responsable,
      LignesRapportColumns.dateDebut: dateDebut.toIso8601String(),
      LignesRapportColumns.dateFin: dateFin.toIso8601String(),
      LignesRapportColumns.statutActivite: statutActivite,
      LignesRapportColumns.resultatsAtteints: resultatsAtteints,
      LignesRapportColumns.difficultesRencontrees: difficultesRencontrees,
      LignesRapportColumns.prochainesEtapes: prochainesEtapes,
    };
  }

  /// Créer depuis Map de la base de données
  factory LigneRapport.fromMap(Map<String, dynamic> map) {
    return LigneRapport(
      id: map[LignesRapportColumns.id] as int?,
      rapportId: map[LignesRapportColumns.rapportId] as int,
      activiteId: map[LignesRapportColumns.activiteId] as int?,
      description: map[LignesRapportColumns.description] as String,
      evenementConnexe: map[LignesRapportColumns.evenementConnexe] as String?,
      lieu: map[LignesRapportColumns.lieu] as String?,
      structureId: map[LignesRapportColumns.structureId] as int?,
      responsable: map[LignesRapportColumns.responsable] as String?,
      dateDebut: DateTime.parse(map[LignesRapportColumns.dateDebut] as String),
      dateFin: DateTime.parse(map[LignesRapportColumns.dateFin] as String),
      statutActivite: map[LignesRapportColumns.statutActivite] as String,
      resultatsAtteints: map[LignesRapportColumns.resultatsAtteints] as String?,
      difficultesRencontrees:
          map[LignesRapportColumns.difficultesRencontrees] as String?,
      prochainesEtapes: map[LignesRapportColumns.prochainesEtapes] as String?,
    );
  }

  LigneRapport copyWith({
    int? id,
    int? rapportId,
    int? activiteId,
    String? description,
    String? evenementConnexe,
    String? lieu,
    int? structureId,
    String? responsable,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? statutActivite,
    String? resultatsAtteints,
    String? difficultesRencontrees,
    String? prochainesEtapes,
  }) {
    return LigneRapport(
      id: id ?? this.id,
      rapportId: rapportId ?? this.rapportId,
      activiteId: activiteId ?? this.activiteId,
      description: description ?? this.description,
      evenementConnexe: evenementConnexe ?? this.evenementConnexe,
      lieu: lieu ?? this.lieu,
      structureId: structureId ?? this.structureId,
      responsable: responsable ?? this.responsable,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statutActivite: statutActivite ?? this.statutActivite,
      resultatsAtteints: resultatsAtteints ?? this.resultatsAtteints,
      difficultesRencontrees:
          difficultesRencontrees ?? this.difficultesRencontrees,
      prochainesEtapes: prochainesEtapes ?? this.prochainesEtapes,
    );
  }

  @override
  String toString() {
    return 'LigneRapport(id: $id, rapportId: $rapportId, desc: $description)';
  }
}
