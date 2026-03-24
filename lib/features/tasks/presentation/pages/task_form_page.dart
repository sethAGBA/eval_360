import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/tache.dart';
import '../providers/task_provider.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  final int? taskId;

  const TaskFormPage({super.key, this.taskId});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormState {
  String titre = '';
  String description = '';
  TachePriorite priorite = TachePriorite.moyenne;
  TacheStatut statut = TacheStatut.aFaire;
  DateTime? dateEcheance;
  double porcentageAvancement = 0.0;
  int? activiteId;
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late _TaskFormState _state;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _state = _TaskFormState();
  }

  void _initializeFromTache(Tache tache) {
    if (_isInitialized) return;
    _state.titre = tache.titre;
    _state.description = tache.description ?? '';
    _state.priorite = tache.priorite;
    _state.statut = tache.statut;
    _state.dateEcheance = tache.dateEcheance;
    _state.porcentageAvancement = tache.pourcentageAvancement;
    _state.activiteId = tache.activiteId;
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;
    
    if (isEditing) {
      final tacheAsync = ref.watch(taskDetailProvider(widget.taskId!));
      return tacheAsync.when(
        data: (tache) {
          if (tache != null) {
            _initializeFromTache(tache);
          }
          return _buildForm(context, isEditing);
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Erreur: $err'))),
      );
    }

    return _buildForm(context, isEditing);
  }

  Widget _buildForm(BuildContext context, bool isEditing) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la Tâche' : 'Nouvelle Tâche'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _state.titre,
                decoration: const InputDecoration(
                  labelText: 'Titre de la tâche *',
                  hintText: 'Ex: Préparer les TdR de la mission...',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => _state.titre = val!,
              ),
              const SizedBox(height: AppSizes.paddingL),
              TextFormField(
                initialValue: _state.description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                onSaved: (val) => _state.description = val ?? '',
              ),
              const SizedBox(height: AppSizes.paddingL),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TachePriorite>(
                      value: _state.priorite,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: TachePriorite.values.map((p) => DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            _buildPriorityDot(p),
                            const SizedBox(width: 8),
                            Text(p.label),
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => _state.priorite = val!),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingL),
                  Expanded(
                    child: DropdownButtonFormField<TacheStatut>(
                      value: _state.statut,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: TacheStatut.values.map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      )).toList(),
                      onChanged: (val) => setState(() => _state.statut = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingL),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date d\'échéance'),
                subtitle: Text(_state.dateEcheance == null 
                  ? 'Non définie' 
                  : DateFormat('dd/MM/yyyy').format(_state.dateEcheance!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _state.dateEcheance ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) {
                    setState(() => _state.dateEcheance = picked);
                  }
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
              Text('Avancement: ${_state.porcentageAvancement.toInt()}%'),
              Slider(
                value: _state.porcentageAvancement,
                min: 0,
                max: 100,
                divisions: 10,
                onChanged: (val) => setState(() => _state.porcentageAvancement = val),
              ),
              const SizedBox(height: AppSizes.paddingXL),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(isEditing ? 'Mettre à jour' : 'Créer la tâche'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityDot(TachePriorite priorite) {
    Color color;
    switch (priorite) {
      case TachePriorite.haute: color = AppColors.error; break;
      case TachePriorite.moyenne: color = AppColors.warning; break;
      case TachePriorite.basse: color = AppColors.success; break;
    }
    return Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final tache = Tache(
        id: widget.taskId,
        titre: _state.titre,
        description: _state.description,
        priorite: _state.priorite,
        statut: _state.statut,
        dateEcheance: _state.dateEcheance,
        pourcentageAvancement: _state.porcentageAvancement,
        agentId: 1, // Temporaire: à remplacer par ID user connecté
        activiteId: _state.activiteId,
      );

      try {
        if (widget.taskId != null) {
          await ref.read(taskActionProvider.notifier).updateTask(tache);
        } else {
          await ref.read(taskActionProvider.notifier).addTask(tache);
        }
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}
