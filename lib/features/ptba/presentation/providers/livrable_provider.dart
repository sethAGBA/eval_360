import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/livrable.dart';
import '../../../../core/services/database_service.dart';

// ============================================================================
// PROVIDERS POUR LES LIVRABLES
// ============================================================================

/// Provider pour récupérer la liste des livrables associés à une activité
final livrablesProvider = FutureProvider.family<List<Livrable>, int>((ref, activiteId) async {
  return await DatabaseService.instance.getLivrablesByActivite(activiteId);
});
