import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/commune.dart';
import '../../../../core/services/database_service.dart';

class AddCommuneDialog extends StatefulWidget {
  final Commune? commune;

  const AddCommuneDialog({super.key, this.commune});

  @override
  State<AddCommuneDialog> createState() => _AddCommuneDialogState();
}

class _AddCommuneDialogState extends State<AddCommuneDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prefectureController;
  late TextEditingController _contactMaireController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactTelephoneController;
  late TextEditingController _pdcDebutController;
  late TextEditingController _pdcFinController;
  late TextEditingController _documentUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _nbHabitantsController;
  String? _selectedRegion;
  double _tauxAvancement = 0.0;
  bool _isSaving = false;

  final List<String> _regions = ['Maritime', 'Plateaux', 'Centrale', 'Kara', 'Savanes'];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.commune?.nom);
    _prefectureController = TextEditingController(text: widget.commune?.prefecture);
    _contactMaireController = TextEditingController(text: widget.commune?.contactMaire);
    _contactEmailController = TextEditingController(text: widget.commune?.contactEmail);
    _contactTelephoneController = TextEditingController(text: widget.commune?.contactTelephone);
    _pdcDebutController = TextEditingController(text: widget.commune?.pdcPeriodeDebut?.toString());
    _pdcFinController = TextEditingController(text: widget.commune?.pdcPeriodeFin?.toString());
    _documentUrlController = TextEditingController(text: widget.commune?.pdcDocumentUrl);
    _descriptionController = TextEditingController(text: widget.commune?.description);
    _nbHabitantsController = TextEditingController(text: widget.commune?.nbHabitants?.toString());
    _selectedRegion = widget.commune?.region;
    _tauxAvancement = widget.commune?.tauxAvancementPdc ?? 0.0;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prefectureController.dispose();
    _contactMaireController.dispose();
    _contactEmailController.dispose();
    _contactTelephoneController.dispose();
    _pdcDebutController.dispose();
    _pdcFinController.dispose();
    _documentUrlController.dispose();
    _descriptionController.dispose();
    _nbHabitantsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final db = DatabaseService.instance;
      final commune = Commune(
        id: widget.commune?.id,
        nom: _nomController.text.trim(),
        region: _selectedRegion!,
        prefecture: _prefectureController.text.trim(),
        contactMaire: _contactMaireController.text.trim().isEmpty ? null : _contactMaireController.text.trim(),
        contactEmail: _contactEmailController.text.trim().isEmpty ? null : _contactEmailController.text.trim(),
        contactTelephone: _contactTelephoneController.text.trim().isEmpty ? null : _contactTelephoneController.text.trim(),
        pdcPeriodeDebut: int.tryParse(_pdcDebutController.text),
        pdcPeriodeFin: int.tryParse(_pdcFinController.text),
        pdcDocumentUrl: _documentUrlController.text.trim().isEmpty ? null : _documentUrlController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        nbHabitants: int.tryParse(_nbHabitantsController.text),
        tauxAvancementPdc: _tauxAvancement,
        dateDerniereMiseAJour: DateTime.now(),
      );

      if (widget.commune == null) {
        await db.createCommune(commune);
      } else {
        await db.updateCommune(commune);
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
    final isEdit = widget.commune != null;

    return AlertDialog(
      title: Text(isEdit ? 'Modifier la Commune' : 'Ajouter une Commune'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la Commune',
                  hintText: 'ex: Golfe 1, Ogou 1, etc.',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      decoration: const InputDecoration(labelText: 'Région'),
                      items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _selectedRegion = v),
                      validator: (v) => v == null ? 'Champ requis' : null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: _prefectureController,
                      decoration: const InputDecoration(labelText: 'Préfecture'),
                      validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _nbHabitantsController,
                decoration: const InputDecoration(
                  labelText: 'Nombre d\'habitants',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSizes.paddingL),
              const Text('Planning PDC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pdcDebutController,
                      decoration: const InputDecoration(labelText: 'Année Début', hintText: 'ex: 2021'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: _pdcFinController,
                      decoration: const InputDecoration(labelText: 'Année Fin', hintText: 'ex: 2026'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _documentUrlController,
                decoration: const InputDecoration(
                  labelText: 'Lien du document PDC',
                  hintText: 'URL vers le PDF ou drive',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSizes.paddingL),
              const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSizes.paddingS),
              TextFormField(
                controller: _contactMaireController,
                decoration: const InputDecoration(
                  labelText: 'Nom du Maire',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email de contact',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _contactTelephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description / Notes',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              if (isEdit) ...[
                const SizedBox(height: AppSizes.paddingL),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Avancement PDC', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Slider(
                  value: _tauxAvancement,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${_tauxAvancement.round()}%',
                  onChanged: (val) => setState(() => _tauxAvancement = val),
                  activeColor: AppColors.primary,
                ),
              ],
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
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEdit ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}
