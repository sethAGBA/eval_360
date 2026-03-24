import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres et Administration'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Général'),
            Tab(icon: Icon(Icons.manage_accounts), text: 'Utilisateurs & Rôles'),
            Tab(icon: Icon(Icons.storage), text: 'Données de Référence'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(context, ref),
          _buildUsersTab(context, ref),
          _buildReferenceTab(context),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(BuildContext context, WidgetRef ref) {
    final year = ref.watch(activeExerciseYearProvider);
    final inst = ref.watch(institutionNameProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informations de l\'Instance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Divider(),
                ListTile(
                  title: const Text('Nom de l\'Institution'),
                  subtitle: Text(inst),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    // Update behavior here
                  },
                ),
                ListTile(
                  title: const Text('Année d\'Exercice Active'),
                  subtitle: Text('$year (Détermine le PTBA en cours)'),
                  trailing: DropdownButton<int>(
                    value: year,
                    items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) ref.read(activeExerciseYearProvider.notifier).state = val;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersListProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erreur: $err')),
      data: (users) {
        if (users.isEmpty) return const Center(child: Text('Aucun utilisateur trouvé.'));
        
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(user.nomComplet.substring(0, 1), style: const TextStyle(color: AppColors.primary)),
                ),
                title: Text(user.nomComplet, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Matricule: ${user.matricule} | Rôle: ${user.role}'),
                trailing: Switch(
                  value: user.actif,
                  onChanged: (val) {
                    // Update user status in DB
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReferenceTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      children: [
        Card(
          child: ExpansionTile(
            title: const Text('Types de Documents (GED)', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              ListTile(title: const Text('Termes de Référence (TdR)'), trailing: const Icon(Icons.check, color: Colors.green)),
              ListTile(title: const Text('Ordres de Mission'), trailing: const Icon(Icons.check, color: Colors.green)),
              ListTile(title: const Text('Livret de Bord (Stagiaires)'), trailing: const Icon(Icons.check, color: Colors.green)),
              ListTile(title: const Text('Rapports Périodiques'), trailing: const Icon(Icons.check, color: Colors.green)),
            ],
          ),
        ),
      ],
    );
  }
}
