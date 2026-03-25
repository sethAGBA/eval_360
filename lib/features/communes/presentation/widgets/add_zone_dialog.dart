import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/commune.dart';
import '../../../../core/models/zone_intervention.dart';
import '../../../../core/services/database_service.dart';

class AddZoneDialog extends StatefulWidget {
  final Commune commune;
  final ZoneIntervention? zone;

  const AddZoneDialog({
    super.key,
    required this.commune,
    this.zone,
  });

  @override
  State<AddZoneDialog> createState() => _AddZoneDialogState();
}

class _AddZoneDialogState extends State<AddZoneDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _populationController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.zone?.villageQuartier);
    _populationController = TextEditingController(text: widget.zone?.populationTotale?.toString());
    _latController = TextEditingController(text: widget.zone?.latitude?.toString());
    _lngController = TextEditingController(text: widget.zone?.longitude?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _populationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final zone = ZoneIntervention(
        id: widget.zone?.id,
        pays: 'Togo', // Par défaut pour ce projet
        region: widget.commune.region,
        provinceDepartement: widget.commune.prefecture,
        communeDistrict: widget.commune.nom,
        villageQuartier: _nameController.text.trim(),
        populationTotale: int.tryParse(_populationController.text),
        latitude: double.tryParse(_latController.text),
        longitude: double.tryParse(_lngController.text),
        communeId: widget.commune.id,
      );

      if (widget.zone == null) {
        await DatabaseService.instance.createZone(zone);
      } else {
        await DatabaseService.instance.updateZone(zone);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.zone != null;

    return AlertDialog(
      title: Text(isEdit ? 'Modifier la Zone' : 'Ajouter une Zone'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du Village / Quartier',
                prefixIcon: Icon(Icons.map),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextFormField(
              controller: _populationController,
              decoration: const InputDecoration(
                labelText: 'Population estimée',
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEdit ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}
