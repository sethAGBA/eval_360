import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/settings_provider.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
                  onTap: () async {
                    final controller = TextEditingController(text: inst);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Nom de l\'institution'),
                        content: TextField(controller: controller, autofocus: true),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Enregistrer')),
                        ],
                      ),
                    );
                    if (result != null && result.isNotEmpty) {
                      await ref.read(institutionNameProvider.notifier).set(result);
                    }
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
                    onChanged: (val) async {
                      if (val != null) await ref.read(activeExerciseYearProvider.notifier).set(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),
        _buildBrandingSection(context, ref),
      ],
    );
  }

  Widget _buildBrandingSection(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(appConfigProvider);

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erreur: $err')),
      data: (config) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Branding & En-têtes des Rapports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              const SizedBox(height: AppSizes.paddingS),
              _buildConfigTile(
                context,
                'République',
                config.republique,
                (val) => ref.read(appConfigProvider.notifier).updateConfig(config.copyWith(republique: val)),
              ),
              _buildConfigTile(
                context,
                'Ministère / Tutelle',
                config.ministere,
                (val) => ref.read(appConfigProvider.notifier).updateConfig(config.copyWith(ministere: val)),
              ),
              _buildConfigTile(
                context,
                'Entité / Direction',
                config.entite,
                (val) => ref.read(appConfigProvider.notifier).updateConfig(config.copyWith(entite: val)),
              ),
              _buildConfigTile(
                context,
                'Sigle Complet',
                config.sigle,
                (val) => ref.read(appConfigProvider.notifier).updateConfig(config.copyWith(sigle: val)),
              ),
              _buildConfigTile(
                context,
                'Description Détaillée',
                config.direction,
                (val) => ref.read(appConfigProvider.notifier).updateConfig(config.copyWith(direction: val)),
                isMultiline: true,
              ),
              const SizedBox(height: AppSizes.paddingM),
              const Text('Logo de l\'institution', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: config.logoPath != null && File(config.logoPath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            child: Image.file(File(config.logoPath!), fit: BoxFit.contain),
                          )
                        : const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result != null && result.files.single.path != null) {
                            await ref.read(appConfigProvider.notifier).updateConfig(
                                  config.copyWith(logoPath: result.files.single.path),
                                );
                          }
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Modifier le logo'),
                      ),
                      if (config.logoPath != null)
                        TextButton.icon(
                          onPressed: () => ref.read(appConfigProvider.notifier).updateConfig(config.copyWith(logoPath: null)),
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigTile(
    BuildContext context,
    String label,
    String value,
    Function(String) onSave, {
    bool isMultiline = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      subtitle: Text(
        value.isEmpty ? '(Non défini)' : value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.edit, size: 20),
      onTap: () async {
        final controller = TextEditingController(text: value);
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(label),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLines: isMultiline ? 3 : 1,
              decoration: InputDecoration(hintText: 'Entrez $label'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Enregistrer')),
            ],
          ),
        );
        if (result != null) {
          onSave(result);
        }
      },
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
