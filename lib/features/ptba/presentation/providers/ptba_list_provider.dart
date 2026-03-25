import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/plan_travail.dart';
import '../../../../core/services/database_service.dart';

// ============================================================================
// PROVIDERS POUR LES PTBA
// ============================================================================

/// Provider pour récupérer la liste de tous les PTBAs
final ptbaListProvider = FutureProvider<List<PlanTravail>>((ref) async {
  return await DatabaseService.instance.getAllPlansTravail();
});

/// Provider pour récupérer un seul PTBA (si nécessaire en le cherchant dans la liste)
final ptbaDetailByIdProvider = FutureProvider.family<PlanTravail?, int>((ref, ptbaId) async {
  // Pour l'instant, c'est une requête un peu lourde qui scanne tout,
  // idéalement il faudrait une méthode getPlanTravailById() dans DatabaseService,
  // mais on peut s'en passer si on passe l'objet PlanTravail directement lors de la navigation.
  return null;
});
