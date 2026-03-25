import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/services/database_service.dart';

// ============================================================================
// PROVIDERS POUR LES DÉTAILS D'UN PTBA
// ============================================================================

/// Provider pour récupérer la liste des activités associées à un PTBA spécifique
final ptbaActivitiesProvider = FutureProvider.family<List<Activite>, int>((ref, ptbaId) async {
  return await DatabaseService.instance.getActivitesByPlanTravail(ptbaId);
});
