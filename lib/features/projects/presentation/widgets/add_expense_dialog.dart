import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/depense.dart';
import '../../../../core/models/budget_ligne.dart';
import '../../../../core/services/database_service.dart';
import '../providers/budget_provider.dart';
import '../providers/project_provider.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  final int projetId;
  final List<BudgetLigne> budgetLignes;

  const AddExpenseDialog({
    super.key,
    required this.projetId,
    required this.budgetLignes,
  });

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  final _fournisseurController = TextEditingController();

  BudgetLigne? _selectedLigne;
  DateTime _selectedDate = DateTime.now();
  ModePaiement _selectedMode = ModePaiement.especes;
  String _typeOperation = 'Dépense Directe';

  @override
  void initState() {
    super.initState();
    if (widget.budgetLignes.isNotEmpty) {
      _selectedLigne = widget.budgetLignes.first;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    _fournisseurController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || _selectedLigne == null) return;

    final depense = Depense(
      projetId: widget.projetId,
      budgetLigneId: _selectedLigne!.id!,
      typeOperation: _typeOperation,
      numeroPiece: 'EXP-${DateTime.now().millisecondsSinceEpoch}',
      dateOperation: _selectedDate,
      montant: double.parse(_montantController.text),
      description: _descriptionController.text,
      fournisseurPrestataire: _fournisseurController.text,
      modePaiement: _selectedMode,
      statutValidation: StatutValidationDepense.enAttente,
      createdAt: DateTime.now(),
    );

    try {
      await DatabaseService.instance.createDepense(depense);

      // Invalider les providers pour rafraîchir l'UI
      ref.invalidate(projectDepensesProvider(widget.projetId));
      ref.invalidate(budgetConsumptionProvider(widget.projetId));
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dépense enregistrée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Text('Enregistrer une dépense')),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<BudgetLigne>(
                value: _selectedLigne,
                decoration: const InputDecoration(
                  labelText: 'Ligne Budgétaire',
                ),
                items: widget.budgetLignes.map((ligne) {
                  return DropdownMenuItem(
                    value: ligne,
                    child: Text('${ligne.codeLigne} - ${ligne.libelle}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedLigne = value),
                validator: (value) => value == null ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA)',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date de l\'opération'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description / Libellé',
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fournisseurController,
                decoration: const InputDecoration(
                  labelText: 'Fournisseur / Bénéficiaire',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ModePaiement>(
                value: _selectedMode,
                decoration: const InputDecoration(
                  labelText: 'Mode de Paiement',
                ),
                items: ModePaiement.values.map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode.label));
                }).toList(),
                onChanged: (value) => setState(() => _selectedMode = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
