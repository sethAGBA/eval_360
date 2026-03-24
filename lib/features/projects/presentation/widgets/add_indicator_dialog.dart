import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/indicateur.dart';
import '../../../../core/models/cadre_logique.dart';
import '../../../../core/services/database_service.dart';

class AddIndicateurDialog extends StatefulWidget {
  final int projectId;
  final Indicateur? indicateur;

  const AddIndicateurDialog({
    super.key,
    required this.projectId,
    this.indicateur,
  });

  @override
  State<AddIndicateurDialog> createState() => _AddIndicateurDialogState();
}

class _AddIndicateurDialogState extends State<AddIndicateurDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _libelleController;
  late TextEditingController _definitionController;
  late TextEditingController _uniteController;
  late TextEditingController _baselineController;
  late TextEditingController _cibleController;

  NiveauIndicateur _niveau = NiveauIndicateur.output;
  TypeIndicateur _type = TypeIndicateur.quantitatif;
  FrequenceCollecte _frequence = FrequenceCollecte.trimestrielle;
  int? _selectedCadreLogiqueId;
  List<CadreLogique> _cadreLogiqueElements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: widget.indicateur?.codeIndicateur,
    );
    _libelleController = TextEditingController(
      text: widget.indicateur?.libelle,
    );
    _definitionController = TextEditingController(
      text: widget.indicateur?.definition,
    );
    _uniteController = TextEditingController(
      text: widget.indicateur?.uniteMesure,
    );
    _baselineController = TextEditingController(
      text: widget.indicateur?.baseline?.toString(),
    );
    _cibleController = TextEditingController(
      text: widget.indicateur?.cibleFinale?.toString(),
    );

    if (widget.indicateur != null) {
      _niveau = widget.indicateur!.niveau;
      _type = widget.indicateur!.type;
      _frequence = widget.indicateur!.frequenceCollecte;
      _selectedCadreLogiqueId = widget.indicateur!.cadreLogiqueId;
    }

    _loadCadreLogique();
  }

  Future<void> _loadCadreLogique() async {
    try {
      final elements = await DatabaseService.instance.getCadreLogiqueByProject(
        widget.projectId,
      );
      setState(() {
        _cadreLogiqueElements = elements;
        // Si on édite et que l'élément n'est plus dans la liste (rare), on reset
        if (_selectedCadreLogiqueId != null &&
            !elements.any((e) => e.id == _selectedCadreLogiqueId)) {
          _selectedCadreLogiqueId = null;
        }
      });
    } catch (e) {
      debugPrint('Error loading cadre logique: $e');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _libelleController.dispose();
    _definitionController.dispose();
    _uniteController.dispose();
    _baselineController.dispose();
    _cibleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final db = DatabaseService.instance;
      final indicateur = Indicateur(
        id: widget.indicateur?.id,
        projetId: widget.projectId,
        cadreLogiqueId: _selectedCadreLogiqueId,
        codeIndicateur: _codeController.text,
        libelle: _libelleController.text,
        definition: _definitionController.text.isEmpty
            ? null
            : _definitionController.text,
        niveau: _niveau,
        type: _type,
        uniteMesure: _uniteController.text.isEmpty
            ? null
            : _uniteController.text,
        baseline: double.tryParse(_baselineController.text),
        cibleFinale: double.tryParse(_cibleController.text),
        frequenceCollecte: _frequence,
        createdAt: widget.indicateur?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.indicateur == null) {
        await db.createIndicateur(indicateur);
      } else {
        await db.updateIndicateur(indicateur);
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
              widget.indicateur == null
                  ? 'Ajouter un Indicateur'
                  : 'Modifier l\'Indicateur',
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
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'ex: IND-01',
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _libelleController,
                decoration: const InputDecoration(labelText: 'Libellé'),
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
              DropdownButtonFormField<NiveauIndicateur>(
                value: _niveau,
                decoration: const InputDecoration(labelText: 'Niveau'),
                items: NiveauIndicateur.values
                    .map(
                      (n) => DropdownMenuItem(value: n, child: Text(n.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _niveau = v!),
              ),
              const SizedBox(height: AppSizes.paddingM),
              DropdownButtonFormField<TypeIndicateur>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TypeIndicateur.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _uniteController,
                      decoration: const InputDecoration(labelText: 'Unité'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: DropdownButtonFormField<FrequenceCollecte>(
                      value: _frequence,
                      decoration: const InputDecoration(labelText: 'Fréquence'),
                      items: FrequenceCollecte.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _frequence = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _baselineController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Valeur de base',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: TextFormField(
                      controller: _cibleController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cible finale',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _definitionController,
                decoration: const InputDecoration(
                  labelText: 'Définition / Notes',
                ),
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
