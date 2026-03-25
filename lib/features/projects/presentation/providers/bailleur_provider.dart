// import 'package:eval360/core/models/bailleur.dart';
// import 'package:eval360/core/services/database_service.dart';
import 'package:eval_360/core/models/bailleur.dart';
import 'package:eval_360/core/models/partenaire.dart';
import 'package:eval_360/core/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour récupérer tous les bailleurs
final bailleursProvider = FutureProvider<List<Bailleur>>((ref) async {
  return await DatabaseService.instance.getBailleurs();
});

final projectBailleursProvider = FutureProvider.family<List<Bailleur>, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getBailleursByProject(projectId);
});

/// Provider pour les partenaires d'un projet spécifique
final projectPartenairesProvider = FutureProvider.family<List<Partenaire>, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getPartenairesByProject(projectId);
});
