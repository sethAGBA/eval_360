import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/projet.dart';
import '../../../../core/models/cadre_logique.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/export_service.dart';
import '../providers/project_provider.dart';
import '../providers/bailleur_provider.dart';
import '../providers/project_detail_providers.dart';
import '../providers/budget_provider.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/add_budget_ligne_dialog.dart';
import '../widgets/add_indicator_dialog.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/add_measure_dialog.dart';
import '../widgets/update_activity_progress_dialog.dart';
import '../widgets/add_cadre_logique_dialog.dart';

/// Page de détail d'un projet
class ProjectDetailPage extends ConsumerWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(projectId);
    if (id == null)
      return const Scaffold(body: Center(child: Text('ID invalide')));

    final projectAsync = ref.watch(selectedProjectProvider);
    final statsAsync = ref.watch(projectStatsProvider(id));

    // Force selection of project ID in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedProjectIdProvider.notifier).state = id;
    });

    return projectAsync.when(
      data: (projet) {
        if (projet == null)
          return const Scaffold(body: Center(child: Text('Projet non trouvé')));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projet.titre,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${projet.codeProjet} • ${projet.statut.label}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Exporter le rapport PDF',
                onPressed: () async {
                  final stats = statsAsync.asData?.value;
                  if (stats == null) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Génération du rapport...')),
                  );

                  try {
                    final activites = await ref.read(
                      activitesProvider(id).future,
                    );
                    final indicateurs = await ref.read(
                      indicateursProvider(id).future,
                    );

                    await ExportService.instance.exportProjectReport(
                      projet: projet,
                      stats: stats,
                      activites: activites,
                      indicateurs: indicateurs,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur d\'export: $e')),
                      );
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.paddingM),
                child: IconButton.filledTonal(
                  onPressed: () {
                    context.push('/projects/${projet.id}/edit');
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Modifier le projet',
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.paddingM),

                // Onglets
                DefaultTabController(
                  length: 5,
                  child: Expanded(
                    child: Column(
                      children: [
                        const TabBar(
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Général'),
                            Tab(text: 'Cadre Logique'),
                            Tab(text: 'Indicateurs'),
                            Tab(text: 'Budget'),
                            Tab(text: 'Activités'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildGeneralTab(context, projet, statsAsync),
                              _buildCadreLogiqueTab(context, projet.id!),
                              _buildIndicateursTab(context, projet.id!),
                              _buildBudgetTab(context, projet, statsAsync),
                              _buildActivitesTab(context, projet.id!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Erreur: $err'))),
    );
  }

  Widget _buildGeneralTab(
    BuildContext context,
    Projet projet,
    AsyncValue<ProjectStats> statsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartes de statistiques rapides
          statsAsync.when(
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Avancement Temporel',
                    '${projet.pourcentageAvancementTemporel.toStringAsFixed(1)}%',
                    Icons.timer,
                    AppColors.primary,
                    progress: projet.pourcentageAvancementTemporel / 100,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Budget Consommé',
                    '${(stats.budgetExecute / projet.budgetTotal * 100).toStringAsFixed(1)}%',
                    Icons.account_balance_wallet,
                    Colors.orange,
                    progress: stats.budgetExecute / projet.budgetTotal,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Indicateurs Atteints',
                    '${stats.nombreIndicateursAtteints}/${stats.nombreIndicateurs}',
                    Icons.check_circle,
                    Colors.green,
                    progress: stats.nombreIndicateurs > 0
                        ? stats.nombreIndicateursAtteints /
                              stats.nombreIndicateurs
                        : 0,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Bénéficiaires Atteints',
                    '${stats.nombreBeneficiairesAtteints}/${stats.nombreBeneficiaires}',
                    Icons.people,
                    Colors.purple,
                    progress: stats.nombreBeneficiaires > 0
                        ? stats.nombreBeneficiairesAtteints /
                              stats.nombreBeneficiaires
                        : 0,
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (err, stack) => Text('Erreur stats: $err'),
          ),

          const SizedBox(height: AppSizes.paddingL),

          // Détails du projet
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations de Base',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingM),
                  _buildDetailRow(
                    context,
                    'Période',
                    '${projet.dateDebutPrevue.day}/${projet.dateDebutPrevue.month}/${projet.dateDebutPrevue.year} - ${projet.dateFinPrevue.day}/${projet.dateFinPrevue.month}/${projet.dateFinPrevue.year}',
                  ),
                  _buildDetailRow(
                    context,
                    'Secteur',
                    projet.secteurIntervention,
                  ),
                  _buildDetailRow(
                    context,
                    'Budget Total',
                    '${projet.budgetTotal.toStringAsFixed(0)} FCFA',
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    projet.description ?? 'Aucune description fournie.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingL),

          // Bailleurs (BailleursTab ou section dans Général ?)
          // On va mettre un résumé ici et un onglet dédié si besoin
          _buildBailleursSection(context, projet.id!),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    double? progress,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBailleursSection(BuildContext context, int projectId) {
    return Consumer(
      builder: (context, ref, child) {
        final bailleursAsync = ref.watch(projectBailleursProvider(projectId));
        final partenairesAsync = ref.watch(projectPartenairesProvider(projectId));

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partenaires et Bailleurs',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                
                // Bailleurs section
                bailleursAsync.when(
                  data: (bailleurs) {
                    if (bailleurs.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bailleurs de Fonds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: AppSizes.paddingS),
                        ...bailleurs.map((b) => _buildEntityItem(b.nom, b.type.label, Icons.account_balance)),
                        const SizedBox(height: AppSizes.paddingM),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text('Erreur: $err'),
                ),

                // Partenaires section
                partenairesAsync.when(
                  data: (partenaires) {
                    if (partenaires.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Partenaires Techniques', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: AppSizes.paddingS),
                        ...partenaires.map((p) => _buildEntityItem(p.nom, p.type.label, Icons.handshake)),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text('Erreur: $err'),
                ),

                if ((bailleursAsync.asData?.value.isEmpty ?? true) && 
                    (partenairesAsync.asData?.value.isEmpty ?? true))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                    child: Text('Aucun bailleur ou partenaire enregistré.', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntityItem(String name, String type, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(type, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCadreLogiqueTab(BuildContext context, int projectId) {
    return Consumer(
      builder: (context, ref, child) {
        final cadreAsync = ref.watch(cadreLogiqueProvider(projectId));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Structure du Projet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) =>
                            AddCadreLogiqueDialog(projectId: projectId),
                      );
                      if (result == true) {
                        ref.invalidate(cadreLogiqueProvider(projectId));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: cadreAsync.when(
                data: (elements) {
                  if (elements.isEmpty) {
                    return const Center(
                      child: Text('Aucun élément de cadre logique.'),
                    );
                  }

                  // Trier les éléments par niveau et ordre
                  // En attendant une vraie structure en arbre, on affiche indifféremment
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                    ),
                    itemCount: elements.length,
                    itemBuilder: (context, index) {
                      final item = elements[index];
                      double indentation = 0;
                      switch (item.niveau) {
                        case NiveauCadreLogique.impact:
                          indentation = 0;
                          break;
                        case NiveauCadreLogique.outcome:
                          indentation = 16;
                          break;
                        case NiveauCadreLogique.output:
                          indentation = 32;
                          break;
                        case NiveauCadreLogique.activite:
                          indentation = 48;
                          break;
                      }

                      return Padding(
                        padding: EdgeInsets.only(left: indentation),
                        child: Card(
                          margin: const EdgeInsets.only(
                            bottom: AppSizes.paddingM,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getNiveauColor(
                                item.niveau,
                              ).withValues(alpha: 0.2),
                              child: Text(
                                item.niveau.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: _getNiveauColor(item.niveau),
                                ),
                              ),
                            ),
                            title: Text(
                              '${item.code}: ${item.libelle}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: item.description != null
                                ? Text(
                                    item.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AddCadreLogiqueDialog(
                                        projectId: projectId,
                                        element: item,
                                      ),
                                    );
                                    if (result == true) {
                                      ref.invalidate(
                                        cadreLogiqueProvider(projectId),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmer la suppression'),
                                        content: const Text('Voulez-vous vraiment supprimer cet élément du cadre logique ? Cela peut affecter les activités et indicateurs liés.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await DatabaseService.instance.deleteCadreLogique(item.id!);
                                      ref.invalidate(cadreLogiqueProvider(projectId));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erreur: $err')),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIndicateursTab(BuildContext context, int projectId) {
    return Consumer(
      builder: (context, ref, child) {
        final indicateursAsync = ref.watch(indicateursProvider(projectId));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suivi des Indicateurs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) =>
                            AddIndicateurDialog(projectId: projectId),
                      );
                      if (result == true) {
                        ref.invalidate(indicateursProvider(projectId));
                        ref.invalidate(projectStatsProvider(projectId));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: indicateursAsync.when(
                data: (indicateurs) {
                  if (indicateurs.isEmpty)
                    return const Center(child: Text('Aucun indicateur.'));
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                    ),
                    itemCount: indicateurs.length,
                    itemBuilder: (context, index) {
                      final ind = indicateurs[index];
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppSizes.paddingM,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ind.libelle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${ind.valeurActuelle.toStringAsFixed(ind.valeurActuelle.truncateToDouble() == ind.valeurActuelle ? 0 : 1)} / ${ind.cibleFinale?.toStringAsFixed(ind.cibleFinale?.truncateToDouble() == ind.cibleFinale ? 0 : 1) ?? "0"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value:
                                    ind.cibleFinale != null &&
                                        ind.cibleFinale! > 0
                                    ? (ind.valeurActuelle / ind.cibleFinale!)
                                          .clamp(0.0, 1.0)
                                    : 0,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Niveau: ${ind.niveau.label} - Fréquence: ${ind.frequenceCollecte.label}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) =>
                                            AddMeasureDialog(indicateur: ind),
                                      );
                                      if (result == true) {
                                        ref.invalidate(
                                          indicateursProvider(projectId),
                                        );
                                        ref.invalidate(
                                          projectStatsProvider(projectId),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.add_chart, size: 16),
                                    label: const Text('Collecter'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erreur: $err')),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivitesTab(BuildContext context, int projectId) {
    return Consumer(
      builder: (context, ref, child) {
        final activitesAsync = ref.watch(activitesProvider(projectId));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plan d\'Activités',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) =>
                            AddActiviteDialog(projectId: projectId),
                      );
                      if (result == true) {
                        ref.invalidate(activitesProvider(projectId));
                        ref.invalidate(projectStatsProvider(projectId));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: activitesAsync.when(
                data: (activites) {
                  if (activites.isEmpty) {
                    return const Center(child: Text('Aucune activité.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                    ),
                    itemCount: activites.length,
                    itemBuilder: (context, index) {
                      final task = activites[index];
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppSizes.paddingM,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingM,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  task.intitule,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${task.dateDebutPrevue.day}/${task.dateDebutPrevue.month} - ${task.dateFinPrevue.day}/${task.dateFinPrevue.month}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildStatutChip(task),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final result = await showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              AddActiviteDialog(
                                                projectId: projectId,
                                                activite: task,
                                              ),
                                        );
                                        if (result == true) {
                                          ref.invalidate(activitesProvider(projectId));
                                          ref.invalidate(projectStatsProvider(projectId));
                                        }
                                      },
                                      tooltip: 'Modifier l\'activité',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_note),
                                      onPressed: () async {
                                        final result = await showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              UpdateActivityProgressDialog(
                                                activite: task,
                                              ),
                                        );
                                        if (result == true) {
                                          ref.invalidate(
                                            activitesProvider(projectId),
                                          );
                                          ref.invalidate(
                                            projectStatsProvider(projectId),
                                          );
                                        }
                                      },
                                      tooltip: 'Mettre à jour le progrès',
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value: task.pourcentageAvancement / 100,
                                      backgroundColor: Colors.grey[200],
                                      color: _getStatusColor(task.statut),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Avancement: ${task.pourcentageAvancement}%',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'Bénéficiaires: ${task.nombreBeneficiairesAtteints} / ${task.nombreBeneficiairesCibles}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    if (task.cadreLogiqueIds.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final cadreAsync = ref.watch(cadreLogiqueProvider(projectId));
                                          return cadreAsync.when(
                                            data: (elements) {
                                              final linkedCodes = elements
                                                  .where((e) => task.cadreLogiqueIds.contains(e.id))
                                                  .map((e) => e.code)
                                                  .join(', ');
                                              return Row(
                                                children: [
                                                  const Icon(Icons.account_tree_outlined, size: 14, color: Colors.blueGrey),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Cadre Logique: $linkedCodes',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        fontStyle: FontStyle.italic,
                                                        color: Colors.blueGrey,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            loading: () => const SizedBox.shrink(),
                                            error: (_, __) => const SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                    ],
                                    if (task.zoneIds.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final zonesAsync = ref.watch(zonesProvider(projectId));
                                          return zonesAsync.when(
                                            data: (elements) {
                                              final linkedNames = elements
                                                  .where((e) => task.zoneIds.contains(e.id))
                                                  .map((e) => e.communeDistrict ?? e.provinceDepartement ?? e.region)
                                                  .join(', ');
                                              return Row(
                                                children: [
                                                  const Icon(Icons.map_outlined, size: 14, color: Colors.teal),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Zones: $linkedNames',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        fontStyle: FontStyle.italic,
                                                        color: Colors.teal,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            loading: () => const SizedBox.shrink(),
                                            error: (_, __) => const SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erreur: $err')),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetTab(
    BuildContext context,
    Projet projet,
    AsyncValue<ProjectStats> statsAsync,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final budgetAsync = ref.watch(projectBudgetLignesProvider(projet.id!));
        final consumptionAsync = ref.watch(
          budgetConsumptionProvider(projet.id!),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé financier
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    _buildInfoCard(
                      context,
                      'Budget Global',
                      '${projet.budgetTotal.toStringAsFixed(0)} FCFA',
                      Icons.monetization_on,
                      AppColors.primary,
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    _buildInfoCard(
                      context,
                      'Budget Exécuté',
                      '${stats.budgetExecute.toStringAsFixed(0)} FCFA',
                      Icons.receipt_long,
                      Colors.green,
                      progress: projet.budgetTotal > 0
                          ? stats.budgetExecute / projet.budgetTotal
                          : 0,
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    _buildInfoCard(
                      context,
                      'Budget Restant',
                      '${(projet.budgetTotal - stats.budgetExecute).toStringAsFixed(0)} FCFA',
                      Icons.savings,
                      Colors.blue,
                      progress: projet.budgetTotal > 0
                          ? (1 - (stats.budgetExecute / projet.budgetTotal))
                          : 0,
                    ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => Text('Erreur: $err'),
              ),

              const SizedBox(height: AppSizes.paddingXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lignes Budgétaires',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AddBudgetLigneDialog(projetId: projet.id!),
                      );
                    },
                    icon: const Icon(Icons.add),
                    tooltip: 'Ajouter une ligne',
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),

              budgetAsync.when(
                data: (lignes) {
                  if (lignes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const Text('Aucune ligne budgétaire définie.'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddBudgetLigneDialog(
                                    projetId: projet.id!,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_chart),
                              label: const Text('Ajouter une ligne'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return consumptionAsync.when(
                    data: (consumptionMap) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lignes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSizes.paddingM),
                        itemBuilder: (context, index) {
                          final ligne = lignes[index];
                          final consomme = consumptionMap[ligne.id] ?? 0.0;
                          final ratio = ligne.budgetRevise > 0
                              ? (consomme / ligne.budgetRevise).clamp(0.0, 1.0)
                              : 0.0;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${ligne.codeLigne} - ${ligne.libelle}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${consomme.toStringAsFixed(0)} / ${ligne.budgetRevise.toStringAsFixed(0)} FCFA',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      backgroundColor: Colors.grey[200],
                                      color: ratio > 0.9
                                          ? Colors.red
                                          : ratio > 0.7
                                          ? Colors.orange
                                          : Colors.green,
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text('Erreur: $err'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Erreur: $err'),
              ),

              const SizedBox(height: AppSizes.paddingXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dépenses Récentes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Génération du fichier Excel...'),
                            ),
                          );

                          try {
                            final depenses = await ref.read(
                              projectDepensesProvider(projet.id!).future,
                            );
                            await ExportService.instance.exportExpensesExcel(
                              projet: projet,
                              depenses: depenses,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur d\'export: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.table_view),
                        tooltip: 'Exporter vers Excel',
                        color: Colors.green[700],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          budgetAsync.maybeWhen(
                            data: (lignes) {
                              if (lignes.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Veuillez d\'abord définir des lignes budgétaires.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (context) => AddExpenseDialog(
                                  projetId: projet.id!,
                                  budgetLignes: lignes,
                                ),
                              );
                            },
                            orElse: () {},
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),

              ref
                  .watch(projectDepensesProvider(projet.id!))
                  .when(
                    data: (depenses) {
                      if (depenses.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Aucune dépense enregistrée.'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: depenses.length > 5 ? 5 : depenses.length,
                        itemBuilder: (context, index) {
                          final d = depenses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.red,
                              ),
                            ),
                            title: Text(
                              d.description ?? 'Dépense sans description',
                            ),
                            subtitle: Text(
                              '${d.dateOperation.day}/${d.dateOperation.month}/${d.dateOperation.year} - ${d.typeOperation}',
                            ),
                            trailing: Text(
                              '- ${d.montant.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text('Erreur: $err'),
                  ),
            ],
          ),
        );
      },
    );
  }

  Color _getNiveauColor(NiveauCadreLogique niveau) {
    switch (niveau) {
      case NiveauCadreLogique.impact:
        return Colors.deepPurple;
      case NiveauCadreLogique.outcome:
        return Colors.blue;
      case NiveauCadreLogique.output:
        return Colors.green;
      case NiveauCadreLogique.activite:
        return Colors.orange;
    }
  }

  Widget _buildStatutChip(Activite task) {
    Color color = _getStatusColor(task.statut);
    if (task.estEnRetard) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        task.statut.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(StatutActivite statut) {
    switch (statut) {
      case StatutActivite.planifiee:
        return Colors.grey;
      case StatutActivite.enCours:
        return Colors.blue;
      case StatutActivite.terminee:
        return Colors.green;
      case StatutActivite.retard:
        return Colors.red;
      case StatutActivite.annulee:
        return Colors.blueGrey;
    }
  }
}
