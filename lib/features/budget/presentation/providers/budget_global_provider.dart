import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/models/depense.dart';
import '../../../../core/services/database_service.dart';

/// Provider pour les statistiques budgétaires globales
final globalBudgetStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  return await DatabaseService.instance.getGlobalBudgetStats();
});

/// Provider pour toutes les dépenses (tous projets confondus)
final allDepensesProvider = FutureProvider<List<Depense>>((ref) async {
  return await DatabaseService.instance.getAllDepenses();
});

/// StateNotifier pour gérer les actions sur les dépenses (validation, etc.)
final depenseActionProvider = StateNotifierProvider<DepenseActionNotifier, AsyncValue<void>>((ref) {
  return DepenseActionNotifier(ref);
});

class DepenseActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  DepenseActionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateStatus(int id, StatutValidationDepense status) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseService.instance.updateDepenseStatus(id, status);
      // Invalider les providers pour rafraîchir les données
      ref.invalidate(allDepensesProvider);
      ref.invalidate(globalBudgetStatsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
