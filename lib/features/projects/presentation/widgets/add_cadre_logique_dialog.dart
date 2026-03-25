import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/cadre_logique.dart';
import '../../../../core/services/database_service.dart';

class AddCadreLogiqueDialog extends StatefulWidget {
  final int projectId;
  final CadreLogique? element;

  const AddCadreLogiqueDialog({
    super.key,
    required this.projectId,
    this.element,
  });

  @override
  State<AddCadreLogiqueDialog> createState() => _AddCadreLogiqueDialogState();
}

class _AddCadreLogiqueDialogState extends State<AddCadreLogiqueDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _libelleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hypothesesController;
  late TextEditingController _moyensController;
  late TextEditingController _ordreController;

  NiveauCadreLogique _niveau = NiveauCadreLogique.outcome;
  int? _selectedParentId;
  List<CadreLogique> _allElements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.element?.code);
    _libelleController = TextEditingController(text: widget.element?.libelle);
    _descriptionController = TextEditingController(text: widget.element?.description);
    _hypothesesController = TextEditingController(text: widget.element?.hypothesesRisques);
    _moyensController = TextEditingController(text: widget.element?.moyensVerification);
    _ordreController = TextEditingController(text: widget.element?.ordre.toString() ?? '0');

    if (widget.element != null) {
      _niveau = widget.element!.niveau;
      _selectedParentId = widget.element!.parentId;
    }

    _loadElements();
  }

  Future<void> _loadElements() async {
    try {
      final elements = await DatabaseService.instance.getCadreLogiqueByProject(
        widget.projectId,
      );
      setState(() {
        _allElements = elements;
      });
    } catch (e) {
      debugPrint('Error loading cadre logique elements: $e');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _libelleController.dispose();
    _descriptionController.dispose();
    _hypothesesController.dispose();
    _moyensController.dispose();
    _ordreController.dispose();
    super.dispose();
  }

  List<CadreLogique> _getPotentialParents() {
    switch (_niveau) {
      case NiveauCadreLogique.impact:
        return [];
      case NiveauCadreLogique.outcome:
        return _allElements.where((e) => e.niveau == NiveauCadreLogique.impact).toList();
      case NiveauCadreLogique.output:
        return _allElements.where((e) => e.niveau == NiveauCadreLogique.outcome).toList();
      case NiveauCadreLogique.activite:
        return _allElements.where((e) => e.niveau == NiveauCadreLogique.output).toList();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final db = DatabaseService.instance;
      final element = CadreLogique(
        id: widget.element?.id,
        projetId: widget.projectId,
        niveau: _niveau,
        code: _codeController.text,
        libelle: _libelleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        parentId: _selectedParentId,
        ordre: int.tryParse(_ordreController.text) ?? 0,
        hypothesesRisques: _hypothesesController.text.isEmpty ? null : _hypothesesController.text,
        moyensVerification: _moyensController.text.isEmpty ? null : _moyensController.text,
        createdAt: widget.element?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.element == null) {
        await db.createCadreLogique(element);
      } else {
        await db.updateCadreLogique(element);
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
    final potentialParents = _getPotentialParents();

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.element == null
                  ? 'Ajouter au Cadre Logique'
                  : 'Modifier l\'élément',
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
              DropdownButtonFormField<NiveauCadreLogique>(
                value: _niveau,
                decoration: const InputDecoration(labelText: 'Niveau'),
                items: NiveauCadreLogique.values
                    .map((n) => DropdownMenuItem(value: n, child: Text(n.label)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _niveau = v!;
                    _selectedParentId = null; // Reset parent on level change
                  });
                },
              ),
              const SizedBox(height: AppSizes.paddingM),
              if (potentialParents.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  value: _selectedParentId,
                  decoration: const InputDecoration(labelText: 'Élément Parent'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Aucun')),
                    ...potentialParents.map(
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text('${e.code}: ${e.libelle}'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedParentId = v),
                ),
                const SizedBox(height: AppSizes.paddingM),
              ],
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code (ex: R1, P1.1)'),
                validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _libelleController,
                decoration: const InputDecoration(labelText: 'Libellé'),
                validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _ordreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ordre'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _hypothesesController,
                decoration: const InputDecoration(labelText: 'Hypothèses & Risques'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingM),
              TextFormField(
                controller: _moyensController,
                decoration: const InputDecoration(labelText: 'Moyens de vérification'),
                maxLines: 2,
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
