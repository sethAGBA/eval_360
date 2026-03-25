import '../database/database_tables.dart';

/// Modèle de données pour une zone d'intervention géographique
class ZoneIntervention {
  final int? id;
  final String pays;
  final String? region;
  final String? provinceDepartement;
  final String? communeDistrict;
  final String? villageQuartier;
  final double? latitude;
  final double? longitude;
  final int? populationTotale;
  final int? communeId;

  const ZoneIntervention({
    this.id,
    required this.pays,
    this.region,
    this.provinceDepartement,
    this.communeDistrict,
    this.villageQuartier,
    this.latitude,
    this.longitude,
    this.populationTotale,
    this.communeId,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) ZonesColumns.id: id,
      ZonesColumns.pays: pays,
      ZonesColumns.region: region,
      ZonesColumns.provinceDepartement: provinceDepartement,
      ZonesColumns.communeDistrict: communeDistrict,
      ZonesColumns.villageQuartier: villageQuartier,
      ZonesColumns.latitude: latitude,
      ZonesColumns.longitude: longitude,
      ZonesColumns.populationTotale: populationTotale,
      ZonesColumns.communeId: communeId,
    };
  }

  /// Créer depuis Map de la base de données
  factory ZoneIntervention.fromMap(Map<String, dynamic> map) {
    return ZoneIntervention(
      id: map[ZonesColumns.id] as int?,
      pays: map[ZonesColumns.pays] as String,
      region: map[ZonesColumns.region] as String?,
      provinceDepartement: map[ZonesColumns.provinceDepartement] as String?,
      communeDistrict: map[ZonesColumns.communeDistrict] as String?,
      villageQuartier: map[ZonesColumns.villageQuartier] as String?,
      latitude: map[ZonesColumns.latitude] as double?,
      longitude: map[ZonesColumns.longitude] as double?,
      populationTotale: map[ZonesColumns.populationTotale] as int?,
      communeId: map[ZonesColumns.communeId] as int?,
    );
  }

  /// Créer une copie avec modifications
  ZoneIntervention copyWith({
    int? id,
    String? pays,
    String? region,
    String? provinceDepartement,
    String? communeDistrict,
    String? villageQuartier,
    double? latitude,
    double? longitude,
    int? populationTotale,
    int? communeId,
  }) {
    return ZoneIntervention(
      id: id ?? this.id,
      pays: pays ?? this.pays,
      region: region ?? this.region,
      provinceDepartement: provinceDepartement ?? this.provinceDepartement,
      communeDistrict: communeDistrict ?? this.communeDistrict,
      villageQuartier: villageQuartier ?? this.villageQuartier,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      populationTotale: populationTotale ?? this.populationTotale,
      communeId: communeId ?? this.communeId,
    );
  }

  /// Obtenir le nom complet de la zone (du plus spécifique au plus général)
  String get nomComplet {
    final parts = <String>[];

    if (villageQuartier != null && villageQuartier!.isNotEmpty) {
      parts.add(villageQuartier!);
    }
    if (communeDistrict != null && communeDistrict!.isNotEmpty) {
      parts.add(communeDistrict!);
    }
    if (provinceDepartement != null && provinceDepartement!.isNotEmpty) {
      parts.add(provinceDepartement!);
    }
    if (region != null && region!.isNotEmpty) {
      parts.add(region!);
    }
    parts.add(pays);

    return parts.join(', ');
  }

  /// Obtenir le nom court (niveau le plus spécifique disponible)
  String get nomCourt {
    return villageQuartier ??
        communeDistrict ??
        provinceDepartement ??
        region ??
        pays;
  }

  /// Vérifier si la zone a des coordonnées GPS
  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  @override
  String toString() {
    return 'ZoneIntervention(id: $id, nom: $nomComplet, communeId: $communeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ZoneIntervention &&
        other.id == id &&
        other.nomComplet == nomComplet &&
        other.communeId == communeId;
  }

  @override
  int get hashCode => Object.hash(id, nomComplet, communeId);
}
