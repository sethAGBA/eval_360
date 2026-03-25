import 'dart:convert';
import '../database/database_tables.dart';

/// Modèle de données pour un utilisateur du système
class Utilisateur {
  final int? id;
  final String? matricule;
  final String username;
  final String email;
  final String passwordHash;
  final String nom;
  final String prenom;
  final UserRole role;
  final List<int> projetsAssignes;
  final Map<String, dynamic> permissions;
  final bool actif;
  final DateTime? derniereConnexion;
  final bool twoFactorEnabled;
  final String? twoFactorSecret;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Utilisateur({
    this.id,
    this.matricule,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.nom,
    required this.prenom,
    required this.role,
    this.projetsAssignes = const [],
    this.permissions = const {},
    this.actif = true,
    this.derniereConnexion,
    this.twoFactorEnabled = false,
    this.twoFactorSecret,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      if (id != null) UtilisateursColumns.id: id,
      UtilisateursColumns.matricule: matricule,
      UtilisateursColumns.username: username,
      UtilisateursColumns.email: email,
      UtilisateursColumns.passwordHash: passwordHash,
      UtilisateursColumns.nom: nom,
      UtilisateursColumns.prenom: prenom,
      UtilisateursColumns.role: role.name,
      UtilisateursColumns.projetsAssignes: jsonEncode(projetsAssignes),
      UtilisateursColumns.permissions: jsonEncode(permissions),
      UtilisateursColumns.actif: actif ? 1 : 0,
      UtilisateursColumns.derniereConnexion: derniereConnexion
          ?.toIso8601String(),
      UtilisateursColumns.twoFactorEnabled: twoFactorEnabled ? 1 : 0,
      UtilisateursColumns.twoFactorSecret: twoFactorSecret,
      UtilisateursColumns.createdAt: createdAt.toIso8601String(),
      UtilisateursColumns.updatedAt: updatedAt.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map[UtilisateursColumns.id] as int?,
      matricule: map[UtilisateursColumns.matricule] as String?,
      username: map[UtilisateursColumns.username] as String,
      email: map[UtilisateursColumns.email] as String,
      passwordHash: map[UtilisateursColumns.passwordHash] as String,
      nom: map[UtilisateursColumns.nom] as String,
      prenom: map[UtilisateursColumns.prenom] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == map[UtilisateursColumns.role],
        orElse: () => UserRole.lecteur,
      ),
      projetsAssignes:
          (jsonDecode(map[UtilisateursColumns.projetsAssignes] as String)
                  as List)
              .map((e) => e as int)
              .toList(),
      permissions:
          jsonDecode(map[UtilisateursColumns.permissions] as String)
              as Map<String, dynamic>,
      actif: map[UtilisateursColumns.actif] == 1,
      derniereConnexion: map[UtilisateursColumns.derniereConnexion] != null
          ? DateTime.parse(map[UtilisateursColumns.derniereConnexion] as String)
          : null,
      twoFactorEnabled: map[UtilisateursColumns.twoFactorEnabled] == 1,
      twoFactorSecret: map[UtilisateursColumns.twoFactorSecret] as String?,
      createdAt: DateTime.parse(map[UtilisateursColumns.createdAt] as String),
      updatedAt: DateTime.parse(map[UtilisateursColumns.updatedAt] as String),
    );
  }

  /// Créer une copie avec modifications
  Utilisateur copyWith({
    int? id,
    String? matricule,
    String? username,
    String? email,
    String? passwordHash,
    String? nom,
    String? prenom,
    UserRole? role,
    List<int>? projetsAssignes,
    Map<String, dynamic>? permissions,
    bool? actif,
    DateTime? derniereConnexion,
    bool? twoFactorEnabled,
    String? twoFactorSecret,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      matricule: matricule ?? this.matricule,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      role: role ?? this.role,
      projetsAssignes: projetsAssignes ?? this.projetsAssignes,
      permissions: permissions ?? this.permissions,
      actif: actif ?? this.actif,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Nom complet de l'utilisateur
  String get nomComplet => '$prenom $nom';

  /// Initiales de l'utilisateur
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  /// Vérifier si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    // Super admin a toutes les permissions
    if (role == UserRole.superAdmin) return true;

    return permissions[permission] == true;
  }

  /// Vérifier si l'utilisateur a accès à un projet
  bool hasAccessToProject(int projectId) {
    // Super admin et admin ont accès à tous les projets
    if (role == UserRole.superAdmin || role == UserRole.admin) return true;

    return projetsAssignes.contains(projectId);
  }

  @override
  String toString() {
    return 'Utilisateur(id: $id, username: $username, nom: $nomComplet, role: ${role.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Utilisateur && other.id == id && other.username == username;
  }

  @override
  int get hashCode => Object.hash(id, username);
}

/// Rôles utilisateur dans le système
enum UserRole {
  /// Administrateur système avec tous les droits
  superAdmin,

  /// Administrateur avec droits étendus
  admin,

  /// Chef de projet
  chefProjet,

  /// Coordinateur Suivi & Évaluation
  coordinateurSE,

  /// Responsable financier
  responsableFinancier,

  /// Agent de Suivi & Évaluation
  agentSE,

  /// Consultant externe
  consultant,

  /// Lecteur (accès en lecture seule)
  lecteur;

  /// Label lisible du rôle
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Administrateur';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.chefProjet:
        return 'Chef de Projet';
      case UserRole.coordinateurSE:
        return 'Coordinateur S&E';
      case UserRole.responsableFinancier:
        return 'Responsable Financier';
      case UserRole.agentSE:
        return 'Agent S&E';
      case UserRole.consultant:
        return 'Consultant';
      case UserRole.lecteur:
        return 'Lecteur';
    }
  }

  /// Description du rôle
  String get description {
    switch (this) {
      case UserRole.superAdmin:
        return 'Accès complet à toutes les fonctionnalités du système';
      case UserRole.admin:
        return 'Gestion des utilisateurs et configuration système';
      case UserRole.chefProjet:
        return 'Gestion complète des projets assignés';
      case UserRole.coordinateurSE:
        return 'Coordination du suivi et évaluation';
      case UserRole.responsableFinancier:
        return 'Gestion budgétaire et financière';
      case UserRole.agentSE:
        return 'Collecte et saisie de données S&E';
      case UserRole.consultant:
        return 'Accès limité pour consultants externes';
      case UserRole.lecteur:
        return 'Accès en lecture seule';
    }
  }
}
