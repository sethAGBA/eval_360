// ignore: depend_on_referenced_packages
// import 'package:eval360/features/projects/presentation/providers/project_provider.dart';
import 'package:eval_360/features/projects/presentation/providers/project_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/export_service.dart';

import '../../../../core/models/tache.dart';
import '../providers/dashboard_providers.dart';

/// Page du tableau de bord principal
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tableau de Bord S&E',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        'Vue d\'ensemble de votre portfolio de projets',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final stats = statsAsync.asData?.value;
                      if (stats == null) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Génération du rapport global...'),
                        ),
                      );

                      try {
                        final projects = await ref.read(
                          projectsProvider.future,
                        );
                        await ExportService.instance.exportGlobalReport(
                          projets: projects,
                          stats: stats,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur d\'export: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Rapport Global'),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Filtres
              _buildDashboardFilters(context, ref),

              const SizedBox(height: AppSizes.paddingXL),

              // Cartes de statistiques
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Projets Actifs',
                      value: stats.activeProjects.toString(),
                      icon: Icons.folder,
                      color: AppColors.primary,
                      trend: stats.totalProjects > 0
                          ? '${((stats.activeProjects / stats.totalProjects) * 100).toStringAsFixed(0)}%'
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Exécution Budgétaire',
                      value: stats.budgetTotal > 0
                          ? '${((stats.budgetExecute / stats.budgetTotal) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      icon: Icons.monetization_on,
                      color: AppColors.success,
                      trend: null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Bénéficiaires',
                      value: stats.totalBeneficiaires >= 1000
                          ? '${(stats.totalBeneficiaires / 1000).toStringAsFixed(1)}K'
                          : stats.totalBeneficiaires.toString(),
                      icon: Icons.people,
                      color: AppColors.info,
                      trend: null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Indicateurs Atteints',
                      value: '${stats.tauxIndicateurs.toStringAsFixed(0)}%',
                      icon: Icons.show_chart,
                      color: AppColors.warning,
                      trend: null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Activités du jour
              _buildActivitiesOfDaySection(context, ref),

              const SizedBox(height: AppSizes.paddingXL),

              // Tâches en attente
              _buildPendingTasksSection(context, ref),

              const SizedBox(height: AppSizes.paddingXL),

              // Alertes critiques
              _buildAlertsSection(context, ref),

              const SizedBox(height: AppSizes.paddingXL),

              // Projets récents
              _buildRecentProjectsSection(
                context,
                ref.watch(filteredDashboardProjectsProvider),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(icon, color: color, size: AppSizes.iconL),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      trend,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesOfDaySection(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesOfTheDayProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: AppColors.primary),
                const SizedBox(width: AppSizes.paddingM),
                Text(
                  'Activités du Jour',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return const Text(
                    'Aucune activité prévue pour aujourd\'hui.',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: activities.take(5).map((act) => ListTile(
                    leading: const Icon(Icons.event_note, color: AppColors.primary),
                    title: Text(act.intitule),
                    subtitle: Text(act.statut.label),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Optionnel: navigation vers l'activité
                    },
                  )).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Erreur: $err', style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasksSection(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(pendingTasksProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_late, color: AppColors.warning),
                    const SizedBox(width: AppSizes.paddingM),
                    Text(
                      'Tâches en Attente',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.go('/tasks'),
                  child: const Text('Voir le Kanban'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Text(
                    'Aucune tâche en attente.',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: tasks.take(5).map((tache) => ListTile(
                    leading: Icon(
                      tache.statut == TacheStatut.aFaire ? Icons.radio_button_unchecked : Icons.hourglass_bottom,
                      color: tache.statut == TacheStatut.aFaire ? AppColors.info : AppColors.primary,
                    ),
                    title: Text(tache.titre),
                    subtitle: Text(tache.statut.label),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/tasks'),
                  )).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Erreur: $err', style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(criticalAlertsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.error),
                const SizedBox(width: AppSizes.paddingM),
                Text(
                  'Alertes Critiques',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return const Text(
                    'Aucune alerte pour l\'instant.',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: alerts.take(5).map((alerte) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
                    child: _buildAlertItem(
                      context,
                      title: alerte.title,
                      description: alerte.description,
                      severity: alerte.severity,
                    ),
                  )).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Erreur: $err', style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardFilters(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(dashboardFiltersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.paddingM),
            const Text(
              'Filtres:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppSizes.paddingL),

            // Filtre par Secteur
            Expanded(
              child: _buildFilterDropdown<String>(
                context: context,
                label: 'Secteur',
                value: filters.secteur,
                items: [
                  'Tous les secteurs',
                  'Éducation',
                  'Santé',
                  'Agriculture',
                  'Environnement',
                  'Infrastructure',
                ],
                onChanged: (val) {
                  ref
                      .read(dashboardFiltersProvider.notifier)
                      .update(
                        (state) => state.copyWith(
                          secteur: val == 'Tous les secteurs' ? null : val,
                        ),
                      );
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),

            // Filtre par Année
            Expanded(
              child: _buildFilterDropdown<int?>(
                context: context,
                label: 'Année',
                value: filters.annee,
                items: [null, 2023, 2024, 2025, 2026],
                onChanged: (val) {
                  ref
                      .read(dashboardFiltersProvider.notifier)
                      .update((state) => state.copyWith(annee: val));
                },
                itemLabel: (val) => val == null ? 'Toutes les années' : '$val',
              ),
            ),

            if (filters.hasActiveFilters) ...[
              const SizedBox(width: AppSizes.paddingM),
              TextButton.icon(
                onPressed: () {
                  ref.invalidate(dashboardFiltersProvider);
                },
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Réinitialiser'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T?)? itemLabel,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel?.call(item) ?? item?.toString() ?? 'Toutes',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAlertItem(
    BuildContext context, {
    required String title,
    required String description,
    required String severity,
  }) {
    Color color;
    IconData icon;

    switch (severity) {
      case 'critical':
        color = AppColors.error;
        icon = Icons.error;
        break;
      case 'warning':
        color = AppColors.warning;
        icon = Icons.warning;
        break;
      default:
        color = AppColors.info;
        icon = Icons.info;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: AppSizes.iconM),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProjectsSection(
    BuildContext context,
    AsyncValue<List<dynamic>> projectsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Projets Récents',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () => context.go('/projects'),
                  child: const Text('Voir tous'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return const Text(
                    'Aucun projet pour le moment. Créez votre premier projet !',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: projects
                      .take(3)
                      .map(
                        (p) => ListTile(
                          leading: const Icon(
                            Icons.folder_open,
                            color: AppColors.primary,
                          ),
                          title: Text(p.titre),
                          subtitle: Text(p.codeProjet),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/projects/${p.id}'),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Erreur: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
