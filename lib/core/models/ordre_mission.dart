/// Modèle pour un Ordre de Mission (ORD)
class OrdreMission {
  final int? id;
  final int documentId;
  final String objetMission;
  final String itineraires;
  final DateTime dateDepart;
  final DateTime dateRetour;
  final String? moyenTransport;
  final String? vehiculeId;
  final String? accompagnateurs;
  final String? observation;

  const OrdreMission({
    this.id,
    required this.documentId,
    required this.objetMission,
    required this.itineraires,
    required this.dateDepart,
    required this.dateRetour,
    this.moyenTransport,
    this.vehiculeId,
    this.accompagnateurs,
    this.observation,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'document_id': documentId,
      'objet_mission': objetMission,
      'itineraire': itineraires,
      'date_depart': dateDepart.toIso8601String(),
      'date_retour': dateRetour.toIso8601String(),
      'moyen_transport': moyenTransport,
      'vehicule_id': vehiculeId,
      'accompagnateurs': accompagnateurs,
      'observation': observation,
    };
  }

  factory OrdreMission.fromMap(Map<String, dynamic> map) {
    return OrdreMission(
      id: map['id'] as int?,
      documentId: map['document_id'] as int,
      objetMission: map['objet_mission'] as String,
      itineraires: map['itineraire'] as String? ?? '',
      dateDepart: DateTime.parse(map['date_depart'] as String),
      dateRetour: DateTime.parse(map['date_retour'] as String),
      moyenTransport: map['moyen_transport'] as String?,
      vehiculeId: map['vehicule_id'] as String?,
      accompagnateurs: map['accompagnateurs'] as String?,
      observation: map['observation'] as String?,
    );
  }
}
