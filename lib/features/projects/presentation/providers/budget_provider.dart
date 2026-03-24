import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/budget_ligne.dart';
import '../../../../core/models/depense.dart';
import '../../../../core/services/database_service.dart';

/// Provider pour les lignes budgétaires d'un projet
final projectBudgetLignesProvider =
    FutureProvider.family<List<BudgetLigne>, int>((ref, projetId) async {
      return await DatabaseService.instance.getBudgetLignesByProject(projetId);
    });

/// Provider pour les dépenses d'un projet
final projectDepensesProvider = FutureProvider.family<List<Depense>, int>((
  ref,
  projetId,
) async {
  return await DatabaseService.instance.getDepensesByProject(projetId);
});

/// Provider pour la consommation budgétaire par ligne
final budgetConsumptionProvider = FutureProvider.family<Map<int, double>, int>((
  ref,
  projetId,
) async {
  return await DatabaseService.instance.getBudgetConsumptionByLine(projetId);
});
