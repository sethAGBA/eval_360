# Audit et Plan de Remédiation UI (Eval360)

Ce document dresse l'inventaire des écrans comportant des données "en dur" (mockées), ceux souffrant d'un manque de synchronisation avec la base de données (SQLite), et les maillons manquants dans la navigation (pages sans point d'accès ou sans page liste).

---

## 1. Écrans développés avec des données "en dur" / Manque de Synchro

| Module / Écran | Fichier concerné | Problème (Données en dur / Synchro partielle) | Action Requise |
| :--- | :--- | :--- | :--- |
| **Paramètres (Module 14)** | `settings_page.dart` | L'onglet Général (Année active, Nom Institution) utilise un simple `StateProvider` temporaire. Au redémarrage, les données sont perdues. L'onglet "Référence" est statique dans le code. | Mettre en place la persistance localement (`SharedPreferences`) ou dans la BDD SQLite. |
| **Rapports Hebdo / Mensuels** | `monthly_reports_list_page.dart` | La grille des semaines (52) et des mois (12) est générée statiquement via `List.generate`. | Confirmer que le clic filtre bien les requêtes BDD correspondantes au mois/semaine visé. |
| **Profil Agent / Dashboard** | `agents_page.dart` et `tasks_page.dart` | Le Kanban de `tasks_page.dart` trace l'interface mais ne sauvegarde pas systématiquement les changements de statut (Drag & Drop) en base de données. | Connecter l'événement `onDragCompleted` du Kanban à une requête `UPDATE` immédiate en SQLite. |
| **Détails Projet (PTBA)** | `project_detail_page.dart` | Les sous-onglets gèrent des dummy data ou des listes vides statiques au lieu de remonter le flux d'activités réel du projet. | Purger la page des `List.generate()` simulés. Interroger SQLite via `projet_id` pour charger le vrai plan. |

---

## 2. Écrans mal liés et Pages Manquantes (Processus Orphelins)

Nous avons des formulaires de saisie complets, mais ces fonctionnalités "n'existent pas" d'un point de vue de l'utilisateur final car elles n'ont ni **page de liste** pour les afficher ni point d'entrée clair dans l'arborescence.

| Processus | Fichier Saisie Existant | Page Liste / Dashboard MANQUANTE ❌ | Solution |
| :--- | :--- | :--- | :--- |
| **TdR (Termes de Référence)** | `tdr_form_page.dart` | L'utilisateur crée un TdR mais ne sait pas où le retrouver pour l'imprimer ou l'éditer plus tard ! | Créer `tdrs_list_page.dart`. L'ajouter en sous-menu de la barre latérale sous GED/Processus. |
| **Ordres de Mission (ORD)** | `ordre_mission_form_page.dart`| Piste d'audit rompue. L'ORD est stocké en SQLite mais impossible de lire les historiques. | Créer `ordres_mission_list_page.dart` et relier le formulaire lors d'un "Nouveau". |
| **Rapports de Stage** | `rapport_stage_form_page.dart`| Le stagiaire remplit ses étapes, la ligne est poussée en DB. Aucun pôle "Validateur" pour l'instant capable de consulter ces rapports. | Créer `rapports_stage_list_page.dart` en liste avec des statuts : 'Soumis', 'En cours'. |

---

## 3. Plan d'Action Étape par Étape

Pour finaliser formellement l'application avec cohérence, voici le parcours conseillé :

### Sprint Correctif 1 : Restaurer les Lignes de Vie (Pages orphelines)
- Création de `tdrs_list_page.dart` (Vue de tous les Termes de référence, Filtres par projet, Bouton "Add").
- Création de `ordres_mission_list_page.dart`.
- Création de `rapports_stage_list_page.dart`.
- Ajustement du `app_router.dart` et `custom_sidebar.dart` pour indexer ces nouvelles listes depuis le menu collapsable de gauche.

### Sprint Correctif 2 : Élimination du Code "en dur"
- Nettoyage des Provider Riverpod (suppression des listes statiques utilisées au départ pour l'UI).
- Refactoring du bloc "Activités" et "Budget" de `project_detail_page.dart` pour se lier exclusivement sur `DatabaseService`.

### Sprint Correctif 3 : Persistance et UI Sync
- Mise en place d'un composant de persistance pour sauvegarder réellement (dans SharedPreferences) le paramétrage "Année Fiscale" choisi dans `settings_page.dart` (+ institution name).
- Rafraîchissement direct (invalidateProvider) à chaque Drag & Drop réussi sur le Tableau des Tâches (Kanban).
