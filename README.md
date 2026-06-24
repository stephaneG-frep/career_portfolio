# CareerPortfolio

Application Flutter locale pour créer, prévisualiser et exporter un portfolio
professionnel. Aucune authentification, collecte de données ou infrastructure
serveur n'est utilisée.

## Fonctionnalités

- Profil professionnel avec photo et liens
- Compétences, projets, expériences, formations et certifications
- Recherche et filtres
- Aperçu responsive du portfolio
- Export PDF
- Export HTML statique sous forme d'une archive ZIP (`index.html` + `assets/`)
- Stockage local Hive CE et données de démonstration au premier lancement
- Thèmes clair et sombre

## Plateformes

- Android
- Linux
- Web

## Lancement

```bash
flutter pub get
flutter run
```

Choisir explicitement une plateforme si nécessaire :

```bash
flutter run -d linux
flutter run -d chrome
```

## Vérification

```bash
flutter analyze
flutter test
flutter build web
flutter build linux
flutter build apk --debug
```
