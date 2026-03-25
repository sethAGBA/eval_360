import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:open_file_plus/open_file_plus.dart';

import '../models/projet.dart';
import '../models/depense.dart';
import '../models/app_config.dart';
import '../models/activite.dart';
import '../models/indicateur.dart';
import '../models/rapport_hebdo.dart';
import '../models/ligne_rapport.dart';
import '../models/rapport_mensuel.dart';
import '../models/synthese_axe.dart';
import '../services/database_service.dart';


class ExportService {
  static final ExportService instance = ExportService._();
  ExportService._();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'FCFA',
    decimalDigits: 0,
    locale: 'fr_FR',
  );

  // ============================================================================
  // HELPER: Sauvegarde et ouverture sécurisées (évite les erreurs shell macOS)
  // ============================================================================

  /// Sauvegarde le PDF dans un dossier choisi par l'utilisateur et l'ouvre.
  /// Passe par un fichier temporaire pour éviter les problèmes avec
  /// les apostrophes et caractères spéciaux dans les chemins macOS/Windows.
  Future<void> _saveAndOpen(List<int> bytes, String fileName) async {
    // 1. Choisir le dossier de destination
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choisir le dossier d\'enregistrement',
    );
    if (selectedDirectory == null) return;

    // 2. Sanitiser le nom de fichier (pas le chemin)
    final safeFileName = fileName.replaceAll(RegExp('[\\\\/:*?"\'<>|]'), '_');

    // 3. Écrire d'abord dans un répertoire temporaire (chemin garanti sans
    //    caractères spéciaux) pour pouvoir l'ouvrir via OpenFile
    final tempDir = Directory.systemTemp;
    final tempPath = '${tempDir.path}/$safeFileName';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);

    // 4. Ouvrir depuis le chemin temporaire (pas de problème de shell)
    await OpenFile.open(tempPath);

    // 5. Copier vers la destination choisie par l'utilisateur
    final destPath = '$selectedDirectory/$safeFileName';
    await tempFile.copy(destPath);
  }

  Future<void> exportProjectReport({
    required Projet projet,
    required ProjectStats stats,
    required List<Activite> activites,
    required List<Indicateur> indicateurs,
  }) async {
    final pdf = pw.Document();

    // Use default fonts for simplicity first, or try Google Fonts
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => _buildHeader(context, projet),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildProjectSummary(projet, stats),
          pw.SizedBox(height: 20),
          _buildIndicateursSection(indicateurs),
          pw.SizedBox(height: 20),
          _buildActivitesSection(activites),
        ],
      ),
    );
    final bytes = await pdf.save();

    final String fileName = 'Rapport_${projet.codeProjet}_${projet.titre}.pdf';
    await _saveAndOpen(bytes, fileName);
  }

  pw.Widget _buildHeader(pw.Context context, Projet projet) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'RAPPORT DE PROJET',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              projet.codeProjet,
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Généré par Eval360 le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildProjectSummary(Projet projet, ProjectStats stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          projet.titre,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _buildInfoItem(
                'Date de début',
                _dateFormat.format(projet.dateDebutPrevue),
              ),
            ),
            pw.Expanded(
              child: _buildInfoItem(
                'Date de fin',
                _dateFormat.format(projet.dateFinPrevue),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Indicateurs',
                '${stats.nombreIndicateursAtteints}/${stats.nombreIndicateurs}',
              ),
              _buildStatItem('Activités', stats.nombreActivites.toString()),
              _buildStatItem(
                'Bénéficiaires',
                '${stats.nombreBeneficiairesAtteints}/${stats.nombreBeneficiaires}',
              ),
              _buildStatItem(
                'Budget',
                _currencyFormat.format(projet.budgetTotal),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue800),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildIndicateursSection(List<Indicateur> indicateurs) {
    if (indicateurs.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Performance des Indicateurs',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Code', 'Intitulé', 'Cible', 'Réalisé', 'Progrès'],
          data: indicateurs.map((i) {
            final cible = i.cibleFinale ?? 0.0;
            final progress = cible > 0 ? (i.valeurActuelle / cible * 100) : 0;
            return [
              i.codeIndicateur,
              i.libelle,
              cible.toString(),
              i.valeurActuelle.toString(),
              '${progress.toStringAsFixed(1)}%',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
          cellHeight: 30,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
            4: pw.Alignment.center,
          },
        ),
      ],
    );
  }

  pw.Widget _buildActivitesSection(List<Activite> activites) {
    if (activites.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Suivi des Activités',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Activité', 'Statut', 'Avancement', 'Bénéficiaires'],
          data: activites.map((a) {
            return [
              a.intitule,
              a.statut.name,
              '${a.pourcentageAvancement}%',
              '${a.nombreBeneficiairesAtteints}/${a.nombreBeneficiairesCibles}',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
          cellHeight: 30,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
          },
        ),
      ],
    );
  }

  Future<void> exportGlobalReport({
    required List<Projet> projets,
    required DashboardStats stats,
  }) async {
    // Charger la configuration et le logo
    final config = await DatabaseService.instance.getAppConfig();
    pw.MemoryImage? logoImage;
    if (config.logoPath != null && File(config.logoPath!).existsSync()) {
      try {
        logoImage = pw.MemoryImage(File(config.logoPath!).readAsBytesSync());
      } catch (e) {
        // debugPrint('❌ Erreur chargement logo PDF: $e'); // Assuming debugPrint is available
      }
    }

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => _buildGlobalHeader(context, logoImage),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildGlobalStats(stats),
          pw.SizedBox(height: 20),
          _buildProjectListTable(projets),
        ],
      ),
    );
    final bytes = await pdf.save();
    
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choisir le dossier d\'enregistrement',
    );

    if (selectedDirectory != null) {
      final String fileName = 'Rapport_Global_Portfolio_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final String fullPath = '$selectedDirectory/$fileName';
      final file = File(fullPath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(fullPath);
    }
  }

  pw.Widget _buildGlobalHeader(pw.Context context, [pw.MemoryImage? logoImage]) {
    return pw.Column(
      children: [
        pw.Text(
          'RAPPORT GLOBAL DU PORTFOLIO',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildGlobalStats(DashboardStats stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Projets Actifs', stats.activeProjects.toString()),
          _buildStatItem(
            'Budget Total',
            _currencyFormat.format(stats.budgetTotal),
          ),
          _buildStatItem('Bénéficiaires', stats.totalBeneficiaires.toString()),
          _buildStatItem(
            'Indicateurs',
            '${stats.tauxIndicateurs.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectListTable(List<Projet> projets) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Liste des Projets',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Code', 'Titre', 'Statut', 'Budget Total'],
          data: projets.map((p) {
            return [
              p.codeProjet,
              p.titre,
              p.statut.label,
              _currencyFormat.format(p.budgetTotal),
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
          cellHeight: 25,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.center,
            3: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }

  Future<void> exportExpensesExcel({
    required Projet projet,
    required List<Depense> depenses,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Dépenses_${projet.codeProjet}'];
    excel.delete('Sheet1'); // Remove default sheet

    // Headers
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('N° Pièce'),
      TextCellValue('Type'),
      TextCellValue('Description'),
      TextCellValue('Fournisseur'),
      TextCellValue('Montant (FCFA)'),
      TextCellValue('Mode'),
      TextCellValue('Statut'),
    ]);

    // Data rows
    for (final d in depenses) {
      sheet.appendRow([
        TextCellValue(_dateFormat.format(d.dateOperation)),
        TextCellValue(d.numeroPiece),
        TextCellValue(d.typeOperation),
        TextCellValue(d.description ?? ''),
        TextCellValue(d.fournisseurPrestataire ?? ''),
        IntCellValue(d.montant.toInt()),
        TextCellValue(d.modePaiement.label),
        TextCellValue(d.statutValidation.label),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choisir le dossier d\'enregistrement',
      );

      if (selectedDirectory != null) {
        final String fileName = 'Depenses_${projet.codeProjet}.xlsx';
        final String fullPath = '$selectedDirectory/$fileName';
        final file = File(fullPath);
        await file.writeAsBytes(bytes);
        await OpenFile.open(fullPath);
      }
    }
  }

  // ============================================================================
  // EXPORT RAPPORT HEBDOMADAIRE (Module 04)
  // ============================================================================

  Future<void> exportWeeklyReportToPdf({
    required RapportHebdo rapport,
    required List<LigneRapport> lignes,
    String? agentNom,
  }) async {
    // Charger la configuration et le logo
    final config = await DatabaseService.instance.getAppConfig();
    pw.MemoryImage? logoImage;
    if (config.logoPath != null && File(config.logoPath!).existsSync()) {
      try {
        logoImage = pw.MemoryImage(File(config.logoPath!).readAsBytesSync());
      } catch (e) {
        debugPrint('❌ Erreur chargement logo PDF: $e');
      }
    }

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Fetch activity details to show codes
    final List<String?> activityCodes = [];
    for (final ligne in lignes) {
      if (ligne.activiteId != null) {
        final act = await DatabaseService.instance.getActiviteById(ligne.activiteId!);
        activityCodes.add(act?.codeActivite);
      } else {
        activityCodes.add(null);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => _buildWeeklyHeader(context, rapport, config, logoImage),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildWeeklyReportInfo(rapport, agentNom),
          pw.SizedBox(height: 20),
          _buildWeeklyActivitiesTable(lignes, activityCodes),
          pw.SizedBox(height: 30),
          _buildSignatureSection(rapport),
        ],
      ),
    );

    final bytes = await pdf.save();
    
    // Sanitize file name for shell safety
    String fileName = 'Rapport_Hebdo_S${rapport.semaineNumero}_${rapport.annee}.pdf';
    fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choisir le dossier d\'enregistrement',
    );

    if (selectedDirectory != null) {
      final String fullPath = '$selectedDirectory/$fileName';
      final file = File(fullPath);
      await file.writeAsBytes(bytes);
      
      // Use quotes to handle paths with spaces if necessary, 
      // though OpenFile usually handles this.
      await OpenFile.open(fullPath);
    }
  }

  pw.Widget _buildWeeklyHeader(pw.Context context, RapportHebdo rapport, AppConfig config, pw.MemoryImage? logoImage) {
    return _buildPdfHeader('RAPPORT HEBDOMADAIRE', config, logoImage);
  }

  pw.Widget _buildWeeklyReportInfo(RapportHebdo rapport, String? agentNom) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Agent:', agentNom ?? 'Non spécifié'),
              _buildInfoRow('Période:', 'Semaine ${rapport.semaineNumero} / ${rapport.annee}'),
              _buildInfoRow('Dates:', 'Du ${_dateFormat.format(rapport.dateDebut)} au ${_dateFormat.format(rapport.dateFin)}'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Statut:', rapport.statutValidation.label.toUpperCase()),
              _buildInfoRow('Date de génération:', _dateFormat.format(DateTime.now())),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildWeeklyActivitiesTable(List<LigneRapport> lignes, List<String?> activityCodes) {
    return pw.Table.fromTextArray(
      headers: [
        'Code PTBA',
        'Activités / Tâches',
        'Lieu',
        'Dates',
        'Statut',
        'Résultats / Observations'
      ],
      data: List.generate(lignes.length, (index) {
        final l = lignes[index];
        final code = activityCodes[index] ?? '-';
        return [
          code,
          l.description,
          l.lieu ?? '-',
          '${_dateFormat.format(l.dateDebut)}\n${_dateFormat.format(l.dateFin)}',
          l.statutActivite,
          l.resultatsAtteints ?? '-',
        ];
      }),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellHeight: 40,
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(3),
      },
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerLeft,
      },
    );
  }

  pw.Widget _buildSignatureSection(RapportHebdo rapport) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Text('L\'Agent', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 40),
            pw.Text('____________________', style: const pw.TextStyle(color: PdfColors.grey400)),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('Le Superviseur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 40),
            pw.Text(
              rapport.statutValidation == StatutValidationRapport.valide
                  ? 'APPROUVÉ LE ${rapport.dateValidation != null ? _dateFormat.format(rapport.dateValidation!) : ""}'
                  : '____________________',
              style: pw.TextStyle(
                color: rapport.statutValidation == StatutValidationRapport.valide
                    ? PdfColors.green800
                    : PdfColors.grey400,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Exporter un rapport mensuel au format PDF
  Future<void> exportMonthlyReportToPdf({
    required RapportMensuel rapport,
    required List<SyntheseAxe> syntheses,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Charger la configuration et le logo
    final config = await DatabaseService.instance.getAppConfig();
    pw.MemoryImage? logoImage;
    if (config.logoPath != null && File(config.logoPath!).existsSync()) {
      try {
        logoImage = pw.MemoryImage(File(config.logoPath!).readAsBytesSync());
      } catch (e) {
        debugPrint('❌ Erreur chargement logo PDF: $e');
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => _buildPdfHeader('RAPPORT MENSUEL D\'ACTIVITÉS', config, logoImage),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildMonthlyInfoSection(rapport),
          pw.SizedBox(height: 24),
          pw.Text(
            'SYNTHÈSE DE PERFORMANCE PAR AXE STRATÉGIQUE',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildSyntheseAxesTable(syntheses),
          pw.SizedBox(height: 24),
          pw.Text(
            'RECOMMANDATIONS ET PERSPECTIVES',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Renforcement du suivi de proximité pour l\'axe Infrastructures.'),
          pw.Bullet(text: 'Accélération des décaissements pour les activités en cours.'),
          pw.SizedBox(height: 40),
          _buildMonthlySignatureSection(rapport),
        ],
      ),
    );

    final bytes = await pdf.save();
    String fileName = 'Rapport_Mensuel_${rapport.moisNom}_${rapport.annee}.pdf';
    fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choisir le dossier d\'enregistrement',
    );

    if (selectedDirectory != null) {
      final String fullPath = '$selectedDirectory/$fileName';
      final file = File(fullPath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(fullPath);
    }
  }

  pw.Widget _buildMonthlyInfoSection(RapportMensuel rapport) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Mois', rapport.moisNom),
              _buildInfoItem('Année', rapport.annee.toString()),
              _buildInfoItem('Taux Global', '${rapport.tauxRealisationGlobal.toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSyntheseAxesTable(List<SyntheseAxe> syntheses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FixedColumnWidth(80),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Axe Stratégique', isHeader: true),
            _buildTableCell('Prévues', isHeader: true),
            _buildTableCell('Réalisées', isHeader: true),
            _buildTableCell('Taux (%)', isHeader: true),
          ],
        ),
        // Lignes
        ...syntheses.map((s) => pw.TableRow(
          children: [
            _buildTableCell(s.libelleAxe),
            _buildTableCell(s.nombreActivitesPrevues.toString(), align: pw.TextAlign.center),
            _buildTableCell(s.nombreActivitesRealisees.toString(), align: pw.TextAlign.center),
            _buildTableCell('${s.tauxRealisation.toStringAsFixed(1)}%', align: pw.TextAlign.center),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildPdfHeader(String title, AppConfig config, pw.MemoryImage? logoImage) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Bloc de gauche (Logo + Info)
            pw.Row(
              children: [
                if (logoImage != null)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 10),
                    child: pw.Container(
                      width: 50,
                      height: 50,
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      config.republique,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      config.sigle,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      config.entite,
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'Logiciel Eval360',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Divider(thickness: 1.5, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildMonthlySignatureSection(RapportMensuel rapport) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Text('L\'Agent', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 40),
            pw.Text('____________________', style: const pw.TextStyle(color: PdfColors.grey400)),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('Le Superviseur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 40),
            pw.Text(
              rapport.statutValidation == StatutValidationRapport.valide
                  ? 'APPROUVÉ LE ${rapport.dateValidation != null ? _dateFormat.format(rapport.dateValidation!) : ""}'
                  : '____________________',
              style: pw.TextStyle(
                color: rapport.statutValidation == StatutValidationRapport.valide
                    ? PdfColors.green800
                    : PdfColors.grey400,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
