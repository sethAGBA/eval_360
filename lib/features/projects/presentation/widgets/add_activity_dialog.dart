import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/models/cadre_logique.dart';
import '../../../../core/models/zone_intervention.dart';
import '../../../../core/services/database_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/commune.dart';
import '../../../agents/presentation/providers/agent_provider.dart';

class AddActiviteDialog extends ConsumerStatefulWidget {
  final int projectId;
  final Activite? activite;

  const AddActiviteDialog({super.key, required this.projectId, this.activite});

  @override
  ConsumerState<AddActiviteDialog> createState() => _AddActiviteDialogState();
}

class _AddActiviteDialogState extends ConsumerState<AddActiviteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _intituleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _beneficiairesController;
  late TextEditingController _livrablesController;
  late TextEditingController _indicateursReussiteController;
  late TextEditingController _risquesController;
  late TextEditingController _observationsController;
  late TextEditingController _lieuController;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  PrioriteActivite _priorite = PrioriteActivite.moyenne;
  StatutActivite _statut = StatutActivite.planifiee;
  List<int> _selectedCadreLogiqueIds = [];
  List<int> _selectedZoneIds = [];
  List<int> _selectedCommuneIds = [];
  List<int> _selectedAgentIds = [];

  List<CadreLogique> _cadreLogiqueElements = [];
  List<ZoneIntervention> _zones = [];
  List<Commune> _communes = [];
  bool _isLoading = false;

  Color _getNiveauColor(NiveauCadreLogique niveau) {
    switch (niveau) {
      case NiveauCadreLogique.impact:
        return Colors.deepPurple;
      case NiveauCadreLogique.outcome:
        return Colors.blue;
      case NiveauCadreLogique.output:
        return Colors.green;
      case NiveauCadreLogique.activite:
        return Colors.orange;
    }
  }

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
    _livrablesController = TextEditingController(text: widget.activite?.livrables);
    _indicateursReussiteController = TextEditingController(text: widget.activite?.indicateursReussite);
    _risquesController = TextEditingController(text: widget.activite?.risques);
    _observationsController = TextEditingController(text: widget.activite?.observations);
    _lieuController = TextEditingController(text: widget.activite?.lieu);

    if (widget.activite != null) {
      _startDate = widget.activite!.dateDebutPrevue;
      _endDate = widget.activite!.dateFinPrevue;
      _priorite = widget.activite!.priorite;
      _statut = widget.activite!.statut;
      _selectedCadreLogiqueIds = List.from(widget.activite!.cadreLogiqueIds);
      _selectedZoneIds = List.from(widget.activite!.zoneIds);
      _selectedCommuneIds = List.from(widget.activite!.communeIds);
      _selectedAgentIds = List.from(widget.activite!.agentIds);
    }

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = DatabaseService.instance;
      final cadre = await db.getCadreLogiqueByProject(widget.projectId);
      final zones = await db.getZonesByProject(widget.projectId);
      final communes = await db.getCommunes();

      setState(() {
        _cadreLogiqueElements = cadre;
        _zones = zones;
        _communes = communes;
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
    _livrablesController.dispose();
    _indicateursReussiteController.dispose();
    _risquesController.dispose();
    _observationsController.dispose();
    _lieuController.dispose();
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
        cadreLogiqueIds: _selectedCadreLogiqueIds,
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
        livrables: _livrablesController.text.isEmpty ? null : _livrablesController.text,
        indicateursReussite: _indicateursReussiteController.text.isEmpty ? null : _indicateursReussiteController.text,
        risques: _risquesController.text.isEmpty ? null : _risquesController.text,
        observations: _observationsController.text.isEmpty ? null : _observationsController.text,
        lieu: _lieuController.text.isEmpty ? null : _lieuController.text,
        agentIds: _selectedAgentIds,
        zoneIds: _selectedZoneIds,
        communeIds: _selectedCommuneIds,
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
              // Sélection Multi-Cadre Logique
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Éléments du Cadre Logique',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _cadreLogiqueElements.map((e) {
                  final isSelected = _selectedCadreLogiqueIds.contains(e.id!);
                  return FilterChip(
                    label: Text('${e.code}: ${e.libelle}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCadreLogiqueIds.add(e.id!);
                        } else {
                          _selectedCadreLogiqueIds.remove(e.id!);
                        }
                      });
                    },
                    selectedColor: _getNiveauColor(e.niveau).withValues(alpha: 0.2),
                    checkmarkColor: _getNiveauColor(e.niveau),
                  );
                }).toList(),
              ),
              if (_cadreLogiqueElements.isEmpty)
                const Text(
                  'Chargement du cadre logique...',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              const SizedBox(height: AppSizes.paddingM),
              // Sélection Multi-Communes
              const Text(
                'Communes de Rattachament',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _communes.where((c) => c.id != null).map((c) {
                  final isSelected = _selectedCommuneIds.contains(c.id!);
                  return FilterChip(
                    label: Text(c.nom),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCommuneIds.add(c.id!);
                        } else {
                          _selectedCommuneIds.remove(c.id!);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              if (_communes.isEmpty)
                const Text(
                  'Chargement des communes...',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              const SizedBox(height: AppSizes.paddingM),
              const SizedBox(height: AppSizes.paddingM),
              // Sélection Multi-Zones
              const Text(
                'Zones d\'Intervention',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _zones.map((z) {
                  final isSelected = _selectedZoneIds.contains(z.id!);
                  return FilterChip(
                    label: Text(
                      '${z.communeDistrict ?? z.provinceDepartement ?? z.region}',
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedZoneIds.add(z.id!);
                        } else {
                          _selectedZoneIds.remove(z.id!);
                        }
                      });
                    },
                    selectedColor: Colors.teal.withOpacity(0.2),
                    checkmarkColor: Colors.teal,
                  );
                }).toList(),
              ),
              if (_zones.isEmpty)
                const Text(
                  'Chargement des zones...',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
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
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _livrablesController,
                decoration: const InputDecoration(labelText: 'Livrables attendus'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _indicateursReussiteController,
                decoration: const InputDecoration(labelText: 'Indicateurs de réussite'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _risquesController,
                decoration: const InputDecoration(labelText: 'Risques identifiés'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _lieuController,
                decoration: const InputDecoration(labelText: 'Lieu d\'exécution'),
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(labelText: 'Observations'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingL),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Assigner à (Agents)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: AppSizes.paddingS),
              ref.watch(agentsProvider).when(
                data: (agents) => Wrap(
                  spacing: 8,
                  children: agents.map((agent) {
                    final isSelected = _selectedAgentIds.contains(agent.id);
                    return FilterChip(
                      label: Text(agent.nomComplet),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAgentIds.add(agent.id!);
                          } else {
                            _selectedAgentIds.remove(agent.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Erreur agents'),
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
