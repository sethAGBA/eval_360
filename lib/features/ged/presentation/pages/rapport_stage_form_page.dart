import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/document.dart';
import '../../../../core/models/rapport_stage.dart';
import '../../../../core/services/database_service.dart';

class RapportStageFormPage extends ConsumerStatefulWidget {
  const RapportStageFormPage({super.key});

  @override
  ConsumerState<RapportStageFormPage> createState() => _RapportStageFormPageState();
}

class _RapportStageFormPageState extends ConsumerState<RapportStageFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _introController = TextEditingController();
  final _presController = TextEditingController();
  final _actController = TextEditingController();
  final _compController = TextEditingController();
  final _diffController = TextEditingController();
  final _solController = TextEditingController();
  final _clotController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _introController.dispose();
    _presController.dispose();
    _actController.dispose();
    _compController.dispose();
    _diffController.dispose();
    _solController.dispose();
    _clotController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Créer le document dans la GED
      final doc = Document(
        titre: 'Rapport de Stage - ${DateTime.now().year}',
        type: TypeDocument.rapportStage,
        dateDocument: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final docId = await DatabaseService.instance.createDocument(doc);

      // 2. Créer le contenu du rapport
      final rapport = RapportStage(
        documentId: docId,
        introduction: _introController.text,
        presentationStructure: _presController.text,
        activitesRealisees: _actController.text,
        competencesAcquises: _compController.text,
        difficultesRencontrees: _diffController.text,
        solutionsApportees: _solController.text,
        conclusionRecommandations: _clotController.text,
        dateSoumission: DateTime.now(),
      );
      await DatabaseService.instance.createRapportStage(rapport);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapport de stage soumis et archivé dans la GED')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canevas Rapport de Stage'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _submitReport();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                Step(
                  title: const Text('Introduction & Présentation'),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      _buildField(_introController, 'Introduction (Objectifs du stage, contexte)'),
                      const SizedBox(height: 16),
                      _buildField(_presController, 'Présentation de la structure d\'accueil'),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Activités & Compétences'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      _buildField(_actController, 'Activités réalisées durant le stage'),
                      const SizedBox(height: 16),
                      _buildField(_compController, 'Compétences et connaissances acquises'),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Analyse Critique'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    children: [
                      _buildField(_diffController, 'Difficultés rencontrées'),
                      const SizedBox(height: 16),
                      _buildField(_solController, 'Solutions apportées ou suggérées'),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Conclusion'),
                  isActive: _currentStep >= 3,
                  content: _buildField(_clotController, 'Conclusion et Recommandations (pour la CPDSE-CT)'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'Ce champ est requis pour le rapport institutional' : null,
    );
  }
}
