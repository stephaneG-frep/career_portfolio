import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/education.dart';
import '../models/experience.dart';
import '../models/profile.dart';
import '../models/project.dart';
import '../models/skill.dart';

class PdfExportService {
  Future<void> export({
    required Profile profile,
    required List<Skill> skills,
    required List<PortfolioProject> projects,
    required List<Experience> experiences,
    required List<Education> education,
  }) async {
    final bytes = await build(
      profile: profile,
      skills: skills,
      projects: projects,
      experiences: experiences,
      education: education,
    );
    final safeName = profile.fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'portfolio_${safeName.isEmpty ? 'career' : safeName}.pdf',
    );
  }

  Future<Uint8List> build({
    required Profile profile,
    required List<Skill> skills,
    required List<PortfolioProject> projects,
    required List<Experience> experiences,
    required List<Education> education,
  }) async {
    final document = pw.Document(
      title: 'Portfolio de ${profile.fullName}',
      author: profile.fullName,
    );
    final navy = PdfColor.fromHex('#071B33');
    final cyan = PdfColor.fromHex('#00A8C6');
    final muted = PdfColor.fromHex('#667085');
    pw.MemoryImage? photo;
    if (profile.photoBase64 != null) {
      photo = pw.MemoryImage(base64Decode(profile.photoBase64!));
    }

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Container(
          color: navy,
          padding: const pw.EdgeInsets.all(52),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (photo != null)
                pw.ClipOval(
                  child: pw.Image(
                    photo,
                    width: 118,
                    height: 118,
                    fit: pw.BoxFit.cover,
                  ),
                ),
              pw.SizedBox(height: 30),
              pw.Text(
                profile.fullName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 38,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                profile.professionalTitle,
                style: pw.TextStyle(color: cyan, fontSize: 22),
              ),
              pw.SizedBox(height: 28),
              pw.Container(width: 70, height: 4, color: cyan),
              pw.SizedBox(height: 28),
              pw.Text(
                profile.shortBio,
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  lineSpacing: 5,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                [
                  profile.city,
                  profile.email,
                ].where((value) => value.isNotEmpty).join('  •  '),
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        header: (_) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            profile.fullName,
            style: pw.TextStyle(color: muted, fontSize: 9),
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(color: muted, fontSize: 9),
          ),
        ),
        build: (_) => [
          _heading('Profil', navy, cyan),
          pw.Text(profile.longBio.isEmpty ? profile.shortBio : profile.longBio),
          pw.SizedBox(height: 22),
          _heading('Compétences', navy, cyan),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#E8F5F8'),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      '${skill.name} — ${skill.level.label}',
                      style: pw.TextStyle(color: navy, fontSize: 10),
                    ),
                  ),
                )
                .toList(),
          ),
          pw.SizedBox(height: 24),
          _heading('Projets principaux', navy, cyan),
          ...projects
              .take(6)
              .map(
                (project) => _entry(
                  project.name,
                  '${project.status.label} • ${project.technologies.join(', ')}',
                  project.detailedDescription.isEmpty
                      ? project.shortDescription
                      : project.detailedDescription,
                  navy,
                  muted,
                ),
              ),
          pw.SizedBox(height: 16),
          _heading('Expériences', navy, cyan),
          ...experiences.map(
            (item) => _entry(
              item.position,
              '${item.company} • ${item.type.label}',
              item.description,
              navy,
              muted,
            ),
          ),
          pw.SizedBox(height: 16),
          _heading('Formations & certifications', navy, cyan),
          ...education.map(
            (item) => _entry(
              item.name,
              '${item.organization} • ${item.date.year}'
              '${item.duration.isEmpty ? '' : ' • ${item.duration}'}',
              item.notes,
              navy,
              muted,
            ),
          ),
          pw.SizedBox(height: 16),
          _heading('Coordonnées', navy, cyan),
          pw.Text(
            [
              profile.email,
              profile.phone,
              profile.website,
              profile.github,
              profile.linkedin,
              ...profile.otherLinks,
            ].where((value) => value.isNotEmpty).join('\n'),
          ),
        ],
      ),
    );
    return document.save();
  }

  pw.Widget _heading(String text, PdfColor navy, PdfColor accent) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      children: [
        pw.Container(width: 5, height: 20, color: accent),
        pw.SizedBox(width: 9),
        pw.Text(
          text,
          style: pw.TextStyle(
            color: navy,
            fontSize: 19,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  pw.Widget _entry(
    String title,
    String subtitle,
    String description,
    PdfColor navy,
    PdfColor muted,
  ) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 14),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: navy,
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(subtitle, style: pw.TextStyle(color: muted, fontSize: 9)),
        if (description.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(description, style: const pw.TextStyle(fontSize: 10)),
        ],
      ],
    ),
  );
}
