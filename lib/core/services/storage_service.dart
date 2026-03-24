import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// Service de gestion des fichiers (documents, images, pièces justificatives)
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  /// Répertoires de stockage
  static const String _documentsDir = 'documents';
  static const String _imagesDir = 'images';
  static const String _piecesJustificativesDir = 'pieces_justificatives';
  static const String _exportsDir = 'exports';
  static const String _tempDir = 'temp';

  /// Obtenir le répertoire racine de l'application
  Future<Directory> get _appDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final eval360Dir = Directory(path.join(appDir.path, 'eval360'));

    if (!await eval360Dir.exists()) {
      await eval360Dir.create(recursive: true);
    }

    return eval360Dir;
  }

  /// Obtenir le répertoire pour un type de fichier
  Future<Directory> _getDirectory(String subDir) async {
    final appDir = await _appDirectory;
    final dir = Directory(path.join(appDir.path, subDir));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  // ============================================================================
  // SAUVEGARDE DE FICHIERS
  // ============================================================================

  /// Sauvegarder un document
  Future<String?> saveDocument({
    required String sourcePath,
    required int projectId,
    required String category,
    String? customName,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('❌ Source file does not exist: $sourcePath');
        return null;
      }

      // Créer le répertoire de destination
      final docsDir = await _getDirectory(_documentsDir);
      final projectDir = Directory(
        path.join(docsDir.path, 'project_$projectId', category),
      );
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }

      // Générer le nom du fichier
      final extension = path.extension(sourcePath);
      final fileName =
          customName ?? '${DateTime.now().millisecondsSinceEpoch}$extension';
      final destPath = path.join(projectDir.path, fileName);

      // Copier le fichier
      await sourceFile.copy(destPath);

      debugPrint('✅ Document saved: $destPath');
      return destPath;
    } catch (e) {
      debugPrint('❌ Error saving document: $e');
      return null;
    }
  }

  /// Sauvegarder une image
  Future<String?> saveImage({
    required String sourcePath,
    required int projectId,
    String? customName,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('❌ Source file does not exist: $sourcePath');
        return null;
      }

      // Créer le répertoire de destination
      final imagesDir = await _getDirectory(_imagesDir);
      final projectDir = Directory(
        path.join(imagesDir.path, 'project_$projectId'),
      );
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }

      // Générer le nom du fichier
      final extension = path.extension(sourcePath);
      final fileName =
          customName ?? '${DateTime.now().millisecondsSinceEpoch}$extension';
      final destPath = path.join(projectDir.path, fileName);

      // Copier le fichier
      await sourceFile.copy(destPath);

      debugPrint('✅ Image saved: $destPath');
      return destPath;
    } catch (e) {
      debugPrint('❌ Error saving image: $e');
      return null;
    }
  }

  /// Sauvegarder une pièce justificative
  Future<String?> savePieceJustificative({
    required String sourcePath,
    required int depenseId,
    String? customName,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('❌ Source file does not exist: $sourcePath');
        return null;
      }

      // Créer le répertoire de destination
      final pjDir = await _getDirectory(_piecesJustificativesDir);
      final depenseDir = Directory(path.join(pjDir.path, 'depense_$depenseId'));
      if (!await depenseDir.exists()) {
        await depenseDir.create(recursive: true);
      }

      // Générer le nom du fichier
      final extension = path.extension(sourcePath);
      final fileName =
          customName ?? '${DateTime.now().millisecondsSinceEpoch}$extension';
      final destPath = path.join(depenseDir.path, fileName);

      // Copier le fichier
      await sourceFile.copy(destPath);

      debugPrint('✅ Piece justificative saved: $destPath');
      return destPath;
    } catch (e) {
      debugPrint('❌ Error saving piece justificative: $e');
      return null;
    }
  }

  /// Sauvegarder un export (PDF, Excel, etc.)
  Future<String?> saveExport({
    required String sourcePath,
    required String fileName,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('❌ Source file does not exist: $sourcePath');
        return null;
      }

      // Créer le répertoire de destination
      final exportsDir = await _getDirectory(_exportsDir);
      final destPath = path.join(exportsDir.path, fileName);

      // Copier le fichier
      await sourceFile.copy(destPath);

      debugPrint('✅ Export saved: $destPath');
      return destPath;
    } catch (e) {
      debugPrint('❌ Error saving export: $e');
      return null;
    }
  }

  // ============================================================================
  // RÉCUPÉRATION DE FICHIERS
  // ============================================================================

  /// Récupérer un fichier
  Future<File?> getFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting file: $e');
      return null;
    }
  }

  /// Lister les fichiers d'un répertoire
  Future<List<FileInfo>> listFiles(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        return [];
      }

      final files = <FileInfo>[];
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          files.add(
            FileInfo(
              path: entity.path,
              name: path.basename(entity.path),
              size: stat.size,
              modified: stat.modified,
              extension: path.extension(entity.path),
            ),
          );
        }
      }

      return files;
    } catch (e) {
      debugPrint('❌ Error listing files: $e');
      return [];
    }
  }

  // ============================================================================
  // SUPPRESSION DE FICHIERS
  // ============================================================================

  /// Supprimer un fichier
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
      return false;
    }
  }

  /// Supprimer tous les fichiers d'un projet
  Future<bool> deleteProjectFiles(int projectId) async {
    try {
      // Supprimer les documents
      final docsDir = await _getDirectory(_documentsDir);
      final projectDocsDir = Directory(
        path.join(docsDir.path, 'project_$projectId'),
      );
      if (await projectDocsDir.exists()) {
        await projectDocsDir.delete(recursive: true);
      }

      // Supprimer les images
      final imagesDir = await _getDirectory(_imagesDir);
      final projectImagesDir = Directory(
        path.join(imagesDir.path, 'project_$projectId'),
      );
      if (await projectImagesDir.exists()) {
        await projectImagesDir.delete(recursive: true);
      }

      debugPrint('✅ Project files deleted for project: $projectId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting project files: $e');
      return false;
    }
  }

  // ============================================================================
  // UTILITAIRES
  // ============================================================================

  /// Calculer le hash d'un fichier (pour vérifier l'intégrité)
  Future<String?> calculateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      debugPrint('❌ Error calculating file hash: $e');
      return null;
    }
  }

  /// Obtenir la taille d'un fichier en bytes
  Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      debugPrint('❌ Error getting file size: $e');
      return null;
    }
  }

  /// Formater la taille d'un fichier (bytes → KB, MB, GB)
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Nettoyer les fichiers temporaires
  Future<void> cleanTempFiles() async {
    try {
      final tempDir = await _getDirectory(_tempDir);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
        debugPrint('✅ Temp files cleaned');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning temp files: $e');
    }
  }

  /// Obtenir l'espace disque utilisé par l'application
  Future<int> getTotalStorageUsed() async {
    try {
      final appDir = await _appDirectory;
      int totalSize = 0;

      await for (final entity in appDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('❌ Error getting total storage: $e');
      return 0;
    }
  }
}

/// Informations sur un fichier
class FileInfo {
  final String path;
  final String name;
  final int size;
  final DateTime modified;
  final String extension;

  const FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
    required this.extension,
  });

  String get formattedSize {
    return StorageService.instance.formatFileSize(size);
  }
}
