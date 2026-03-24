// import 'package:eval360/core/models/projet.dart';
// import 'package:eval360/core/services/database_service.dart';
// import 'package:eval360/core/database/database_tables.dart';
import 'package:eval_360/core/database/database_tables.dart';
import 'package:eval_360/core/models/projet.dart';
import 'package:eval_360/core/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// PROVIDERS POUR LES PROJETS
// ============================================================================

/// Provider pour récupérer tous les projets
final projectsProvider = FutureProvider<List<Projet>>((ref) async {
  return await DatabaseService.instance.getProjects();
});

/// Provider pour les filtres de projets
final projectFiltersProvider = StateProvider<ProjectFilters>((ref) {
  return ProjectFilters();
});

/// Provider pour les projets filtrés
final filteredProjectsProvider = FutureProvider<List<Projet>>((ref) async {
  final filters = ref.watch(projectFiltersProvider);
  // Watch the base projectsProvider to ensure refresh when data changes
  await ref.watch(projectsProvider.future);

  return await DatabaseService.instance.getProjects(
    statut: filters.statut,
    bailleurId: filters.bailleurId,
    secteur: filters.secteur,
    dateDebutMin: filters.dateDebutMin,
    dateDebutMax: filters.dateDebutMax,
    searchQuery: filters.searchQuery,
    orderBy: filters.orderBy,
    ascending: filters.ascending,
  );
});

/// Provider pour un projet sélectionné
final selectedProjectIdProvider = StateProvider<int?>((ref) => null);

/// Provider pour récupérer un projet par ID
final selectedProjectProvider = FutureProvider<Projet?>((ref) async {
  final projectId = ref.watch(selectedProjectIdProvider);
  if (projectId == null) return null;

  return await DatabaseService.instance.getProjectById(projectId);
});

/// Provider pour les statistiques d'un projet
final projectStatsProvider = FutureProvider.family<ProjectStats, int>((
  ref,
  projectId,
) async {
  return await DatabaseService.instance.getProjectStats(projectId);
});

/// Provider pour le nombre de projets par statut
final projectCountByStatusProvider = FutureProvider<Map<ProjetStatut, int>>((
  ref,
) async {
  return await DatabaseService.instance.getProjectCountByStatus();
});

/// Provider pour les statistiques du dashboard
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final filters = ref.watch(dashboardFiltersProvider);
  // Watch projectsProvider to refresh when data changes
  await ref.watch(projectsProvider.future);

  return await DatabaseService.instance.getDashboardStats(
    secteur: filters.secteur,
    annee: filters.annee,
  );
});

/// Provider pour les projets récents du dashboard (filtrés)
final filteredDashboardProjectsProvider = FutureProvider<List<Projet>>((
  ref,
) async {
  final filters = ref.watch(dashboardFiltersProvider);
  await ref.watch(projectsProvider.future);

  return await DatabaseService.instance.getProjects(
    secteur: filters.secteur,
    dateDebutMin: filters.annee != null ? DateTime(filters.annee!, 1, 1) : null,
    dateDebutMax: filters.annee != null
        ? DateTime(filters.annee!, 12, 31)
        : null,
    orderBy: '${ProjetsColumns.createdAt}',
    ascending: false,
  );
});

// ============================================================================
// CLASSES DE FILTRES
// ============================================================================

/// Filtres pour le tableau de bord
class DashboardFilters {
  final String? secteur;
  final int? annee;

  const DashboardFilters({this.secteur, this.annee});

  DashboardFilters copyWith({String? secteur, int? annee}) {
    return DashboardFilters(
      secteur: secteur ?? this.secteur,
      annee: annee ?? this.annee,
    );
  }

  bool get hasActiveFilters => secteur != null || annee != null;
}

/// Provider pour l'état des filtres du dashboard
final dashboardFiltersProvider = StateProvider<DashboardFilters>((ref) {
  return const DashboardFilters();
});

/// Filtres pour la liste des projets
class ProjectFilters {
  final ProjetStatut? statut;
  final int? bailleurId;
  final String? secteur;
  final DateTime? dateDebutMin;
  final DateTime? dateDebutMax;
  final String? searchQuery;
  final String? orderBy;
  final bool ascending;

  ProjectFilters({
    this.statut,
    this.bailleurId,
    this.secteur,
    this.dateDebutMin,
    this.dateDebutMax,
    this.searchQuery,
    this.orderBy,
    this.ascending = true,
  });

  ProjectFilters copyWith({
    ProjetStatut? statut,
    int? bailleurId,
    String? secteur,
    DateTime? dateDebutMin,
    DateTime? dateDebutMax,
    String? searchQuery,
    String? orderBy,
    bool? ascending,
  }) {
    return ProjectFilters(
      statut: statut ?? this.statut,
      bailleurId: bailleurId ?? this.bailleurId,
      secteur: secteur ?? this.secteur,
      dateDebutMin: dateDebutMin ?? this.dateDebutMin,
      dateDebutMax: dateDebutMax ?? this.dateDebutMax,
      searchQuery: searchQuery ?? this.searchQuery,
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Réinitialiser tous les filtres
  ProjectFilters clear() {
    return ProjectFilters();
  }

  /// Vérifier si des filtres sont actifs
  bool get hasActiveFilters {
    return statut != null ||
        bailleurId != null ||
        secteur != null ||
        dateDebutMin != null ||
        dateDebutMax != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}
