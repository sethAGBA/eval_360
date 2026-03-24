// import 'package:eval360/core/models/bailleur.dart';
// import 'package:eval360/core/services/database_service.dart';
import 'package:eval_360/core/models/bailleur.dart';
import 'package:eval_360/core/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour récupérer tous les bailleurs
final bailleursProvider = FutureProvider<List<Bailleur>>((ref) async {
  return await DatabaseService.instance.getBailleurs();
});

/// Provider pour les bailleurs d'un projet spécifique
final projectBailleursProvider = FutureProvider.family<List<Bailleur>, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getBailleursByProject(projectId);
});
