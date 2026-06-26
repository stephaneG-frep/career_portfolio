import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';

import '../models/education.dart';
import '../models/experience.dart';
import '../models/profile.dart';
import '../models/project.dart';
import '../models/skill.dart';

class HtmlExportService {
  Future<String?> export({
    required Profile profile,
    required List<Skill> skills,
    required List<PortfolioProject> projects,
    required List<Experience> experiences,
    required List<Education> education,
  }) async {
    final archive = Archive();
    final assetPaths = <String, String>{};

    void addImage(String key, String base64Value, String filename) {
      final bytes = base64Decode(base64Value);
      archive.addFile(ArchiveFile('assets/$filename', bytes.length, bytes));
      assetPaths[key] = 'assets/$filename';
    }

    if (profile.photoBase64 != null) {
      addImage('profile', profile.photoBase64!, 'profile.jpg');
    }
    for (var p = 0; p < projects.length; p++) {
      for (var i = 0; i < projects[p].imageBase64List.length; i++) {
        addImage(
          'project_${p}_$i',
          projects[p].imageBase64List[i],
          'project_${p}_$i.jpg',
        );
      }
    }

    final html = _buildHtml(
      profile,
      skills,
      projects,
      experiences,
      education,
      assetPaths,
    );
    final htmlBytes = Uint8List.fromList(utf8.encode(html));
    archive.addFile(ArchiveFile('index.html', htmlBytes.length, htmlBytes));
    archive.addFile(ArchiveFile('assets/.keep', 0, Uint8List(0)));
    final zip = Uint8List.fromList(ZipEncoder().encode(archive));
    const filename = 'career_portfolio_html';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return FileSaver.instance.saveAs(
        name: filename,
        bytes: zip,
        fileExtension: 'zip',
        mimeType: MimeType.zip,
      );
    }

    return FileSaver.instance.saveFile(
      name: filename,
      bytes: zip,
      fileExtension: 'zip',
      mimeType: MimeType.zip,
    );
  }

  String _buildHtml(
    Profile profile,
    List<Skill> skills,
    List<PortfolioProject> projects,
    List<Experience> experiences,
    List<Education> education,
    Map<String, String> assets,
  ) {
    String e(String value) => const HtmlEscape().convert(value);
    String link(String url, String label) => url.isEmpty
        ? ''
        : '<a href="${e(url)}" target="_blank" rel="noopener">${e(label)}</a>';
    final contacts = [
      link('mailto:${profile.email}', profile.email),
      link(profile.website, 'Site web'),
      link(profile.github, 'GitHub'),
      link(profile.linkedin, 'LinkedIn'),
      ...profile.otherLinks.map((url) => link(url, url)),
    ].where((value) => value.isNotEmpty).join('');

    return '''<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="description" content="${e(profile.shortBio)}">
  <title>${e(profile.fullName)} — Portfolio</title>
  <style>
    :root{--navy:#071b33;--ink:#172033;--muted:#667085;--cyan:#00a8c6;--violet:#7857d9;--paper:#fffbf5;--card:#fff;--line:#e6e8ec}
    *{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font:16px/1.65 system-ui,-apple-system,Segoe UI,sans-serif}
    a{color:var(--cyan);text-decoration:none}.container{width:min(1100px,calc(100% - 40px));margin:auto}
    header{background:linear-gradient(120deg,var(--navy),#342365);color:#fff;padding:90px 0 70px}
    .hero{display:flex;gap:36px;align-items:center}.avatar{width:150px;height:150px;object-fit:cover;border-radius:50%;border:5px solid #ffffff30}
    h1{font-size:clamp(2.3rem,6vw,4.5rem);line-height:1;margin:0 0 14px}header h2{color:#72def1;margin:0 0 18px;font-weight:500}
    main{padding:55px 0}section{margin-bottom:54px}h2{color:var(--navy);font-size:1.8rem}.grid{display:grid;grid-template-columns:repeat(2,1fr);gap:18px}
    .card{background:var(--card);border:1px solid var(--line);border-radius:18px;padding:24px;box-shadow:0 12px 35px #071b330d}
    .card img{width:100%;aspect-ratio:16/8;object-fit:cover;border-radius:12px}.tags{display:flex;flex-wrap:wrap;gap:8px}.tag{background:#e8f7fa;color:#075467;padding:5px 10px;border-radius:999px;font-size:.88rem}
    .timeline{border-left:3px solid var(--cyan);padding-left:24px}.timeline article{margin-bottom:28px}.muted{color:var(--muted)}
    footer{background:var(--navy);color:#fff;padding:42px 0}.links{display:flex;flex-wrap:wrap;gap:18px}
    @media(max-width:700px){.hero{align-items:flex-start;flex-direction:column}.grid{grid-template-columns:1fr}header{padding:55px 0}.avatar{width:110px;height:110px}}
  </style>
</head>
<body>
<header><div class="container hero">
  ${assets['profile'] == null ? '' : '<img class="avatar" src="${assets['profile']}" alt="${e(profile.fullName)}">'}
  <div><h1>${e(profile.fullName)}</h1><h2>${e(profile.professionalTitle)}</h2><p>${e(profile.shortBio)}</p><span>${e(profile.city)}</span></div>
</div></header>
<main class="container">
  <section><h2>À propos</h2><p>${e(profile.longBio)}</p></section>
  <section><h2>Compétences</h2><div class="tags">${skills.map((s) => '<span class="tag">${e(s.name)} · ${e(s.level.label)}</span>').join()}</div></section>
  <section><h2>Projets</h2><div class="grid">${projects.asMap().entries.map((entry) {
      final p = entry.value;
      final image = assets['project_${entry.key}_0'];
      return '<article class="card">${image == null ? '' : '<img src="$image" alt="${e(p.name)}">'}<h3>${e(p.name)}</h3><p class="muted">${e(p.status.label)}</p><p>${e(p.shortDescription)}</p><div class="tags">${p.technologies.map((t) => '<span class="tag">${e(t)}</span>').join()}</div><p>${link(p.githubUrl, 'Code source')} ${link(p.demoUrl, 'Démonstration')}</p></article>';
    }).join()}</div></section>
  <section><h2>Expériences</h2><div class="timeline">${experiences.map((x) => '<article><h3>${e(x.position)}</h3><div class="muted">${e(x.company)} · ${x.startDate.year} — ${x.endDate?.year ?? 'Aujourd’hui'}</div><p>${e(x.description)}</p></article>').join()}</div></section>
  <section><h2>Formations & certifications</h2><div class="grid">${education.map((x) => '<article class="card"><h3>${e(x.name)}</h3><div class="muted">${e(x.organization)} · ${x.date.year}</div><p>${e(x.notes)}</p></article>').join()}</div></section>
</main>
<footer><div class="container"><h2 style="color:white">Me contacter</h2><div class="links">$contacts</div></div></footer>
</body></html>''';
  }
}
