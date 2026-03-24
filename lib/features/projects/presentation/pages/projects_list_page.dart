import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/projet.dart';
import '../../../../core/services/database_service.dart';
import '../providers/project_provider.dart';
import '../providers/bailleur_provider.dart';

/// Page de liste des projets
class ProjectsListPage extends ConsumerWidget {
  const ProjectsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(filteredProjectsProvider);
    final filters = ref.watch(projectFiltersProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statistiques
            _buildHeader(context, statsAsync),

            const SizedBox(height: AppSizes.paddingXL),

            // Filtres et recherche
            _buildFilters(context, ref, filters),

            const SizedBox(height: AppSizes.paddingL),

            // Liste des projets
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildProjectList(context, projects);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Erreur: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<DashboardStats> statsAsync,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Projets',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Suivez et gérez l\'ensemble de vos interventions',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.push('/projects/new');
          },
          icon: const Icon(Icons.add),
          label: const Text('Nouveau Projet'),
        ),
      ],
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    ProjectFilters filters,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              ref
                  .read(projectFiltersProvider.notifier)
                  .update((state) => state.copyWith(searchQuery: value));
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un projet (code, titre)...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        _buildFilterChip(
          context,
          'Tous',
          filters.statut == null,
          () => ref
              .read(projectFiltersProvider.notifier)
              .update((state) => state.copyWith(statut: null)),
        ),
        const SizedBox(width: AppSizes.paddingS),
        ...ProjetStatut.values.map((statut) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingS),
            child: _buildFilterChip(
              context,
              statut.label,
              filters.statut == statut,
              () => ref
                  .read(projectFiltersProvider.notifier)
                  .update(
                    (state) => state.copyWith(
                      statut: state.statut == statut ? null : statut,
                    ),
                  ),
            ),
          );
        }),
        const SizedBox(width: AppSizes.paddingM),
        OutlinedButton.icon(
          onPressed: () => _showFilterDialog(context, ref, filters),
          icon: const Icon(Icons.filter_list),
          label: const Text('Plus de filtres'),
        ),
      ],
    );
  }

  void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    ProjectFilters filters,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filtres Avancés'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secteur d\'Intervention',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    DropdownButtonFormField<String>(
                      value: filters.secteur,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Tous les secteurs'),
                        ),
                        ...[
                          'Éducation',
                          'Santé',
                          'Agriculture',
                          'Environnement',
                          'Infrastructure',
                        ].map(
                          (s) => DropdownMenuItem(value: s, child: Text(s)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          filters = filters.copyWith(secteur: val);
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    const Text(
                      'Bailleur de Fonds',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    ref
                        .watch(bailleursProvider)
                        .when(
                          data: (bailleurs) => DropdownButtonFormField<int>(
                            value: filters.bailleurId,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Tous les bailleurs'),
                              ),
                              ...bailleurs.map(
                                (b) => DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.nom),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                filters = filters.copyWith(bailleurId: val);
                              });
                            },
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) =>
                              const Text('Erreur chargement bailleurs'),
                        ),
                    const SizedBox(height: AppSizes.paddingL),
                    const Text(
                      'Date de Début',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    filters.dateDebutMin ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  filters = filters.copyWith(
                                    dateDebutMin: date,
                                  );
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'De',
                                isDense: true,
                              ),
                              child: Text(
                                filters.dateDebutMin == null
                                    ? 'Choisir'
                                    : '${filters.dateDebutMin!.day}/${filters.dateDebutMin!.month}/${filters.dateDebutMin!.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    filters.dateDebutMax ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  filters = filters.copyWith(
                                    dateDebutMax: date,
                                  );
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'À',
                                isDense: true,
                              ),
                              child: Text(
                                filters.dateDebutMax == null
                                    ? 'Choisir'
                                    : '${filters.dateDebutMax!.day}/${filters.dateDebutMax!.month}/${filters.dateDebutMax!.year}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(projectFiltersProvider.notifier).state =
                        ProjectFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('RÉINITIALISER'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(projectFiltersProvider.notifier).state = filters;
                    Navigator.pop(context);
                  },
                  child: const Text('APPLIQUER'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, List<Projet> projects) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 250,
        crossAxisSpacing: AppSizes.paddingL,
        mainAxisSpacing: AppSizes.paddingL,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final projet = projects[index];
        return _ProjectCard(projet: projet);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Aucun projet trouvé',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Essayez de modifier vos filtres ou créez un nouveau projet',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Projet projet;

  const _ProjectCard({required this.projet});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          context.push('/projects/${projet.id}');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          projet.statut.colorHex.replaceFirst('#', '0xFF'),
                        ),
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      projet.statut.label,
                      style: TextStyle(
                        color: Color(
                          int.parse(
                            projet.statut.colorHex.replaceFirst('#', '0xFF'),
                          ),
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    projet.codeProjet,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                projet.titre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSizes.paddingXS),
                  Text(
                    '${projet.dateDebutPrevue.year} - ${projet.dateFinPrevue.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${projet.budgetTotal.toStringAsFixed(0)} FCFA',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                child: LinearProgressIndicator(
                  value: projet.pourcentageAvancementTemporel / 100,
                  backgroundColor: AppColors.divider,
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avancement',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '${projet.pourcentageAvancementTemporel.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
