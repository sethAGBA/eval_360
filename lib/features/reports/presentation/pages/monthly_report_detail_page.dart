import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eval_360/core/models/rapport_hebdo.dart';
import 'package:eval_360/core/models/rapport_mensuel.dart';
import 'package:eval_360/core/models/synthese_axe.dart';
import 'package:eval_360/features/reports/presentation/providers/monthly_report_provider.dart';

class MonthlyReportDetailPage extends ConsumerWidget {
  final int reportId;

  const MonthlyReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(monthlyReportDetailProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Rapport Mensuel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Export PDF logic here later
            },
          ),
        ],
      ),
      body: detailAsync.when(
        data: (data) {
          if (data == null) return const Center(child: Text('Rapport introuvable.'));
          return _buildContent(context, data.rapport, data.syntheses);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RapportMensuel report, List<SyntheseAxe> syntheses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entête avec résumé global
          _buildHeader(context, report),
          const SizedBox(height: 24),
          
          // Performance par Axe
          Text(
            'Performance par Axe Stratégique',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...syntheses.map((s) => _buildAxisCard(context, s)),
          
          const SizedBox(height: 24),
          
          // Section validation (si brouillon)
          if (report.statutValidation == StatutValidationRapport.brouillon)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Action pour soumettre à validation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Soumettre pour validation'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RapportMensuel report) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${report.moisNom} ${report.annee}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text('Rapport de synthèse mensuel'),
                  ],
                ),
                _buildStatusChip(report.statutValidation),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Taux Global', '${report.tauxRealisationGlobal.toStringAsFixed(1)}%', Colors.blue),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                _buildStatItem(context, 'Mois', report.mois.toString().padLeft(2, '0'), Colors.orange),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                _buildStatItem(context, 'Année', report.annee.toString(), Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAxisCard(BuildContext context, SyntheseAxe synthese) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    synthese.libelleAxe,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  '${synthese.tauxRealisation.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(synthese.tauxRealisation),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: synthese.tauxRealisation / 100,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(synthese.tauxRealisation)),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  '${synthese.nombreActivitesRealisees} / ${synthese.nombreActivitesPrevues} activités réalisées',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatusChip(StatutValidationRapport statut) {
    Color color = Colors.grey;
    String label = 'Brouillon';
    
    switch (statut) {
      case StatutValidationRapport.brouillon: color = Colors.grey; label = 'Brouillon'; break;
      case StatutValidationRapport.enAttente: color = Colors.orange; label = 'En attente'; break;
      case StatutValidationRapport.valide: color = Colors.green; label = 'Validé'; break;
      case StatutValidationRapport.rejete: color = Colors.red; label = 'Rejeté'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
