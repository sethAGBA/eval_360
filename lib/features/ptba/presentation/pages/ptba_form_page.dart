import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/plan_travail.dart';
import '../../../../core/services/database_service.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../providers/ptba_list_provider.dart';

class PtbaFormPage extends ConsumerStatefulWidget {
  final int? id; // Si null, c'est une création

  const PtbaFormPage({super.key, this.id});

  @override
  ConsumerState<PtbaFormPage> createState() => _PtbaFormPageState();
}

class _PtbaFormPageState extends ConsumerState<PtbaFormPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedProjetId;
  int _annee = DateTime.now().year;
  StatutPTBA _statut = StatutPTBA.brouillon;

  bool _isLoading = false;
  PlanTravail? _ptbaToEdit;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadPtba();
    }
  }

  Future<void> _loadPtba() async {
    setState(() => _isLoading = true);
    try {
      // Dans DatabaseService il n'y a peut être pas getPlanTravailById,
      // on le cherche dans les globaux
      final db = DatabaseService.instance;
      final ptbas = await db.getAllPlansTravail();
      final ptba = ptbas.firstWhere((p) => p.id == widget.id);

      setState(() {
        _ptbaToEdit = ptba;
        _selectedProjetId = ptba.projetId;
        _annee = ptba.annee;
        _statut = ptba.statut;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur au chargement: $e')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un projet')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = DatabaseService.instance;
      if (_ptbaToEdit == null) {
        // Mode création
        final newPtba = PlanTravail(
          projetId: _selectedProjetId!,
          type: 'annuel',
          annee: _annee,
          dateDebut: DateTime(_annee, 1, 1), // 1er janvier de l'année
          dateFin: DateTime(_annee, 12, 31), // 31 décembre de l'année
          statut: _statut,
          budgetTotal: 0,
          budgetEtat: 0,
          budgetPtf: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await db.createPlanTravail(newPtba);
      } else {
        // Mode édition
        final updated = _ptbaToEdit!.copyWith(
          projetId: _selectedProjetId!,
          annee: _annee,
          statut: _statut,
        );
        await db.updatePlanTravail(updated);
      }

      // Rafraîchir la liste et fermer
      ref.invalidate(ptbaListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PTBA enregistré avec succès')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'enregistrement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.id == null ? 'Nouveau PTBA' : 'Éditer le PTBA'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations Générales',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: AppSizes.paddingL),

                      // Sélection du Projet
                      _buildProjetSelector(),
                      const SizedBox(height: AppSizes.paddingL),

                      // Année
                      TextFormField(
                        initialValue: _annee.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Année du Plan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir une année';
                          }
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed < 2000 || parsed > 2100) {
                            return 'Année invalide';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null) {
                            _annee = parsed;
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingL),

                      // Statut
                      DropdownButtonFormField<StatutPTBA>(
                        value: _statut,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items: StatutPTBA.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _statut = val);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingXL),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('ANNULER'),
                          ),
                          const SizedBox(width: AppSizes.paddingM),
                          ElevatedButton(
                            onPressed: _save,
                            child: const Text('ENREGISTRER'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjetSelector() {
    final projectsAsync = ref.watch(projectsProvider);

    return projectsAsync.when(
      data: (projets) {
        if (projets.isEmpty) {
          return const Text('Aucun projet disponible',
              style: TextStyle(color: AppColors.error));
        }
        return DropdownButtonFormField<int>(
          value: _selectedProjetId,
          decoration: const InputDecoration(
            labelText: 'Projet concerné *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.folder),
          ),
          items: projets.map((p) {
            return DropdownMenuItem(
              value: p.id,
              child: Text('${p.codeProjet} - ${p.titre}',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          validator: (val) => val == null ? 'Requis' : null,
          onChanged: widget.id == null
              ? (val) {
                  setState(() => _selectedProjetId = val);
                }
              : null, // Si on édite, on ne change généralement pas le projet du PTBA
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Erreur de chargement des projets: $err'),
    );
  }
}
