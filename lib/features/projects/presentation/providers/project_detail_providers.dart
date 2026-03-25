// import 'package:eval360/core/models/activite.dart';
// import 'package:eval360/core/models/cadre_logique.dart';
// import 'package:eval360/core/models/indicateur.dart';
// import 'package:eval360/core/services/database_service.dart';
import 'package:eval_360/core/models/activite.dart';
import 'package:eval_360/core/models/cadre_logique.dart';
import 'package:eval_360/core/models/indicateur.dart';
import 'package:eval_360/core/models/zone_intervention.dart';
import 'package:eval_360/core/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour le cadre logique d'un projet
final cadreLogiqueProvider = FutureProvider.family<List<CadreLogique>, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getCadreLogiqueByProject(projectId);
});

/// Provider pour les indicateurs d'un projet
final indicateursProvider = FutureProvider.family<List<Indicateur>, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getIndicateursByProject(projectId);
});

/// Provider pour les activités d'un projet
final activitesProvider = FutureProvider.family<List<Activite>, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getActivitesByProject(projectId);
});

/// Provider pour les zones d'intervention d'un projet
final zonesProvider = FutureProvider.family<List<ZoneIntervention>, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getZonesByProject(projectId);
});

/// Provider pour toutes les activités (utilisé dans les rapports)
final allActivitesProvider = FutureProvider<List<Activite>>((ref) async {
  return await DatabaseService.instance.getActivites();
});
