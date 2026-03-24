import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/models/tache.dart';
import '../../../../core/services/database_service.dart';

// ============================================================================
// PROVIDERS POUR LES TACHES
// ============================================================================

/// Filtres pour les tâches
class TaskFilters {
  final int? agentId;
  final TacheStatut? statut;

  const TaskFilters({this.agentId, this.statut});

  TaskFilters copyWith({int? agentId, TacheStatut? statut}) {
    return TaskFilters(
      agentId: agentId ?? this.agentId,
      statut: statut ?? this.statut,
    );
  }
}

/// Provider pour l'état des filtres
final taskFiltersProvider = StateProvider<TaskFilters>((ref) {
  return const TaskFilters();
});

/// Provider pour récupérer toutes les tâches filtrées
final tasksProvider = FutureProvider<List<Tache>>((ref) async {
  final filters = ref.watch(taskFiltersProvider);
  return await DatabaseService.instance.getTasks(
    agentId: filters.agentId,
    statut: filters.statut,
  );
});

/// Notifier pour la gestion des actions sur les tâches
class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TaskNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addTask(Tache tache) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseService.instance.createTask(tache);
      ref.invalidate(tasksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(Tache tache) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseService.instance.updateTask(tache);
      ref.invalidate(tasksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> moveTask(Tache tache, TacheStatut nouveauStatut) async {
    final updatedTache = tache.copyWith(statut: nouveauStatut);
    await updateTask(updatedTache);
  }

  Future<void> deleteTask(int id) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseService.instance.deleteTask(id);
      ref.invalidate(tasksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider pour les actions sur les tâches
final taskActionProvider = StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  return TaskNotifier(ref);
});

/// Provider pour récupérer une tâche spécifique
final taskDetailProvider = FutureProvider.family<Tache?, int>((ref, id) async {
  return await DatabaseService.instance.getTaskById(id);
});
