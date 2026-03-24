import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eval_360/core/models/rapport_hebdo.dart';
import 'package:eval_360/core/models/rapport_mensuel.dart';
import 'package:eval_360/features/reports/presentation/providers/monthly_report_provider.dart';
import 'package:eval_360/core/services/database_service.dart';

class MonthlyReportsListPage extends ConsumerWidget {
  const MonthlyReportsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(filteredMonthlyReportsProvider);
    final filters = ref.watch(monthlyReportFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports Mensuels d\'Activités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(monthlyReportsProvider),
          ),
          ElevatedButton.icon(
            onPressed: () => _showConsolidateDialog(context, ref),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Générer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ).paddingOnly(right: 16),
        ],
      ),
      body: Column(
        children: [
          // Barre de filtres
          _buildFilterBar(context, ref, filters),
          
          // Liste
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aucun rapport mensuel trouvé.'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportCard(context, ref, report);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, MonthlyReportFilters filters) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          // Filtre Année
          DropdownButton<int>(
            hint: const Text('Année'),
            value: filters.annee,
            items: [2024, 2025, 2026].map((int annee) {
              return DropdownMenuItem<int>(
                value: annee,
                child: Text(annee.toString()),
              );
            }).toList(),
            onChanged: (val) {
              ref.read(monthlyReportFiltersProvider.notifier).state = 
                  filters.copyWith(annee: val);
            },
          ),
          const SizedBox(width: 16),
          if (filters.annee != null)
            TextButton(
              onPressed: () {
                ref.read(monthlyReportFiltersProvider.notifier).state = 
                    const MonthlyReportFilters();
              },
              child: const Text('Réinitialiser'),
            ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, WidgetRef ref, RapportMensuel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(report.statutValidation).withOpacity(0.1),
          child: Icon(Icons.calendar_month, color: _getStatusColor(report.statutValidation)),
        ),
        title: Text('${report.moisNom} ${report.annee}'),
        subtitle: Text('Taux de réalisation global: ${report.tauxRealisationGlobal.toStringAsFixed(1)}%'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(report.statutValidation).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusLabel(report.statutValidation),
            style: TextStyle(
              color: _getStatusColor(report.statutValidation),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => context.push('/reports/monthly/${report.id}'),
      ),
    );
  }

  Color _getStatusColor(StatutValidationRapport statut) {
    switch (statut) {
      case StatutValidationRapport.brouillon: return Colors.grey;
      case StatutValidationRapport.enAttente: return Colors.orange;
      case StatutValidationRapport.valide: return Colors.green;
      case StatutValidationRapport.rejete: return Colors.red;
    }
  }

  String _getStatusLabel(StatutValidationRapport statut) {
    switch (statut) {
      case StatutValidationRapport.brouillon: return 'Brouillon';
      case StatutValidationRapport.enAttente: return 'En attente';
      case StatutValidationRapport.valide: return 'Validé';
      case StatutValidationRapport.rejete: return 'Rejeté';
    }
  }

  Future<void> _showConsolidateDialog(BuildContext context, WidgetRef ref) async {
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Générer le rapport mensuel'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sélectionnez le mois pour lequel vous souhaitez consolider les rapports hebdomadaires.'),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (i) => i + 1).map((m) {
                      return DropdownMenuItem(value: m, child: Text(DateFormat('MMMM', 'fr_FR').format(DateTime(2024, m))));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedMonth = val!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    items: [2024, 2025, 2026].map((y) {
                      return DropdownMenuItem(value: y, child: Text(y.toString()));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedYear = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      Navigator.pop(context);
                      // On utilise l'agent ID 1 pour la démo ou on récupère l'id de l'user connecté
                      final id = await DatabaseService.instance.consolidateMonthlyReport(1, selectedMonth, selectedYear);
                      ref.invalidate(monthlyReportsProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rapport mensuel généré avec succès !')),
                      );
                      context.push('/reports/monthly/$id');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Générer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

extension PaddingExtension on Widget {
  Widget paddingOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    return Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);
  }
}
