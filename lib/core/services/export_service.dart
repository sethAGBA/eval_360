import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import '../models/projet.dart';
import '../models/depense.dart';
import '../services/database_service.dart';
import '../models/activite.dart';
import '../models/indicateur.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';

class ExportService {
  static final ExportService instance = ExportService._();
  ExportService._();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'FCFA',
    decimalDigits: 0,
    locale: 'fr_FR',
  );

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
    
    String fileName = 'Rapport_${projet.codeProjet}_${projet.titre}.pdf';
    // Remove characters that might be invalid in file names
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
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => _buildGlobalHeader(context),
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

  pw.Widget _buildGlobalHeader(pw.Context context) {
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
}
