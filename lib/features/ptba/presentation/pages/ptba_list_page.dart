import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/plan_travail.dart';
import '../providers/ptba_list_provider.dart';
import '../../../projects/presentation/providers/project_provider.dart';

class PtbaListPage extends ConsumerWidget {
  const PtbaListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ptbaListAsync = ref.watch(ptbaListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSizes.paddingXL),
            Expanded(
              child: ptbaListAsync.when(
                data: (ptbas) {
                  if (ptbas.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildPtbaList(context, ptbas);
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planification / PTBA',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Gérez les Plans de Travail Annuels et leurs matrices',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.push('/ptba/new');
          },
          icon: const Icon(Icons.add),
          label: const Text('Nouveau PTBA'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_calendar_rounded,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Aucun PTBA trouvé',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Créez un nouveau Plan de Travail Annuel pour un projet',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPtbaList(BuildContext context, List<PlanTravail> ptbas) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 200,
        crossAxisSpacing: AppSizes.paddingL,
        mainAxisSpacing: AppSizes.paddingL,
      ),
      itemCount: ptbas.length,
      itemBuilder: (context, index) {
        final ptba = ptbas[index];
        return _PtbaCard(ptba: ptba);
      },
    );
  }
}

class _PtbaCard extends ConsumerWidget {
  final PlanTravail ptba;

  const _PtbaCard({required this.ptba});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final projectName = projectsAsync.when(
      data: (projets) {
        final match = projets.where((p) => p.id == ptba.projetId).firstOrNull;
        return match?.titre ?? 'Projet #${ptba.projetId}';
      },
      loading: () => 'Chargement projet...',
      error: (_, __) => 'Erreur projet',
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          context.push('/ptba/${ptba.id}');
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      'Année ${ptba.annee}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(ptba.statut),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                projectName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Divider(),
              const SizedBox(height: AppSizes.paddingXS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Total',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        '${ptba.budgetTotal.toStringAsFixed(0)} FCFA',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StatutPTBA statut) {
    Color color;
    switch (statut) {
      case StatutPTBA.brouillon:
        color = Colors.grey;
      case StatutPTBA.en_attente:
        color = Colors.orange;
      case StatutPTBA.valide:
        color = Colors.green;
      case StatutPTBA.cloture:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        statut.label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
