import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/projet.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/models/beneficiaire.dart';
import '../providers/project_provider.dart';
import '../providers/bailleur_provider.dart';
import '../../../partenaires/presentation/providers/partenaire_provider.dart';
import '../../../../core/models/partenaire.dart';
import '../providers/zone_provider.dart';

/// Page de formulaire de création ou d'édition de projet (Wizard)
class ProjectFormPage extends ConsumerStatefulWidget {
  final int? projectId;

  const ProjectFormPage({super.key, this.projectId});

  @override
  ConsumerState<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends ConsumerState<ProjectFormPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Form keys pour chaque étape
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  // Contrôleurs pour l'étape 1
  final _titreController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _secteurController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;
  ProjetStatut _statut = ProjetStatut.pipeline;
  List<int> _selectedBailleurIds = [];
  List<int> _selectedPartenaireIds = [];
  List<int> _selectedZoneIds = [];
  List<Beneficiaire> _beneficiaires = [];

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _loadProjectData();
    }
  }

  Future<void> _loadProjectData() async {
    setState(() => _isLoading = true);
    try {
      final db = DatabaseService.instance;
      final projet = await db.getProjectById(widget.projectId!);
      if (projet != null) {
        _titreController.text = projet.titre;
        _codeController.text = projet.codeProjet;
        _descriptionController.text = projet.description ?? '';
        _budgetController.text = projet.budgetTotal.toString();
        _secteurController.text = projet.secteurIntervention;
        _dateDebut = projet.dateDebutPrevue;
        _dateFin = projet.dateFinPrevue;
        _statut = projet.statut;

        // Charger les bailleurs
        final bailleurs = await db.getBailleursByProject(widget.projectId!);
        _selectedBailleurIds = bailleurs.map((b) => b.id!).toList();

        // Charger les partenaires
        final partenaires = await db.getPartenairesByProject(widget.projectId!);
        _selectedPartenaireIds = partenaires.map((p) => p.id!).toList();

        // Charger les zones
        final zones = await db.getZonesByProject(widget.projectId!);
        _selectedZoneIds = zones.map((z) => z.id!).toList();

        // Charger les bénéficiaires
        _beneficiaires = await db.getBeneficiairesByProject(widget.projectId!);
      }
    } catch (e) {
      debugPrint('❌ Error loading project data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _secteurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectId == null
                  ? 'Nouveau Projet'
                  : 'Modifier le Projet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.projectId != null)
              Text(
                'Code: ${_codeController.text}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepCancel: _prevStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: _buildControls,
                steps: [
                  Step(
                    title: const Text('Général'),
                    content: _buildStep1(),
                    isActive: _currentStep >= 0,
                    state: _getStepState(0),
                  ),
                  Step(
                    title: const Text('Bailleurs'),
                    content: _buildStep2(),
                    isActive: _currentStep >= 1,
                    state: _getStepState(1),
                  ),
                  Step(
                    title: const Text('Zones'),
                    content: _buildStep3(),
                    isActive: _currentStep >= 2,
                    state: _getStepState(2),
                  ),
                  Step(
                    title: const Text('Bénéficiaires'),
                    content: _buildStep4(),
                    isActive: _currentStep >= 3,
                    state: _getStepState(3),
                  ),
                ],
              ),
            ),
    );
  }

  StepState _getStepState(int index) {
    if (_currentStep == index) return StepState.editing;
    if (_currentStep > index) return StepState.complete;
    return StepState.indexed;
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    } else {
      _saveProject();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.paddingXL),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: details.onStepContinue,
              child: Text(_currentStep == 3 ? 'TERMINER' : 'CONTINUER'),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: OutlinedButton(
              onPressed: details.onStepCancel,
              child: Text(_currentStep == 0 ? 'ANNULER' : 'RETOUR'),
            ),
          ),
        ],
      ),
    );
  }

  // --- ÉTAPES DU FORMULAIRE ---

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations Générales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingL),
          TextFormField(
            controller: _titreController,
            decoration: const InputDecoration(
              labelText: 'Titre du Projet',
              hintText: 'Ex: Projet de soutien à l\'agriculture',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code Projet',
                    hintText: 'Ex: PRJ-2024-001',
                    prefixIcon: Icon(Icons.tag),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Champ obligatoire'
                      : null,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: DropdownButtonFormField<ProjetStatut>(
                  value: _statut,
                  decoration: const InputDecoration(
                    labelText: 'Statut Initial',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  items: ProjetStatut.values.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s.label));
                  }).toList(),
                  onChanged: (val) => setState(() => _statut = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          TextFormField(
            controller: _secteurController,
            decoration: const InputDecoration(
              labelText: 'Secteur d\'Intervention',
              hintText: 'Ex: Éducation, Santé, Agriculture',
              prefixIcon: Icon(Icons.category),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: AppSizes.paddingM),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Date Début Prévue',
                  selectedDate: _dateDebut,
                  onDateSelected: (date) => setState(() => _dateDebut = date),
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _buildDatePicker(
                  label: 'Date Fin Prévue',
                  selectedDate: _dateFin,
                  onDateSelected: (date) => setState(() => _dateFin = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          TextFormField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Budget Total Estimé (FCFA)',
              prefixIcon: Icon(Icons.monetization_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Champ obligatoire';
              if (double.tryParse(value) == null) return 'Nombre invalide';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onDateSelected(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate == null
              ? 'Sélectionner'
              : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final bailleursAsync = ref.watch(bailleursProvider);

    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partenaires et Bailleurs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingM),
          const Text(
            'Sélectionnez les bailleurs de fonds qui financent ce projet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.paddingL),
          bailleursAsync.when(
            data: (bailleurs) {
              if (bailleurs.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bailleurs de Fonds', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...bailleurs.map((bailleur) {
                    final isSelected = _selectedBailleurIds.contains(bailleur.id);
                    return CheckboxListTile(
                      title: Text(bailleur.nom),
                      subtitle: Text(bailleur.type.label),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedBailleurIds.add(bailleur.id!);
                          } else {
                            _selectedBailleurIds.remove(bailleur.id);
                          }
                        });
                      },
                    );
                  }),
                  const Divider(),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => Text('Erreur Bailleurs: $err'),
          ),
          
          ref.watch(partenairesProvider(true)).when(
            data: (partenaires) {
              if (partenaires.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Partenaires (PTF)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...partenaires.map((p) {
                    final isSelected = _selectedPartenaireIds.contains(p.id);
                    return CheckboxListTile(
                      title: Text(p.nom),
                      subtitle: Text(p.type.label),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedPartenaireIds.add(p.id!);
                          } else {
                            _selectedPartenaireIds.remove(p.id);
                          }
                        });
                      },
                    );
                  }),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => Text('Erreur Partenaires: $err'),
          ),
          
          if ((ref.watch(bailleursProvider).asData?.value.isEmpty ?? true) && 
              (ref.watch(partenairesProvider(true)).asData?.value.isEmpty ?? true))
            const Center(child: Text('Aucun bailleur ou partenaire trouvé.')),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final zonesAsync = ref.watch(zonesProvider);

    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zones d\'Intervention',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingM),
          const Text(
            'Sélectionnez les zones géographiques où le projet sera implémenté.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.paddingL),
          zonesAsync.when(
            data: (zones) {
              if (zones.isEmpty) {
                return const Center(child: Text('Aucune zone trouvée.'));
              }
              return Column(
                children: zones.map((zone) {
                  final isSelected = _selectedZoneIds.contains(zone.id);
                  return CheckboxListTile(
                    title: Text(zone.nomCourt),
                    subtitle: Text(zone.pays),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedZoneIds.add(zone.id!);
                        } else {
                          _selectedZoneIds.remove(zone.id);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Erreur: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Form(
      key: _step4Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Groupes Bénéficiaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addBeneficiaire,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          if (_beneficiaires.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingXL),
                child: Text('Aucun groupe de bénéficiaires défini.'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _beneficiaires.length,
              itemBuilder: (context, index) {
                final b = _beneficiaires[index];
                return Card(
                  child: ListTile(
                    title: Text(b.groupeCible),
                    subtitle: Text('${b.type.label} - ${b.nombrePrevu} prévus'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          setState(() => _beneficiaires.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _addBeneficiaire() {
    final groupController = TextEditingController();
    final countController = TextEditingController();
    BeneficiaireType type = BeneficiaireType.direct;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter des Bénéficiaires'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupController,
                decoration: const InputDecoration(labelText: 'Groupe Cible'),
              ),
              const SizedBox(height: AppSizes.paddingM),
              DropdownButtonFormField<BeneficiaireType>(
                value: type,
                items: BeneficiaireType.values.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.label));
                }).toList(),
                onChanged: (val) => setDialogState(() => type = val!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nombre Prévu'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () {
                if (groupController.text.isNotEmpty) {
                  setState(() {
                    _beneficiaires.add(
                      Beneficiaire(
                        projetId:
                            0, // Sera mis à jour après la création du projet
                        groupeCible: groupController.text,
                        type: type,
                        nombrePrevu: int.tryParse(countController.text) ?? 0,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('AJOUTER'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_step1Key.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = DatabaseService.instance;

      if (widget.projectId != null) {
        // Mode ÉDITION
        final projectId = widget.projectId!;
        final updatedProject = Projet(
          id: projectId,
          codeProjet: _codeController.text,
          titre: _titreController.text,
          description: _descriptionController.text,
          secteurIntervention: _secteurController.text,
          dateDebutPrevue: _dateDebut ?? DateTime.now(),
          dateFinPrevue:
              _dateFin ?? DateTime.now().add(const Duration(days: 365)),
          budgetTotal: double.tryParse(_budgetController.text) ?? 0.0,
          statut: _statut,
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(), // Sera ignoré lors de l'update
        );

        await db.updateProject(updatedProject);

        // Mettre à jour les bailleurs
        await db.updateProjectBailleurs(projectId, _selectedBailleurIds);

        // Mettre à jour les partenaires
        await db.updateProjectPartenaires(projectId, _selectedPartenaireIds);

        // Mettre à jour les zones
        await db.updateProjectZones(projectId, _selectedZoneIds);

        // Mettre à jour les bénéficiaires (Approche simple: supprimer et recréer)
        await db.deleteBeneficiairesByProject(projectId);
        for (final b in _beneficiaires) {
          await db.createBeneficiaire(b.copyWith(projetId: projectId));
        }
      } else {
        // Mode CRÉATION
        final projet = Projet(
          codeProjet: _codeController.text,
          titre: _titreController.text,
          description: _descriptionController.text,
          secteurIntervention: _secteurController.text,
          dateDebutPrevue: _dateDebut ?? DateTime.now(),
          dateFinPrevue:
              _dateFin ?? DateTime.now().add(const Duration(days: 365)),
          budgetTotal: double.tryParse(_budgetController.text) ?? 0.0,
          statut: _statut,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final projectId = await db.createProject(projet);

        // 2. Lier les bailleurs
        for (final bailleurId in _selectedBailleurIds) {
          await db.linkBailleurToProject(
            projetId: projectId,
            bailleurId: bailleurId,
            role: 'Financement',
            montantContribution: 0.0,
            devise: 'FCFA',
          );
        }

        // 2.b Lier les partenaires
        for (final partenaireId in _selectedPartenaireIds) {
          await db.linkPartenaireToProject(
            projetId: projectId,
            partenaireId: partenaireId,
            role: 'Partenaire technique',
          );
        }

        // 3. Lier les zones
        for (final zoneId in _selectedZoneIds) {
          await db.linkZoneToProject(projectId: projectId, zoneId: zoneId);
        }

        // 4. Ajouter les bénéficiaires
        for (final b in _beneficiaires) {
          await db.createBeneficiaire(b.copyWith(projetId: projectId));
        }
      }

      // Refresh providers
      ref.invalidate(projectsProvider);
      if (widget.projectId != null) {
        ref.invalidate(selectedProjectProvider);
        ref.invalidate(projectStatsProvider(widget.projectId!));
        ref.invalidate(projectBailleursProvider(widget.projectId!));
        ref.invalidate(projectPartenairesProvider(widget.projectId!));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.projectId == null
                  ? 'Projet créé avec succès !'
                  : 'Projet mis à jour avec succès !',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
