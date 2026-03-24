import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';
import 'database_service.dart';

/// Service d'authentification et gestion des sessions
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final DatabaseService _db = DatabaseService.instance;

  // Clés pour SharedPreferences
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberMe = 'remember_me';

  Utilisateur? _currentUser;

  /// Utilisateur actuellement connecté
  Utilisateur? get currentUser => _currentUser;

  /// Vérifier si un utilisateur est connecté
  bool get isLoggedIn => _currentUser != null;

  /// Initialiser le service (vérifier si une session existe)
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (isLoggedIn && rememberMe) {
        final userId = prefs.getInt(_keyUserId);
        if (userId != null) {
          _currentUser = await _db.getUtilisateurById(userId);
          debugPrint('✅ Session restored for user: ${_currentUser?.username}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth service: $e');
    }
  }

  /// Connexion avec username et password
  Future<AuthResult> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Récupérer l'utilisateur par username
      final user = await _db.getUtilisateurByUsername(username);

      if (user == null) {
        return AuthResult(
          success: false,
          message: 'Nom d\'utilisateur ou mot de passe incorrect',
        );
      }

      // Vérifier si l'utilisateur est actif
      if (!user.actif) {
        return AuthResult(
          success: false,
          message: 'Ce compte est désactivé. Contactez l\'administrateur.',
        );
      }

      // Vérifier le mot de passe
      final passwordHash = _hashPassword(password);
      if (user.passwordHash != passwordHash) {
        return AuthResult(
          success: false,
          message: 'Nom d\'utilisateur ou mot de passe incorrect',
        );
      }

      // Connexion réussie
      _currentUser = user;

      // Mettre à jour la dernière connexion
      await _db.updateLastLogin(user.id!);

      // Sauvegarder la session
      await _saveSession(user.id!, username, rememberMe);

      debugPrint('✅ User logged in: ${user.username}');

      return AuthResult(
        success: true,
        message: 'Connexion réussie',
        user: user,
      );
    } catch (e) {
      debugPrint('❌ Error during login: $e');
      return AuthResult(
        success: false,
        message: 'Une erreur s\'est produite lors de la connexion',
      );
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      _currentUser = null;

      // Effacer la session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
      await prefs.setBool(_keyIsLoggedIn, false);

      debugPrint('✅ User logged out');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }

  /// Changer le mot de passe
  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _db.getUtilisateurById(userId);
      if (user == null) return false;

      // Vérifier l'ancien mot de passe
      final oldPasswordHash = _hashPassword(oldPassword);
      if (user.passwordHash != oldPasswordHash) {
        return false;
      }

      // Mettre à jour avec le nouveau mot de passe
      final newPasswordHash = _hashPassword(newPassword);
      final updatedUser = user.copyWith(
        passwordHash: newPasswordHash,
        updatedAt: DateTime.now(),
      );

      await _db.updateUtilisateur(updatedUser);

      debugPrint('✅ Password changed for user: ${user.username}');
      return true;
    } catch (e) {
      debugPrint('❌ Error changing password: $e');
      return false;
    }
  }

  /// Réinitialiser le mot de passe (pour admin)
  Future<String?> resetPassword(int userId) async {
    try {
      final user = await _db.getUtilisateurById(userId);
      if (user == null) return null;

      // Générer un mot de passe temporaire
      final tempPassword = _generateTempPassword();
      final tempPasswordHash = _hashPassword(tempPassword);

      final updatedUser = user.copyWith(
        passwordHash: tempPasswordHash,
        updatedAt: DateTime.now(),
      );

      await _db.updateUtilisateur(updatedUser);

      debugPrint('✅ Password reset for user: ${user.username}');
      return tempPassword;
    } catch (e) {
      debugPrint('❌ Error resetting password: $e');
      return null;
    }
  }

  /// Vérifier si l'utilisateur a une permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    return _currentUser!.hasPermission(permission);
  }

  /// Vérifier si l'utilisateur a accès à un projet
  bool hasAccessToProject(int projectId) {
    if (_currentUser == null) return false;
    return _currentUser!.hasAccessToProject(projectId);
  }

  /// Vérifier si l'utilisateur a un rôle spécifique
  bool hasRole(UserRole role) {
    if (_currentUser == null) return false;
    return _currentUser!.role == role;
  }

  /// Vérifier si l'utilisateur est admin
  bool get isAdmin {
    if (_currentUser == null) return false;
    return _currentUser!.role == UserRole.superAdmin ||
        _currentUser!.role == UserRole.admin;
  }

  // ============================================================================
  // MÉTHODES PRIVÉES
  // ============================================================================

  /// Hasher un mot de passe (SHA-256 pour simplifier, bcrypt serait mieux en production)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Générer un mot de passe temporaire
  String _generateTempPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      12,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  /// Sauvegarder la session
  Future<void> _saveSession(
    int userId,
    String username,
    bool rememberMe,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyRememberMe, rememberMe);
  }
}

/// Résultat d'une tentative d'authentification
class AuthResult {
  final bool success;
  final String message;
  final Utilisateur? user;

  const AuthResult({required this.success, required this.message, this.user});
}
