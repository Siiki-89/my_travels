// Em lib/services/pdf_generator_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_travels/data/entities/comment_entity.dart';
import 'package:my_travels/data/entities/stop_point_entity.dart';
import 'package:my_travels/data/entities/travel_entity.dart';
import 'package:my_travels/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGeneratorService {
  final Travel travel;
  final Uint8List mapSnapshot;
  final AppLocalizations l10n;
  final List<Comment> comments;

  PdfGeneratorService({
    required this.travel,
    required this.mapSnapshot,
    required this.l10n,
    required this.comments,
  });

  Future<void> generateAndShareBooklet() async {
    final pdf = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.robotoRegular(),
      bold: await PdfGoogleFonts.robotoBold(),
      italic: await PdfGoogleFonts.robotoItalic(),
    );

    // Carrega a logo da empresa
    final logoSvg = await rootBundle.loadString(
      'assets/images/general/logo.svg',
    );
    final logoImage = pw.SvgImage(svg: logoSvg);

    // Adiciona as páginas ao PDF
    pdf.addPage(_buildCoverPage(theme));
    pdf.addPage(_buildParticipantsPage(theme));
    pdf.addPage(_buildMapPage(theme));

    // Adiciona uma página para cada parada da viagem
    for (final stopPoint in travel.stopPoints) {
      pdf.addPage(_buildStopPointPage(theme, stopPoint));
    }

    pdf.addPage(_buildFinalPage(theme, logoImage));

    // Usa o pacote 'printing' para salvar e compartilhar o PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${travel.title}_booklet.pdf',
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DAS PÁGINAS ---

  pw.Page _buildCoverPage(pw.ThemeData theme) {
    final coverImage = pw.MemoryImage(
      File(travel.coverImagePath!).readAsBytesSync(),
    );
    final period =
        '${DateFormat('dd/MM/yyyy').format(travel.startDate)} - ${DateFormat('dd/MM/yyyy').format(travel.endDate)}';

    return pw.Page(
      theme: theme,
      // Define a orientação da página, se necessário (A5 é mais alto que largo)
      pageFormat: PdfPageFormat.a5,
      build: (context) => pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          // --- AQUI ESTÁ A CORREÇÃO ---
          // Usamos Positioned.fill para que a imagem preencha todo o espaço da Stack.
          pw.Positioned.fill(child: pw.Image(coverImage, fit: pw.BoxFit.cover)),

          // --- FIM DA CORREÇÃO ---
          pw.Container(
            color: PdfColor.fromInt(0x80000000),
          ), // Sobreposição escura
          pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  travel.title,
                  style: pw.TextStyle(
                    fontSize: 40,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  period,
                  style: const pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 10),
                if (travel.vehicle != null)
                  pw.Text(
                    'Transporte: ${travel.vehicle}',
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.MultiPage _buildParticipantsPage(pw.ThemeData theme) {
    return pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a5,
      header: (context) => pw.Header(level: 0, text: 'Participantes da Viagem'),
      build: (context) => [
        pw.GridView(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          children: travel.travelers.map((traveler) {
            final imageProvider = traveler.photoPath != null
                ? pw.MemoryImage(File(traveler.photoPath!).readAsBytesSync())
                : null;
            return pw.Column(
              children: [
                pw.SizedBox(
                  width: 100,
                  height: 100,
                  child: imageProvider != null
                      ? pw.Image(imageProvider, fit: pw.BoxFit.cover)
                      : pw.Container(color: PdfColors.grey300),
                ),
                pw.SizedBox(height: 8),
                pw.Text(traveler.name),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Page _buildMapPage(pw.ThemeData theme) {
    final mapImage = pw.MemoryImage(mapSnapshot);
    return pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a5,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 0, text: 'Mapa da Viagem'),
          pw.SizedBox(height: 20),
          pw.Image(mapImage, fit: pw.BoxFit.contain),
        ],
      ),
    );
  }

  pw.MultiPage _buildStopPointPage(pw.ThemeData theme, StopPoint stopPoint) {
    // Encontra os comentários e fotos para esta parada específica
    final relevantComments = comments.where(
      (c) => c.stopPointId == stopPoint.id,
    );
    final photos = relevantComments.expand((c) => c.photos).toList();

    return pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a5,
      header: (context) =>
          pw.Header(level: 0, text: 'Parada: ${stopPoint.locationName}'),
      build: (context) => [
        if (photos.isNotEmpty)
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: photos.map((photo) {
              return pw.SizedBox(
                width: 120,
                height: 120,
                child: pw.Image(
                  pw.MemoryImage(File(photo.imagePath).readAsBytesSync()),
                  fit: pw.BoxFit.cover,
                ),
              );
            }).toList(),
          ),
        pw.SizedBox(height: 20),
        ...relevantComments.where((c) => c.content.trim().isNotEmpty).map((
          comment,
        ) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            margin: const pw.EdgeInsets.only(bottom: 10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('"${comment.content}"'),
                pw.SizedBox(height: 8),
                pw.Text(
                  '- ${comment.traveler?.name ?? 'Anônimo'}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Page _buildFinalPage(pw.ThemeData theme, pw.SvgImage logo) {
    return pw.Page(
      theme: theme,
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.SizedBox(height: 100, width: 100, child: logo),
            pw.SizedBox(height: 50),
            pw.Text(
              'l10n.pdfFinalMessagePart1', // "UMA VIAGEM NÃO SE MEDE EM MILHAS, MAS EM MOMENTOS."
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'l10n.pdfFinalMessagePart2', // "CADA PÁGINA DESTE LIVRETO..."
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
