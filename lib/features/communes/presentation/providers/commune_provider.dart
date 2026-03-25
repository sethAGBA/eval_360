import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/models/commune.dart';
import '../../../../core/models/zone_intervention.dart';
import '../../../../core/services/database_service.dart';

/// Provider pour la liste des communes
final communesProvider = FutureProvider<List<Commune>>((ref) async {
  return await DatabaseService.instance.getCommunes();
});

/// Provider pour filtrer les communes par région
final communeRegionFilterProvider = StateProvider<String?>((ref) => null);

/// Provider pour les communes filtrées
final filteredCommunesProvider = Provider<AsyncValue<List<Commune>>>((ref) {
  final communesAsync = ref.watch(communesProvider);
  final regionFilter = ref.watch(communeRegionFilterProvider);

  return communesAsync.whenData((communes) {
    if (regionFilter == null) return communes;
    return communes.where((c) => c.region == regionFilter).toList();
  });
});

/// Provider pour les statistiques globales des PDC
final pdcStatsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final communesAsync = ref.watch(communesProvider);
  
  return communesAsync.whenData((communes) {
    if (communes.isEmpty) return {'moyenne': 0.0};
    final sum = communes.fold<double>(0, (prev, element) => prev + element.tauxAvancementPdc);
    return {'moyenne': sum / communes.length};
  });
});

/// Provider pour les zones d'une commune spécifique
final zonesByCommuneProvider = FutureProvider.family<List<ZoneIntervention>, int>((ref, communeId) async {
  return await DatabaseService.instance.getZonesByCommune(communeId);
});
