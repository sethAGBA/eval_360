import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/donnee_collecte.dart';
import '../../../../core/models/indicateur.dart';
import '../../../../core/services/database_service.dart';
import '../providers/project_provider.dart';
import '../providers/project_detail_providers.dart';

class AddMeasureDialog extends ConsumerStatefulWidget {
  final Indicateur indicateur;

  const AddMeasureDialog({super.key, required this.indicateur});

  @override
  ConsumerState<AddMeasureDialog> createState() => _AddMeasureDialogState();
}

class _AddMeasureDialogState extends ConsumerState<AddMeasureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valeurController = TextEditingController();
  final _commentaireController = TextEditingController();
  final _methodeController = TextEditingController();
  final _sourceController = TextEditingController();

  DateTime _dateCollecte = DateTime.now();

  @override
  void dispose() {
    _valeurController.dispose();
    _commentaireController.dispose();
    _methodeController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateCollecte,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateCollecte) {
      setState(() {
        _dateCollecte = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final donnee = DonneeCollecte(
      indicateurId: widget.indicateur.id!,
      dateCollecte: _dateCollecte,
      valeurMesuree: double.tryParse(_valeurController.text) ?? 0.0,
      commentaireQualitatif: _commentaireController.text.isEmpty
          ? null
          : _commentaireController.text,
      methodeUtilisee: _methodeController.text.isEmpty
          ? null
          : _methodeController.text,
      sourceVerification: _sourceController.text.isEmpty
          ? null
          : _sourceController.text,
      valide: true, // Auto-validé pour le moment pour simplifier
      createdAt: DateTime.now(),
    );

    try {
      await DatabaseService.instance.createDonneeCollecte(donnee);

      // Rafraîchir les providers
      ref.invalidate(indicateursProvider(widget.indicateur.projetId));
      ref.invalidate(projectStatsProvider(widget.indicateur.projetId));

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesure enregistrée avec succès')),
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
          Expanded(
            child: Text(
              'Nouvelle Mesure - ${widget.indicateur.codeIndicateur}',
            ),
          ),
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
              Text(
                widget.indicateur.libelle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valeurController,
                decoration: const InputDecoration(
                  labelText: 'Valeur Mesurée',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.show_chart),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  if (double.tryParse(value) == null) return 'Valeur invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date de Collecte'),
                subtitle: Text(
                  '${_dateCollecte.day}/${_dateCollecte.month}/${_dateCollecte.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentaireController,
                decoration: const InputDecoration(
                  labelText: 'Observations / Commentaires',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Détails Optionnels (S&E)'),
                children: [
                  TextFormField(
                    controller: _methodeController,
                    decoration: const InputDecoration(
                      labelText: 'Méthode utilisée',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _sourceController,
                    decoration: const InputDecoration(
                      labelText: 'Source de vérification',
                    ),
                  ),
                ],
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
        ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
