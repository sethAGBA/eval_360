import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/models/cadre_logique.dart';
import '../../../../core/models/zone_intervention.dart';
import '../../../../core/services/database_service.dart';

class AddActiviteDialog extends StatefulWidget {
  final int projectId;
  final Activite? activite;

  const AddActiviteDialog({super.key, required this.projectId, this.activite});

  @override
  State<AddActiviteDialog> createState() => _AddActiviteDialogState();
}

class _AddActiviteDialogState extends State<AddActiviteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _intituleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _beneficiairesController;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  PrioriteActivite _priorite = PrioriteActivite.moyenne;
  StatutActivite _statut = StatutActivite.planifiee;
  int? _selectedCadreLogiqueId;
  int? _selectedZoneId;
  int? _selectedResponsableId;

  List<CadreLogique> _cadreLogiqueElements = [];
  List<ZoneIntervention> _zones = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: widget.activite?.codeActivite,
    );
    _intituleController = TextEditingController(
      text: widget.activite?.intitule,
    );
    _descriptionController = TextEditingController(
      text: widget.activite?.description,
    );
    _budgetController = TextEditingController(
      text: widget.activite?.budgetEstime.toString(),
    );
    _beneficiairesController = TextEditingController(
      text: widget.activite?.nombreBeneficiairesCibles.toString(),
    );

    if (widget.activite != null) {
      _startDate = widget.activite!.dateDebutPrevue;
      _endDate = widget.activite!.dateFinPrevue;
      _priorite = widget.activite!.priorite;
      _statut = widget.activite!.statut;
      _selectedCadreLogiqueId = widget.activite!.cadreLogiqueId;
      _selectedZoneId = widget.activite!.zoneId;
      _selectedResponsableId = widget.activite!.responsableId;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = DatabaseService.instance;
      final cadre = await db.getCadreLogiqueByProject(widget.projectId);
      final zones = await db.getZonesByProject(widget.projectId);

      setState(() {
        _cadreLogiqueElements = cadre;
        _zones = zones;
      });
    } catch (e) {
      debugPrint('Error loading data for activity: $e');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _intituleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _beneficiairesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final db = DatabaseService.instance;
      final activite = Activite(
        id: widget.activite?.id,
        projetId: widget.projectId,
        cadreLogiqueId: _selectedCadreLogiqueId,
        codeActivite: _codeController.text,
        intitule: _intituleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        priorite: _priorite,
        statut: _statut,
        dateDebutPrevue: _startDate,
        dateFinPrevue: _endDate,
        budgetEstime: double.tryParse(_budgetController.text) ?? 0.0,
        nombreBeneficiairesCibles:
            int.tryParse(_beneficiairesController.text) ?? 0,
        zoneId: _selectedZoneId,
        responsableId: _selectedResponsableId,
        createdAt: widget.activite?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.activite == null) {
        await db.createActivite(activite);
      } else {
        await db.updateActivite(activite);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              widget.activite == null
                  ? 'Ajouter une Activité'
                  : 'Modifier l\'Activité',
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
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _intituleController,
                decoration: const InputDecoration(labelText: 'Intitulé'),
                validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSizes.paddingM),
              DropdownButtonFormField<int>(
                value: _selectedCadreLogiqueId,
                decoration: const InputDecoration(
                  labelText: 'Lien Cadre Logique',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucun')),
                  ..._cadreLogiqueElements.map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text('${e.code}: ${e.libelle}'),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedCadreLogiqueId = v),
              ),
              const SizedBox(height: AppSizes.paddingM),
              DropdownButtonFormField<int>(
                value: _selectedZoneId,
                decoration: const InputDecoration(
                  labelText: 'Zone Intervenion',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune')),
                  ..._zones.map(
                    (z) => DropdownMenuItem(
                      value: z.id,
                      child: Text(
                        '${z.communeDistrict ?? z.provinceDepartement ?? z.region}',
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedZoneId = v),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PrioriteActivite>(
                      value: _priorite,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: PrioriteActivite.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _priorite = v!),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: DropdownButtonFormField<StatutActivite>(
                      value: _statut,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: StatutActivite.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _statut = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Début Prévu'),
                      subtitle: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      ),
                      onTap: () => _selectDate(context, true),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Fin Prévue'),
                      subtitle: Text(
                        '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                      ),
                      onTap: () => _selectDate(context, false),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Budget Estimé (FCFA)',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: _beneficiairesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bénéficiaires Cibles',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
