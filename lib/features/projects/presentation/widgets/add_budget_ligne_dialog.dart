import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/budget_ligne.dart';
import '../../../../core/services/database_service.dart';
import '../providers/budget_provider.dart';

class AddBudgetLigneDialog extends ConsumerStatefulWidget {
  final int projetId;

  const AddBudgetLigneDialog({super.key, required this.projetId});

  @override
  ConsumerState<AddBudgetLigneDialog> createState() =>
      _AddBudgetLigneDialogState();
}

class _AddBudgetLigneDialogState extends ConsumerState<AddBudgetLigneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _libelleController = TextEditingController();
  final _montantController = TextEditingController();
  final _anneeController = TextEditingController(
    text: DateTime.now().year.toString(),
  );

  String _selectedCategorie = 'Personnel';
  final List<String> _categories = [
    'Personnel',
    'Équipement',
    'Activités',
    'Logistique',
    'Administration',
    'Autre',
  ];

  @override
  void dispose() {
    _codeController.dispose();
    _libelleController.dispose();
    _montantController.dispose();
    _anneeController.dispose();
    super.dispose();
  }

  Future<void> _saveLigne() async {
    if (!_formKey.currentState!.validate()) return;

    final montant = double.parse(_montantController.text);
    final ligne = BudgetLigne(
      projetId: widget.projetId,
      codeLigne: _codeController.text,
      libelle: _libelleController.text,
      categorie: _selectedCategorie,
      budgetInitial: montant,
      budgetRevise: montant,
      annee: int.parse(_anneeController.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await DatabaseService.instance.createBudgetLigne(ligne);

      // Rafraîchir
      ref.invalidate(projectBudgetLignesProvider(widget.projetId));

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ligne budgétaire créée')));
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
          const Expanded(child: Text('Nouvelle Ligne Budgétaire')),
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
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code Ligne (ex: 1.1.1)',
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _libelleController,
                decoration: const InputDecoration(
                  labelText: 'Libellé / Intitulé',
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategorie,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategorie = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(
                  labelText: 'Montant Initial (FCFA)',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anneeController,
                decoration: const InputDecoration(labelText: 'Année'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatoire' : null,
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
        ElevatedButton(onPressed: _saveLigne, child: const Text('Créer')),
      ],
    );
  }
}
