import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/services/database_service.dart';
import '../providers/project_provider.dart';
import '../providers/project_detail_providers.dart';

class UpdateActivityProgressDialog extends ConsumerStatefulWidget {
  final Activite activite;

  const UpdateActivityProgressDialog({super.key, required this.activite});

  @override
  ConsumerState<UpdateActivityProgressDialog> createState() =>
      _UpdateActivityProgressDialogState();
}

class _UpdateActivityProgressDialogState
    extends ConsumerState<UpdateActivityProgressDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _avancement;
  late TextEditingController _beneficiairesController;

  @override
  void initState() {
    super.initState();
    _avancement = widget.activite.pourcentageAvancement.toDouble();
    _beneficiairesController = TextEditingController(
      text: widget.activite.nombreBeneficiairesAtteints.toString(),
    );
  }

  @override
  void dispose() {
    _beneficiairesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedActivite = widget.activite.copyWith(
      pourcentageAvancement: _avancement.toInt(),
      nombreBeneficiairesAtteints:
          int.tryParse(_beneficiairesController.text) ?? 0,
      updatedAt: DateTime.now(),
      statut: _avancement >= 100
          ? StatutActivite.terminee
          : _avancement > 0
          ? StatutActivite.enCours
          : StatutActivite.planifiee,
    );

    try {
      await DatabaseService.instance.updateActivite(updatedActivite);

      // Rafraîchir les données
      ref.invalidate(activitesProvider(widget.activite.projetId));
      ref.invalidate(projectStatsProvider(widget.activite.projetId));

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Progrès mis à jour')));
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
          const Expanded(child: Text('Mettre à jour le progrès')),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.activite.intitule,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'Avancement: ${_avancement.toInt()}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _avancement,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_avancement.toInt()}%',
                onChanged: (val) => setState(() => _avancement = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _beneficiairesController,
                decoration: const InputDecoration(
                  labelText: 'Bénéficiaires Atteints (réel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  if (int.tryParse(value) == null) return 'Nombre invalide';
                  return null;
                },
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
