import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/utilisateur.dart';
import '../../../../core/services/database_service.dart';
import '../providers/agent_provider.dart';

class AgentFormPage extends ConsumerStatefulWidget {
  final int? agentId;

  const AgentFormPage({super.key, this.agentId});

  @override
  ConsumerState<AgentFormPage> createState() => _AgentFormPageState();
}

class _AgentFormPageState extends ConsumerState<AgentFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _matriculeController;
  late TextEditingController _passwordController;
  UserRole _role = UserRole.agentSE;
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _matriculeController = TextEditingController();
    _passwordController = TextEditingController();

    if (widget.agentId != null) {
      _loadAgent();
    }
  }

  Future<void> _loadAgent() async {
    setState(() => _isLoading = true);
    try {
      final agent = await DatabaseService.instance.getUtilisateurById(widget.agentId!);
      if (agent != null) {
        _nomController.text = agent.nom;
        _prenomController.text = agent.prenom;
        _emailController.text = agent.email;
        _usernameController.text = agent.username;
        _matriculeController.text = agent.matricule ?? '';
        _role = agent.role;
        _actif = agent.actif;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _matriculeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final agent = Utilisateur(
        id: widget.agentId,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        username: _usernameController.text,
        matricule: _matriculeController.text.isEmpty ? null : _matriculeController.text,
        passwordHash: _passwordController.text.isNotEmpty 
            ? _passwordController.text // In a real app, hash this
            : (widget.agentId == null ? 'default_password' : ''), 
        role: _role,
        actif: _actif,
        createdAt: widget.agentId == null ? now : now, // Should keep original in real DB
        updatedAt: now,
      );

      if (widget.agentId == null) {
        await DatabaseService.instance.createUtilisateur(agent);
      } else {
        // Fetch existing agent to preserve fields not in form
        final existing = await DatabaseService.instance.getUtilisateurById(widget.agentId!);
        if (existing != null) {
          final updated = existing.copyWith(
            nom: agent.nom,
            prenom: agent.prenom,
            email: agent.email,
            username: agent.username,
            matricule: agent.matricule,
            role: agent.role,
            actif: agent.actif,
            updatedAt: now,
          );
          await DatabaseService.instance.updateUtilisateur(updated);
        }
      }

      ref.invalidate(agentsProvider);
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.agentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'Agent' : 'Ajouter un Agent'),
      ),
      body: _isLoading && !isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_prenomController, 'Prénom', Icons.person),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildTextField(_nomController, 'Nom', Icons.person_outline),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildTextField(_matriculeController, 'Matricule', Icons.badge, required: false),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildTextField(_usernameController, 'Nom d\'utilisateur', Icons.alternate_email),
                    const SizedBox(height: AppSizes.paddingM),
                    if (!isEditing) ...[
                      _buildTextField(_passwordController, 'Mot de passe temporaire', Icons.lock, obscureText: true),
                      const SizedBox(height: AppSizes.paddingM),
                    ],
                    const Text('Rôle', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<UserRole>(
                      value: _role,
                      items: UserRole.values
                          .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                          .toList(),
                      onChanged: (val) => setState(() => _role = val!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    SwitchListTile(
                      title: const Text('Compte actif'),
                      value: _actif,
                      onChanged: (val) => setState(() => _actif = val),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isEditing ? 'Enregistrer les modifications' : 'Créer l\'agent'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: required
          ? (val) => val == null || val.isEmpty ? 'Ce champ est obligatoire' : null
          : null,
    );
  }
}
