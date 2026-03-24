import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/rapport_hebdo.dart';
import '../providers/weekly_report_provider.dart';

/// Page de liste des rapports hebdomadaires
class WeeklyReportsListPage extends ConsumerWidget {
  const WeeklyReportsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(filteredWeeklyReportsProvider);
    final filters = ref.watch(weeklyReportFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(context),

            const SizedBox(height: AppSizes.paddingXL),

            // Filtres
            _buildFilters(context, ref, filters),

            const SizedBox(height: AppSizes.paddingL),

            // Liste des rapports
            Expanded(
              child: reportsAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildReportList(context, reports);
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
              'Rapports Hebdomadaires',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Consultez et gérez vos rapports d\'activités hebdomadaires',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.push('/reports/weekly/new');
          },
          icon: const Icon(Icons.add),
          label: const Text('Nouveau Rapport'),
        ),
      ],
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    WeeklyReportFilters filters,
  ) {
    return Row(
      children: [
        _buildFilterChip(
          context,
          'Tous',
          filters.statut == null,
          () => ref
              .read(weeklyReportFiltersProvider.notifier)
              .update((state) => state.copyWith(statut: null)),
        ),
        const SizedBox(width: AppSizes.paddingS),
        ...StatutValidationRapport.values.map((statut) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingS),
            child: _buildFilterChip(
              context,
              statut.label,
              filters.statut == statut,
              () => ref
                  .read(weeklyReportFiltersProvider.notifier)
                  .update(
                    (state) => state.copyWith(
                      statut: state.statut == statut ? null : statut,
                    ),
                  ),
            ),
          );
        }),
        const Spacer(),
        // Sélection de l'année
        DropdownButton<int>(
          value: filters.annee ?? DateTime.now().year,
          items: [2024, 2025, 2026].map((a) {
            return DropdownMenuItem(value: a, child: Text('Année $a'));
          }).toList(),
          onChanged: (val) {
            ref
                .read(weeklyReportFiltersProvider.notifier)
                .update((state) => state.copyWith(annee: val));
          },
        ),
      ],
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
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildReportList(BuildContext context, List<RapportHebdo> reports) {
    return ListView.separated(
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.paddingM),
      itemBuilder: (context, index) {
        final rapport = reports[index];
        return _ReportCard(rapport: rapport);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            'Aucun rapport trouvé',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          const Text('Commencez par créer votre premier rapport hebdomadaire'),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final RapportHebdo rapport;

  const _ReportCard({required this.rapport});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () => context.push('/reports/weekly/${rapport.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              // Icone de statut
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(
                      rapport.statutValidation.colorHex.replaceFirst('#', '0xFF'),
                    ),
                  ).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(rapport.statutValidation),
                  color: Color(
                    int.parse(
                      rapport.statutValidation.colorHex.replaceFirst('#', '0xFF'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              // Infos rapport
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semaine ${rapport.semaineNumero} - ${rapport.annee}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Du ${dateFormat.format(rapport.dateDebut)} au ${dateFormat.format(rapport.dateFin)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Statut Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(
                      rapport.statutValidation.colorHex.replaceFirst('#', '0xFF'),
                    ),
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                ),
                child: Text(
                  rapport.statutValidation.label,
                  style: TextStyle(
                    color: Color(
                      int.parse(
                        rapport.statutValidation.colorHex.replaceFirst('#', '0xFF'),
                      ),
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(StatutValidationRapport statut) {
    switch (statut) {
      case StatutValidationRapport.brouillon:
        return Icons.edit_note;
      case StatutValidationRapport.enAttente:
        return Icons.hourglass_empty;
      case StatutValidationRapport.valide:
        return Icons.check_circle_outline;
      case StatutValidationRapport.rejete:
        return Icons.error_outline;
    }
  }
}
