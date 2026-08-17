# Contacts

Application Flutter de gestion de contacts, réalisée dans le cadre d'un test
technique. Les données proviennent de l'API [randomuser.me](https://randomuser.me).

## Fonctionnalités

**Demandées :**
- Liste de contacts (50 au premier chargement) avec photo, nom et prénom
- Infinite scroll : les pages suivantes se chargent automatiquement au défilement
- Page de détails : photo, nom, prénom, adresse, email, téléphone fixe et mobile

**Ajoutées :**
- Recherche instantanée (debounce 350 ms) sur le nom, l'email et la ville
- Filtres par genre et par nationalité (appliqués côté API, la pagination repart de zéro)
- Favoris persistés localement (`shared_preferences`), consultables hors ligne
- Civilité (M. / Mme) déduite du genre, affichée sur la liste et la fiche,
  et section « Profil » (genre, âge, nationalité) sur la fiche contact
- Actions rapides depuis la fiche : appeler, envoyer un SMS, écrire un email
  (déclarations `<queries>` Android 11+ et `LSApplicationQueriesSchemes` iOS
  incluses, numéros nettoyés pour les URI `tel:`/`sms:`, snackbar si aucune
  app compatible)
- Copie d'une information dans le presse-papiers par appui long
- Pull-to-refresh, skeleton loader (shimmer) au premier chargement
- Gestion d'erreur fine : écran de retry au chargement initial, retry inline si
  une page suivante échoue (la liste déjà chargée n'est jamais perdue)
- Thème clair / sombre : suit le système par défaut, bascule manuelle depuis
  l'accueil (implémentée en pur Flutter avec `ValueNotifier` +
  `InheritedNotifier`, sans package), choix persisté entre les lancements
- Animation Hero sur la photo de profil
- Cache des images (`cached_network_image`)

## Architecture

Clean architecture allégée, adaptée à la taille du projet :

```
lib/
├── core/            # client HTTP (dio), erreurs, thème, utilitaires
├── domain/          # entité Contact + interface du repository
├── data/            # modèles JSON, data sources (API + local), implémentation du repository
└── presentation/    # pages, widgets et cubits (flutter_bloc)
    ├── contacts/    # liste, recherche, filtres, pagination
    ├── detail/      # fiche contact
    └── favorites/   # gestion des favoris
```

**Choix notables :**

- **flutter_bloc (Cubit)** : les états de la liste sont explicites
  (`loading`, `success`, `failure`, `isLoadingMore`, `loadMoreFailed`), ce qui
  rend la pagination et ses cas limites faciles à raisonner et à tester.
- **Seed de pagination** : sans paramètre `seed`, randomuser.me renvoie des
  utilisateurs différents à chaque appel, y compris pour une même page — donc
  des doublons dans un infinite scroll. Un seed fixe garantit des pages
  stables. Subtilité supplémentaire : le seed **écrase** les paramètres
  `gender` et `nat`, il est donc retiré dès qu'un filtre est actif ; la
  déduplication par `uuid` au merge prend alors le relais contre les doublons.
  À noter : la pagination de l'API commence à `page=1` (le `page=0` de
  l'énoncé renvoie la même chose que la page 1).
- **Premier chargement de 50** : l'énoncé demande 50 contacts par défaut ; le
  premier appel utilise `results=50`, comptabilisé comme 2 pages de 25 pour la
  suite du scroll.
- **Recherche locale** : l'API ne propose pas de recherche texte, le filtrage
  s'applique donc aux contacts déjà chargés (le footer de pagination est
  masqué pendant une recherche pour éviter toute confusion).
- **Garde anti-concurrence** : un seul `loadMore` en vol à la fois, pour
  éviter les doubles requêtes déclenchées par le listener de scroll.

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

- `contact_model_test` : parsing JSON (payload complet, champs manquants, round trip)
- `contacts_cubit_test` : chargement initial, échec réseau, pagination avec
  déduplication, échec d'une page suivante, garde anti-appels concurrents,
  filtrage de la recherche
- `contact_tile_test` : rendu de la tuile et navigation au tap
