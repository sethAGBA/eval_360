import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/document.dart';
import '../../../../core/models/ordre_mission.dart';
import '../../../../core/services/database_service.dart';
import '../../../projects/presentation/providers/project_provider.dart';

class OrdreMissionFormPage extends ConsumerStatefulWidget {
  const OrdreMissionFormPage({super.key});

  @override
  ConsumerState<OrdreMissionFormPage> createState() =>
      _OrdreMissionFormPageState();
}

class _OrdreMissionFormPageState extends ConsumerState<OrdreMissionFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _objetController = TextEditingController();
  final _itineraireController = TextEditingController();
  final _moyenTransportController = TextEditingController(
    text: 'Véhicule de service',
  );
  final _accompagnateursController = TextEditingController();
  final _observationController = TextEditingController();

  int? _selectedProjectId;
  DateTime _dateDepart = DateTime.now();
  DateTime _dateRetour = DateTime.now().add(const Duration(days: 3));
  bool _isLoading = false;

  @override
  void dispose() {
    _objetController.dispose();
    _itineraireController.dispose();
    _moyenTransportController.dispose();
    _accompagnateursController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _saveOrdre() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Créer l'entrée Document dans la GED
      final doc = Document(
        titre: 'Ordre de Mission: ${_objetController.text}',
        type: TypeDocument.ordreMission,
        projetId: _selectedProjectId,
        dateDocument: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final docId = await DatabaseService.instance.createDocument(doc);

      // 2. Créer l'entrée ORD
      final ord = OrdreMission(
        documentId: docId,
        objetMission: _objetController.text,
        itineraires: _itineraireController.text,
        dateDepart: _dateDepart,
        dateRetour: _dateRetour,
        moyenTransport: _moyenTransportController.text,
        accompagnateurs: _accompagnateursController.text,
        observation: _observationController.text,
      );
      await DatabaseService.instance.createOrdreMission(ord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordre de mission enregistré avec succès'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel Ordre de Mission')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Détails de la Mission'),
                    TextFormField(
                      controller: _objetController,
                      decoration: const InputDecoration(
                        labelText: 'Objet de la mission *',
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    projectsAsync.when(
                      data: (projects) => DropdownButtonFormField<int>(
                        value: _selectedProjectId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Projet concerné',
                        ),
                        items: projects
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.titre),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedProjectId = val),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Erreur chargement projets'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itineraireController,
                      decoration: const InputDecoration(
                        labelText: 'Itinéraire (ex: Lomé - Kara - Lomé)',
                      ),
                    ),

                    _buildSectionTitle('Durée & Transport'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDatePicker(
                            'Date de départ',
                            _dateDepart,
                            (d) => setState(() => _dateDepart = d),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDatePicker(
                            'Date de retour',
                            _dateRetour,
                            (d) => setState(() => _dateRetour = d),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _moyenTransportController,
                      decoration: const InputDecoration(
                        labelText: 'Moyen de transport',
                      ),
                    ),

                    _buildSectionTitle('Informations Complémentaires'),
                    TextFormField(
                      controller: _accompagnateursController,
                      decoration: const InputDecoration(
                        labelText: 'Accompagnateurs / Participants',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observationController,
                      decoration: const InputDecoration(
                        labelText: 'Observations particulières',
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveOrdre,
                        child: const Text('GÉNÉRER ORDRE DE MISSION'),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime value,
    Function(DateTime) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onChanged(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(value)),
      ),
    );
  }
}
