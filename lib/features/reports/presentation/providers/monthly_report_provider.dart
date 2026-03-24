import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eval_360/core/models/rapport_mensuel.dart';
import 'package:eval_360/core/models/synthese_axe.dart';
import 'package:eval_360/core/services/database_service.dart';
import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// PROVIDERS POUR LES RAPPORTS MENSUELS
// ============================================================================

/// Provider pour récupérer tous les rapports mensuels
final monthlyReportsProvider = FutureProvider<List<RapportMensuel>>((ref) async {
  return await DatabaseService.instance.getMonthlyReports();
});

/// Filtres pour les rapports mensuels
class MonthlyReportFilters {
  final int? agentId;
  final int? annee;

  const MonthlyReportFilters({this.agentId, this.annee});

  MonthlyReportFilters copyWith({int? agentId, int? annee}) {
    return MonthlyReportFilters(
      agentId: agentId ?? this.agentId,
      annee: annee ?? this.annee,
    );
  }
}

/// Provider pour l'état des filtres
final monthlyReportFiltersProvider = StateProvider<MonthlyReportFilters>((ref) {
  return const MonthlyReportFilters();
});

/// Provider pour les rapports filtrés
final filteredMonthlyReportsProvider = FutureProvider<List<RapportMensuel>>((ref) async {
  final filters = ref.watch(monthlyReportFiltersProvider);
  // Watch the base monthlyReportsProvider to ensure refresh when data changes
  await ref.watch(monthlyReportsProvider.future);

  return await DatabaseService.instance.getMonthlyReports(
    agentId: filters.agentId,
    annee: filters.annee,
  );
});

/// Modèle combiné pour un rapport mensuel et ses synthèses d'axes
class MonthlyReportWithSyntheses {
  final RapportMensuel rapport;
  final List<SyntheseAxe> syntheses;

  const MonthlyReportWithSyntheses({required this.rapport, required this.syntheses});
}

/// Provider pour récupérer un rapport mensuel détaillé par ID
final monthlyReportDetailProvider = FutureProvider.family<MonthlyReportWithSyntheses?, int>((ref, id) async {
  final rapport = await DatabaseService.instance.getMonthlyReportById(id);
  if (rapport == null) return null;
  
  final syntheses = await DatabaseService.instance.getSynthesesByRapportId(id);
  return MonthlyReportWithSyntheses(rapport: rapport, syntheses: syntheses);
});
