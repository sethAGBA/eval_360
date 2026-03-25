import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/commune.dart';
import '../../../../core/models/activite.dart';
import '../../../../core/services/database_service.dart';
import '../widgets/update_pdc_dialog.dart';
import '../widgets/add_commune_dialog.dart';
import '../widgets/add_zone_dialog.dart';
import '../providers/commune_provider.dart';
import '../../../../core/models/zone_intervention.dart';

class CommuneDetailPage extends ConsumerStatefulWidget {
  final Commune commune;

  const CommuneDetailPage({super.key, required this.commune});

  @override
  ConsumerState<CommuneDetailPage> createState() => _CommuneDetailPageState();
}

class _CommuneDetailPageState extends ConsumerState<CommuneDetailPage> {
  late Commune _commune;
  List<Activite> _activites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _commune = widget.commune;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final activites = await DatabaseService.instance.getActivitesByCommune(_commune.id ?? 0, _commune.nom);
      setState(() {
        _activites = activites;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading commune details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Détail PDC - ${_commune.nom}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: 'Modifier les informations',
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: _showUpdateDialog,
            tooltip: 'Mettre à jour l\'avancement',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Supprimer la commune',
          ),
          const SizedBox(width: AppSizes.paddingL),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.paddingL),
            _buildProgressCard(),
            const SizedBox(height: AppSizes.paddingL),
            _buildZonesSection(),
            const SizedBox(height: AppSizes.paddingL),
            _buildActivitesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesSection() {
    final zonesAsync = ref.watch(zonesByCommuneProvider(_commune.id ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Zones d\'intervention (Villages/Quartiers)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              onPressed: _showAddZoneDialog,
              tooltip: 'Ajouter une zone',
            ),
          ],
        ),
        zonesAsync.when(
          data: (zones) {
            if (zones.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingL),
                  child: Center(child: Text('Aucune zone définie pour cette commune.')),
                ),
              );
            }
            return Column(
              children: zones.map((z) => _buildZoneTile(z)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Erreur: $err')),
        ),
      ],
    );
  }

  Widget _buildZoneTile(ZoneIntervention z) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: AppColors.primary),
        title: Text(z.villageQuartier ?? 'Zone sans nom'),
        subtitle: Text('Population: ${z.populationTotale ?? "N/A"} | GPS: ${z.hasCoordinates ? "${z.latitude}, ${z.longitude}" : "Non renseigné"}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showAddZoneDialog(zone: z),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => _deleteZone(z),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.location_city, color: Colors.white),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _commune.nom,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_commune.prefecture} — Région ${_commune.region}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: AppSizes.paddingL * 2),
            _buildDetailRow(Icons.person, 'Maire', _commune.contactMaire ?? 'Non renseigné'),
            if (_commune.contactEmail != null) _buildDetailRow(Icons.email, 'Email', _commune.contactEmail!),
            if (_commune.contactTelephone != null) _buildDetailRow(Icons.phone, 'Téléphone', _commune.contactTelephone!),
            const SizedBox(height: AppSizes.paddingM),
            _buildDetailRow(Icons.people, 'Population', _commune.nbHabitants != null ? NumberFormat('#,###', 'fr_FR').format(_commune.nbHabitants) : 'Non renseignée'),
            _buildDetailRow(Icons.update, 'Dernière mise à jour', _commune.dateDerniereMiseAJour != null 
              ? DateFormat('dd/MM/yyyy HH:mm').format(_commune.dateDerniereMiseAJour!) 
              : 'Jamais'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final color = _getColorForProgress(_commune.tauxAvancementPdc);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avancement du PDC',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: _commune.tauxAvancementPdc / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    color: color,
                  ),
                ),
                Text(
                  '${_commune.tauxAvancementPdc.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Période de validité', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(
                      _commune.pdcPeriodeDebut != null && _commune.pdcPeriodeFin != null
                          ? '${_commune.pdcPeriodeDebut} — ${_commune.pdcPeriodeFin}'
                          : 'Période non renseignée',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_commune.pdcDocumentUrl != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logic for opening URL
                    },
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Consulter le PDC'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            const Text(
              'Le Plan de Développement Communal (PDC) est le document stratégique qui définit les axes prioritaires de développement de la commune.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
            if (_commune.description != null) ...[
              const SizedBox(height: AppSizes.paddingM),
              Text(
                _commune.description!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Activités et Projets sur le territoire',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_activites.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingL),
              child: Center(child: Text('Aucune activité enregistrée pour cette commune.')),
            ),
          )
        else
          ..._activites.map((a) => _buildActiviteCard(a)),
      ],
    );
  }

  Widget _buildActiviteCard(Activite a) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: ListTile(
        title: Text(a.intitule, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(a.description ?? 'Pas de description'),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getColorForProgress(a.pourcentageAvancement.toDouble()).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${a.pourcentageAvancement}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getColorForProgress(a.pourcentageAvancement.toDouble()),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddCommuneDialog(commune: _commune),
    );

    if (result == true) {
      final updatedCommunes = await DatabaseService.instance.getCommunes();
      final updatedCommune = updatedCommunes.firstWhere((c) => c.id == _commune.id);
      setState(() {
        _commune = updatedCommune;
      });
      ref.invalidate(communesProvider);
    }
  }

  void _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la commune'),
        content: Text('Êtes-vous sûr de vouloir supprimer la commune "${_commune.nom}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteCommune(_commune.id!);
        ref.invalidate(communesProvider);
        if (mounted) Navigator.of(context).pop(); // Retour à la liste
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  void _showUpdateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UpdatePdcDialog(commune: _commune),
    );

    if (result == true) {
      // Recharger la commune pour avoir les données à jour
      final updatedCommunes = await DatabaseService.instance.getCommunes();
      final updatedCommune = updatedCommunes.firstWhere((c) => c.id == _commune.id);
      setState(() {
        _commune = updatedCommune;
      });
      // Invalider le provider pour que la liste principale se mette à jour
      ref.invalidate(communesProvider);
    }
  }

  void _showAddZoneDialog({ZoneIntervention? zone}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddZoneDialog(commune: _commune, zone: zone),
    );

    if (result == true) {
      ref.invalidate(zonesByCommuneProvider(_commune.id ?? 0));
    }
  }

  void _deleteZone(ZoneIntervention z) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la zone'),
        content: Text('Voulez-vous supprimer la zone "${z.villageQuartier}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.deleteZone(z.id!);
      ref.invalidate(zonesByCommuneProvider(_commune.id ?? 0));
    }
  }

  Color _getColorForProgress(double progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }
}
