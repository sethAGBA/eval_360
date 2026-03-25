import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/rapport_hebdo.dart';
import '../../../../core/models/ligne_rapport.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/services/database_service.dart';
import '../providers/weekly_report_provider.dart';
import '../widgets/activite_selector_dialog.dart';
import '../../../projects/presentation/providers/project_detail_providers.dart';
import '../../../../core/models/zone_intervention.dart';
import '../../../../core/services/export_service.dart';

/// Page de formulaire pour créer ou modifier un rapport hebdomadaire
class WeeklyReportFormPage extends ConsumerStatefulWidget {
  final int? rapportId;

  const WeeklyReportFormPage({super.key, this.rapportId});

  @override
  ConsumerState<WeeklyReportFormPage> createState() => _WeeklyReportFormPageState();
}

class _WeeklyReportFormPageState extends ConsumerState<WeeklyReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Données de l'entête
  int _semaineNumero = _getCurrentWeekNumber();
  int _annee = DateTime.now().year;
  late DateTime _dateDebut;
  late DateTime _dateFin;
  
  // Liste des lignes d'activités
  List<LigneRapport> _lignes = [];

  @override
  void initState() {
    super.initState();
    _updateDatesFromWeek();
    if (widget.rapportId != null) {
      _loadRapportData();
    } else {
      // Ajouter une ligne vide par défaut
      _addEmptyLine();
    }
  }

  static int _getCurrentWeekNumber() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(firstDayOfYear).inDays;
    return (dayOfYear / 7).ceil();
  }

  void _updateDatesFromWeek() {
    // Calcul simplifié de la semaine (ISO-8601 idéalement)
    final firstDayOfYear = DateTime(_annee, 1, 1);
    final daysToFirstMonday = (8 - firstDayOfYear.weekday) % 7;
    final firstMonday = firstDayOfYear.add(Duration(days: daysToFirstMonday));
    
    _dateDebut = firstMonday.add(Duration(days: (_semaineNumero - 1) * 7));
    _dateFin = _dateDebut.add(const Duration(days: 6));
  }

  Future<void> _loadRapportData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(weeklyReportDetailProvider(widget.rapportId!).future);
      if (data != null) {
        setState(() {
          _semaineNumero = data.rapport.semaineNumero;
          _annee = data.rapport.annee;
          _dateDebut = data.rapport.dateDebut;
          _dateFin = data.rapport.dateFin;
          _lignes = List.from(data.lignes);
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading rapport: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addEmptyLine() {
    setState(() {
      _lignes.add(LigneRapport(
        rapportId: widget.rapportId ?? 0,
        description: '',
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        statutActivite: 'En cours',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.rapportId == null ? 'Nouveau Rapport' : 'Modifier le Rapport'),
        actions: [
          if (widget.rapportId != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportPdf,
              tooltip: 'Exporter en PDF',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRapport,
            tooltip: 'Enregistrer en brouillon',
          ),
          const SizedBox(width: AppSizes.paddingS),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: AppSizes.paddingL),
              _buildLinesSection(),
              const SizedBox(height: AppSizes.paddingXL),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Période du Rapport',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _annee,
                    decoration: const InputDecoration(labelText: 'Année'),
                    items: [2024, 2025, 2026].map((a) {
                      return DropdownMenuItem(value: a, child: Text(a.toString()));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _annee = val!;
                        _updateDatesFromWeek();
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _semaineNumero,
                    decoration: const InputDecoration(labelText: 'Semaine N°'),
                    items: List.generate(52, (index) => index + 1).map((s) {
                      return DropdownMenuItem(value: s, child: Text('Semaine $s'));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _semaineNumero = val!;
                        _updateDatesFromWeek();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    'Période effective : du ${dateFormat.format(_dateDebut)} au ${dateFormat.format(_dateFin)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Détails des Activités',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addEmptyLine,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une ligne'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        ...List.generate(_lignes.length, (index) => _buildLineItem(index)),
      ],
    );
  }

  Widget _buildLineItem(int index) {
    final ligne = _lignes[index];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Text(
                    ligne.description.isEmpty ? 'Nouvelle activité' : ligne.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => setState(() => _lignes.removeAt(index)),
                ),
              ],
            ),
            const Divider(),
            // Sélection activité PTBA
            _buildActiviteSelector(index),
            const SizedBox(height: AppSizes.paddingM),
            TextFormField(
              initialValue: ligne.description,
              decoration: const InputDecoration(
                labelText: 'Description de l\'activité / tâche réaliseé',
                hintText: 'Que s\'est-il passé ?',
              ),
              onChanged: (val) => _lignes[index] = _lignes[index].copyWith(description: val),
              validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              children: [
                Expanded(
                  child: _buildLieuSelector(index),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: ligne.statutActivite,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: ['Réalisée', 'En cours', 'Reportée', 'Annulée'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) => setState(() => _lignes[index] = _lignes[index].copyWith(statutActivite: val)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextFormField(
              initialValue: ligne.resultatsAtteints,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Résultats atteints / Observations'),
              onChanged: (val) => _lignes[index] = _lignes[index].copyWith(resultatsAtteints: val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiviteSelector(int index) {
    final ligne = _lignes[index];
    
    return InkWell(
      onTap: () => _showActiviteSelectorDialog(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.link, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: Text(
                ligne.activiteId == null 
                  ? 'Lier à une activité du PTBA (optionnel)' 
                  : 'Lié à l\'activité ID: ${ligne.activiteId}',
                style: TextStyle(
                  color: ligne.activiteId == null ? AppColors.textSecondary : AppColors.primary,
                  fontStyle: ligne.activiteId == null ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            if (ligne.activiteId != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() => _lignes[index] = _lignes[index].copyWith(activiteId: null)),
              ),
          ],
        ),
      ),
    );
  }

  void _showActiviteSelectorDialog(int index) async {
    final act = await showDialog<Activite>(
      context: context,
      builder: (context) => const ActiviteSelectorDialog(),
    );

    if (act != null) {
      setState(() {
        _lignes[index] = _lignes[index].copyWith(
          activiteId: act.id,
          description: act.intitule,
          lieu: act.lieu, // Suggest default location if available
        );
      });
    }
  }

  Widget _buildLieuSelector(int index) {
    final ligne = _lignes[index];

    return TextFormField(
      key: ValueKey('lieu_${index}_${ligne.activiteId}'),
      initialValue: ligne.lieu,
      decoration: InputDecoration(
        labelText: 'Lieu / Localité',
        suffixIcon: ligne.activiteId != null ? _buildZoneSuggestionMenu(index) : null,
      ),
      onChanged: (val) => _lignes[index] = _lignes[index].copyWith(lieu: val),
    );
  }

  Widget? _buildZoneSuggestionMenu(int index) {
    final ligne = _lignes[index];
    if (ligne.activiteId == null) return null;

    final activitesAsync = ref.watch(allActivitesProvider);
    return activitesAsync.when(
      data: (activites) {
        final activity = activites.firstWhere((a) => a.id == ligne.activiteId, orElse: () => activites.first);
        final zonesIds = activity.zoneIds;

        if (zonesIds.isEmpty) return null;

        return PopupMenuButton<String>(
          icon: const Icon(Icons.location_city, size: 20, color: AppColors.primary),
          tooltip: 'Zones liées à l\'activité',
          onSelected: (val) {
            setState(() {
              _lignes[index] = _lignes[index].copyWith(lieu: val);
            });
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                enabled: false,
                child: Text('Sélectionner une zone associée :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              ...zonesIds.map((id) {
                return PopupMenuItem<String>(
                  value: 'Zone $id',
                  child: FutureBuilder<ZoneIntervention?>(
                    future: DatabaseService.instance.getZoneById(id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data!.villageQuartier ?? 'Zone $id');
                      }
                      return Text('Zone $id...');
                    },
                  ),
                );
              }),
            ];
          },
        );
      },
      loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => null,
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveRapport,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
        ),
        child: Text(
          widget.rapportId == null ? 'CRÉER LE RAPPORT' : 'METTRE À JOUR',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _saveRapport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajoutez au moins une ligne d\'activité')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = DatabaseService.instance;
      final rapport = RapportHebdo(
        id: widget.rapportId,
        agentId: 1, // Devrait provenir de l'auth
        semaineNumero: _semaineNumero,
        annee: _annee,
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        statutValidation: StatutValidationRapport.brouillon,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.rapportId == null) {
        await db.createWeeklyReport(rapport, _lignes);
      } else {
        await db.updateWeeklyReport(rapport, _lignes);
      }

      ref.invalidate(weeklyReportsProvider);
      if (widget.rapportId != null) ref.invalidate(weeklyReportDetailProvider(widget.rapportId!));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _exportPdf() async {
    if (widget.rapportId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await ref.read(weeklyReportDetailProvider(widget.rapportId!).future);
      if (data != null) {
        // Dans une vraie app, on récupérerait le nom de l'agent depuis l'auth
        await ExportService.instance.exportWeeklyReportToPdf(
          rapport: data.rapport,
          lignes: data.lignes,
          agentNom: 'Agent Administratif', 
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
