import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/depense.dart';
import '../providers/budget_global_provider.dart';

class AllExpensesPage extends ConsumerWidget {
  const AllExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depensesAsync = ref.watch(allDepensesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Répertoire des Dépenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allDepensesProvider),
          ),
        ],
      ),
      body: depensesAsync.when(
        data: (depenses) => _buildExpensesList(context, ref, depenses),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildExpensesList(BuildContext context, WidgetRef ref, List<Depense> depenses) {
    if (depenses.isEmpty) {
      return const Center(child: Text('Aucune dépense enregistrée.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: depenses.length,
      itemBuilder: (context, index) {
        final d = depenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
          child: ListTile(
            leading: _buildStatusIcon(d.statutValidation),
            title: Text(d.description ?? 'Dépense #${d.id}'),
            subtitle: Text(
              '${d.dateOperation.day}/${d.dateOperation.month}/${d.dateOperation.year} • ${d.fournisseurPrestataire ?? "Divers"} • ${d.modePaiement.label}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${d.montant.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildStatusChip(d.statutValidation),
              ],
            ),
            onTap: () => _showValidationDialog(context, ref, d),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(StatutValidationDepense statut) {
    IconData icon;
    Color color;
    switch (statut) {
      case StatutValidationDepense.enAttente:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case StatutValidationDepense.approuveTechnique:
        icon = Icons.fact_check;
        color = Colors.blue;
        break;
      case StatutValidationDepense.approuveFinancier:
        icon = Icons.verified;
        color = Colors.indigo;
        break;
      case StatutValidationDepense.paye:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case StatutValidationDepense.rejete:
        icon = Icons.cancel;
        color = Colors.red;
        break;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(StatutValidationDepense statut) {
    Color color;
    switch (statut) {
      case StatutValidationDepense.enAttente: color = Colors.orange; break;
      case StatutValidationDepense.approuveTechnique: color = Colors.blue; break;
      case StatutValidationDepense.approuveFinancier: color = Colors.indigo; break;
      case StatutValidationDepense.paye: color = Colors.green; break;
      case StatutValidationDepense.rejete: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statut.label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showValidationDialog(BuildContext context, WidgetRef ref, Depense depense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation de la Dépense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Référence: ${depense.numeroPiece}'),
            Text('Montant: ${depense.montant.toStringAsFixed(0)} FCFA'),
            const SizedBox(height: 16),
            const Text('Changer le statut vers:'),
          ],
        ),
        actions: [
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => _updateStatus(context, ref, depense.id!, StatutValidationDepense.rejete),
                child: const Text('Rejeter', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () => _updateStatus(context, ref, depense.id!, StatutValidationDepense.approuveTechnique),
                child: const Text('Approuver Tech.'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => _updateStatus(context, ref, depense.id!, StatutValidationDepense.paye),
                child: const Text('Marquer Payé'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, int id, StatutValidationDepense status) async {
    Navigator.pop(context);
    await ref.read(depenseActionProvider.notifier).updateStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour : ${status.label}')),
      );
    }
  }
}
