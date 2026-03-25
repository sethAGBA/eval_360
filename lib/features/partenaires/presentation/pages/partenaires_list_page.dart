import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/partenaire.dart';
import '../../../../core/models/bailleur.dart';
import '../../../../core/services/database_service.dart';
import '../providers/partenaire_provider.dart';
import '../../../projects/presentation/providers/bailleur_provider.dart';

class PartenairesListPage extends ConsumerStatefulWidget {
  const PartenairesListPage({super.key});

  @override
  ConsumerState<PartenairesListPage> createState() => _PartenairesListPageState();
}

class _PartenairesListPageState extends ConsumerState<PartenairesListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rafraîchir pour mettre à jour le bouton flottant
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showInactif = ref.watch(partenaireShowInactifProvider);
    final partenairesAsync = ref.watch(partenairesProvider(!showInactif));
    final bailleursAsync = ref.watch(bailleursProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partenaires Techniques & Financiers'),
        actions: [
          if (_tabController.index == 0) // N'afficher le filtre que pour l'onglet Partenaires (qui a inactif)
            TextButton.icon(
              icon: Icon(showInactif ? Icons.visibility_off : Icons.visibility),
              label: Text(showInactif ? 'Masquer inactifs' : 'Voir tous'),
              onPressed: () => ref.read(partenaireShowInactifProvider.notifier).state = !showInactif,
            ),
          const SizedBox(width: AppSizes.paddingM),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Partenaires (Mise en œuvre)'),
            Tab(text: 'Bailleurs de Fonds'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Partenaires
          partenairesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (partenaires) => _buildPartenairesList(context, partenaires),
          ),
          
          // TAB 2: Bailleurs
          bailleursAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (bailleurs) => _buildBailleursList(context, bailleurs),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showPartenaireForm(context, null);
          } else {
            _showBailleurForm(context, null);
          }
        },
        label: Text(_tabController.index == 0 ? 'Ajouter Partenaire' : 'Ajouter Bailleur'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // =========================================================================
  // LISTE DES PARTENAIRES (PTF)
  // =========================================================================

  Widget _buildPartenairesList(BuildContext context, List<Partenaire> partenaires) {
    if (partenaires.isEmpty) {
      return const Center(child: Text('Aucun partenaire enregistré.'));
    }

    final grouped = <TypePartenaire, List<Partenaire>>{};
    for (final p in partenaires) {
      grouped.putIfAbsent(p.type, () => []).add(p);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      children: grouped.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            child: Text(
              entry.key.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          ...entry.value.map((p) => _buildPartenaireCard(context, p)),
          const SizedBox(height: AppSizes.paddingM),
        ],
      )).toList(),
    );
  }

  Widget _buildPartenaireCard(BuildContext context, Partenaire p) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA ', decimalDigits: 0);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: p.actif ? Colors.grey[200]! : Colors.red[100]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
        leading: CircleAvatar(
          backgroundColor: _colorForPartenaireType(p.type).withOpacity(0.12),
          child: Icon(_iconForPartenaireType(p.type), color: _colorForPartenaireType(p.type)),
        ),
        title: Row(
          children: [
            Text(p.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            if (!p.actif)
              const Chip(
                label: Text('Inactif', style: TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.pays != null) Text('${p.pays} — ${p.secteur ?? ""}'),
            if (p.contactNom != null) Text('Contact: ${p.contactNom} | ${p.contactEmail ?? ""}'),
            if (p.financementTotal != null)
              Text('Financement: ${fmt.format(p.financementTotal!)}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showPartenaireForm(context, p),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showPartenaireForm(BuildContext context, Partenaire? existing) {
    showDialog(
      context: context,
      builder: (_) => _PartenaireForm(existing: existing, onSaved: () {
        ref.invalidate(partenairesProvider);
      }),
    );
  }

  Color _colorForPartenaireType(TypePartenaire type) {
    switch (type) {
      case TypePartenaire.bilateral: return Colors.blue;
      case TypePartenaire.multilateral: return Colors.indigo;
      case TypePartenaire.ong: return Colors.green;
      case TypePartenaire.secteurPrive: return Colors.orange;
      case TypePartenaire.autre: return Colors.grey;
    }
  }

  IconData _iconForPartenaireType(TypePartenaire type) {
    switch (type) {
      case TypePartenaire.bilateral: return Icons.flag;
      case TypePartenaire.multilateral: return Icons.language;
      case TypePartenaire.ong: return Icons.volunteer_activism;
      case TypePartenaire.secteurPrive: return Icons.business;
      case TypePartenaire.autre: return Icons.handshake;
    }
  }

  // =========================================================================
  // LISTE DES BAILLEURS
  // =========================================================================

  Widget _buildBailleursList(BuildContext context, List<Bailleur> bailleurs) {
    if (bailleurs.isEmpty) {
      return const Center(child: Text('Aucun bailleur enregistré.'));
    }

    final grouped = <BailleurType, List<Bailleur>>{};
    for (final b in bailleurs) {
      grouped.putIfAbsent(b.type, () => []).add(b);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      children: grouped.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            child: Text(
              entry.key.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          ...entry.value.map((b) => _buildBailleurCard(context, b)),
          const SizedBox(height: AppSizes.paddingM),
        ],
      )).toList(),
    );
  }

  Widget _buildBailleurCard(BuildContext context, Bailleur b) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
        leading: CircleAvatar(
          backgroundColor: _colorForBailleurType(b.type).withOpacity(0.12),
          child: Icon(_iconForBailleurType(b.type), color: _colorForBailleurType(b.type)),
        ),
        title: Text(b.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(b.pays),
            if (b.contactNom != null) Text('Contact: ${b.contactNom} | ${b.contactEmail ?? ""}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showBailleurForm(context, b),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showBailleurForm(BuildContext context, Bailleur? existing) {
    showDialog(
      context: context,
      builder: (_) => _BailleurForm(existing: existing, onSaved: () {
        ref.invalidate(bailleursProvider);
      }),
    );
  }

  Color _colorForBailleurType(BailleurType type) {
    switch (type) {
      case BailleurType.bailleur: return Colors.blue;
      case BailleurType.partenaire: return Colors.teal;
      case BailleurType.coFinanceur: return Colors.deepPurple;
    }
  }

  IconData _iconForBailleurType(BailleurType type) {
    switch (type) {
      case BailleurType.bailleur: return Icons.account_balance;
      case BailleurType.partenaire: return Icons.group_work;
      case BailleurType.coFinanceur: return Icons.monetization_on;
    }
  }
}

// =========================================================================
// FORMULAIRES (PARTENAIRE ET BAILLEUR)
// =========================================================================

class _PartenaireForm extends ConsumerStatefulWidget {
  final Partenaire? existing;
  final VoidCallback onSaved;

  const _PartenaireForm({this.existing, required this.onSaved});

  @override
  ConsumerState<_PartenaireForm> createState() => _PartenaireFormState();
}

class _PartenaireFormState extends ConsumerState<_PartenaireForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _paysCtrl = TextEditingController();
  final _secteurCtrl = TextEditingController();
  final _contactNomCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _financementCtrl = TextEditingController();
  TypePartenaire _type = TypePartenaire.multilateral;
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final p = widget.existing!;
      _nomCtrl.text = p.nom;
      _paysCtrl.text = p.pays ?? '';
      _secteurCtrl.text = p.secteur ?? '';
      _contactNomCtrl.text = p.contactNom ?? '';
      _contactEmailCtrl.text = p.contactEmail ?? '';
      _financementCtrl.text = p.financementTotal?.toString() ?? '';
      _type = p.type;
      _actif = p.actif;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _paysCtrl.dispose(); _secteurCtrl.dispose();
    _contactNomCtrl.dispose(); _contactEmailCtrl.dispose(); _financementCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final partenaire = Partenaire(
      id: widget.existing?.id,
      nom: _nomCtrl.text,
      type: _type,
      pays: _paysCtrl.text.isEmpty ? null : _paysCtrl.text,
      secteur: _secteurCtrl.text.isEmpty ? null : _secteurCtrl.text,
      contactNom: _contactNomCtrl.text.isEmpty ? null : _contactNomCtrl.text,
      contactEmail: _contactEmailCtrl.text.isEmpty ? null : _contactEmailCtrl.text,
      financementTotal: double.tryParse(_financementCtrl.text),
      actif: _actif,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing?.id != null) {
      await DatabaseService.instance.updatePartenaire(partenaire);
    } else {
      await DatabaseService.instance.createPartenaire(partenaire);
    }
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nouveau Partenaire' : 'Modifier Partenaire'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom du partenaire *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TypePartenaire>(
                  value: _type,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: TypePartenaire.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _paysCtrl, decoration: const InputDecoration(labelText: 'Pays')),
                const SizedBox(height: 12),
                TextFormField(controller: _secteurCtrl, decoration: const InputDecoration(labelText: 'Secteur d\'intervention')),
                const SizedBox(height: 12),
                TextFormField(controller: _contactNomCtrl, decoration: const InputDecoration(labelText: 'Contact (Nom)')),
                const SizedBox(height: 12),
                TextFormField(controller: _contactEmailCtrl, decoration: const InputDecoration(labelText: 'Contact (Email)')),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _financementCtrl,
                  decoration: const InputDecoration(labelText: 'Financement total (FCFA)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Partenariat actif'),
                  value: _actif,
                  onChanged: (v) => setState(() => _actif = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
      ],
    );
  }
}

class _BailleurForm extends ConsumerStatefulWidget {
  final Bailleur? existing;
  final VoidCallback onSaved;

  const _BailleurForm({this.existing, required this.onSaved});

  @override
  ConsumerState<_BailleurForm> createState() => _BailleurFormState();
}

class _BailleurFormState extends ConsumerState<_BailleurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _paysCtrl = TextEditingController();
  final _contactNomCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  BailleurType _type = BailleurType.bailleur;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final b = widget.existing!;
      _nomCtrl.text = b.nom;
      _paysCtrl.text = b.pays;
      _contactNomCtrl.text = b.contactNom ?? '';
      _contactEmailCtrl.text = b.contactEmail ?? '';
      _adresseCtrl.text = b.adresse ?? '';
      _type = b.type;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _paysCtrl.dispose(); _adresseCtrl.dispose();
    _contactNomCtrl.dispose(); _contactEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final bailleur = Bailleur(
      id: widget.existing?.id,
      nom: _nomCtrl.text,
      type: _type,
      pays: _paysCtrl.text,
      contactNom: _contactNomCtrl.text.isEmpty ? null : _contactNomCtrl.text,
      contactEmail: _contactEmailCtrl.text.isEmpty ? null : _contactEmailCtrl.text,
      adresse: _adresseCtrl.text.isEmpty ? null : _adresseCtrl.text,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing?.id != null) {
      await DatabaseService.instance.updateBailleur(bailleur);
    } else {
      await DatabaseService.instance.createBailleur(bailleur);
    }
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nouveau Bailleur' : 'Modifier Bailleur'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom du bailleur *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BailleurType>(
                  value: _type,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: BailleurType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _paysCtrl, 
                  decoration: const InputDecoration(labelText: 'Pays *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _contactNomCtrl, decoration: const InputDecoration(labelText: 'Contact (Nom)')),
                const SizedBox(height: 12),
                TextFormField(controller: _contactEmailCtrl, decoration: const InputDecoration(labelText: 'Contact (Email)')),
                const SizedBox(height: 12),
                TextFormField(controller: _adresseCtrl, decoration: const InputDecoration(labelText: 'Adresse')),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
