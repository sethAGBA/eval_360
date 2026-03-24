import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/document.dart';
import '../../../../core/models/tdr.dart';
import '../../../../core/services/database_service.dart';
import '../../../projects/presentation/providers/project_provider.dart';

class TdrFormPage extends ConsumerStatefulWidget {
  final int? tdrId;
  const TdrFormPage({super.key, this.tdrId});

  @override
  ConsumerState<TdrFormPage> createState() => _TdrFormPageState();
}

class _TdrFormPageState extends ConsumerState<TdrFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _titreController = TextEditingController();
  final _contexteController = TextEditingController();
  final _objGenController = TextEditingController();
  final _objSpecController = TextEditingController();
  final _resultatsController = TextEditingController();
  final _methodeController = TextEditingController();
  final _lieuController = TextEditingController();
  final _budgetController = TextEditingController();

  int? _selectedProjectId;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: Charger les données si tdrId != null
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contexteController.dispose();
    _objGenController.dispose();
    _objSpecController.dispose();
    _resultatsController.dispose();
    _methodeController.dispose();
    _lieuController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveTdr() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Créer l'entrée Document dans la GED
      final doc = Document(
        titre: _titreController.text,
        type: TypeDocument.tdr,
        projetId: _selectedProjectId,
        dateDocument: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final docId = await DatabaseService.instance.createDocument(doc);

      // 2. Créer l'entrée TdR
      final tdr = TdR(
        documentId: docId,
        contexteJustification: _contexteController.text,
        objectifsGeneraux: _objGenController.text,
        objectifsSpecifiques: _objSpecController.text,
        resultatsAttendus: _resultatsController.text,
        methodologie: _methodeController.text,
        lieuExecution: _lieuController.text,
        budgetEstime: double.tryParse(_budgetController.text) ?? 0,
        dateDebut: _dateDebut,
        dateFin: _dateFin,
      );
      await DatabaseService.instance.createTdR(tdr);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TdR enregistré avec succès dans la GED')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tdrId == null ? 'Nouveau TdR' : 'Édition TdR'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informations Générales'),
                  TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(labelText: 'Titre de l\'activité / TdR *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  projectsAsync.when(
                    data: (projects) => DropdownButtonFormField<int>(
                      value: _selectedProjectId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Projet rattaché'),
                      items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.titre))).toList(),
                      onChanged: (val) => setState(() => _selectedProjectId = val),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Erreur chargement projets'),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSectionTitle('Contenu Technique'),
                  _buildMultilineField(_contexteController, 'Contexte et Justification'),
                  _buildMultilineField(_objGenController, 'Objectif Général'),
                  _buildMultilineField(_objSpecController, 'Objectifs Spécifiques'),
                  _buildMultilineField(_resultatsController, 'Résultats Attendus'),
                  _buildMultilineField(_methodeController, 'Méthodologie d\'exécution'),
                  
                  const SizedBox(height: 16),
                  _buildSectionTitle('Logistique & Budget'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lieuController,
                          decoration: const InputDecoration(labelText: 'Lieu d\'exécution', prefixIcon: Icon(Icons.location_on)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Budget Estimé (FCFA)', prefixIcon: Icon(Icons.money)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTdr,
                      child: const Text('ENREGISTRER ET GÉNÉRER'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildMultilineField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
