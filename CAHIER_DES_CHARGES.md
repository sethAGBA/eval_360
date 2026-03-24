# Cahier des Charges — Logiciel MDDL / CPDSE-CT

**Version** : v1.0 | **Date** : 2025 | **Statut** : 🟢 En développement  
**Structure** : CPDSE-CT / SDSE / MDDL | **Référence** : PTBA_CPDSE-CT_Logiciel_044027

---

## 1. Contexte et Objectifs
*   **Numériser** la gestion du PTBA, des activités et des rapports de la CPDSE-CT.
*   **Faciliter** la saisie hebdomadaire et mensuelle des rapports d'activités par les agents.
*   **Assurer le suivi en temps réel** du taux de réalisation du PTBA par axe et par activité.
*   **Produire automatiquement** les documents institutionnels (rapports, canevas, PTBA) conformes aux modèles MDDL.
*   **Permettre le suivi budgétaire** (État + PTF) et les alertes d'échéances.
*   **Centraliser** la gestion documentaire et la traçabilité des actions de la cellule.

---

## 2. Périmètre Fonctionnel — Les 14 Modules

| N° | Module / Écran | Fonctionnalités principales | Priorité | Sprint |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Tableau de bord** | Vue synthétique : activités du jour, tâches en attente, alertes, KPIs PTBA | Haute | Sprint 1 |
| **2** | **PTBA** | Saisie/édition du Plan de Travail Annuel (axes, objectifs, activités, financement) | Haute | Sprint 1 |
| **3** | **Suivi des activités** | Statut des activités, résultats réels vs attendus, lien avec PTBA | Haute | Sprint 2 |
| **4** | **Canevas rapport hebdo** | Saisie des activités hebdo, génération automatique du rapport | Haute | Sprint 2 |
| **5** | **Rapport mensuel** | Synthèse automatique des rapports hebdo, taux de réalisation, difficultés | Haute | Sprint 2 |
| **6** | **Gestion des tâches** | Création/assignation, priorités, suivi avancement (%), vue Kanban | Haute | Sprint 3 |
| **7** | **Gestion des agents** | Fiche agent, affectation tâches, suivi charge de travail, historique | Moyenne | Sprint 3 |
| **8** | **Suivi budgétaire** | Dépenses vs budget (État/PTF), taux d'exécution, alertes dépassement | Haute | Sprint 3 |
| **9** | **Gestion des PDC** | Base de données communes, suivi mise en œuvre PDC, missions terrain | Moyenne | Sprint 4 |
| **10** | **Partenaires (PTF)** | Répertoire PTF, projets en cours, financements, coordination | Moyenne | Sprint 4 |
| **11** | **Reporting & Stats** | Tableaux de bord analytiques, analyse par axe, export PDF/Excel | Haute | Sprint 5 |
| **12** | **Rapport stage** | Canevas numérique du rapport de stage probatoire, génération PDF | Moyenne | Sprint 5 |
| **13** | **Gestion documentaire** | Archivage numérique (TdR, CR, rapports), recherche full-text | Moyenne | Sprint 6 |
| **14** | **Paramétrage** | Configuration MDDL/CPDSE-CT, gestion rôles, utilisateurs, exercices | Haute | Sprint 1 |

---

## 3. Architecture Technique

| Composant | Détail technique |
| :--- | :--- |
| **Framework** | Flutter 3.x (Dart) — Desktop (Win/Lin/Mac) + Mobile (Android/iOS) |
| **Base de données** | **SQLite via drift** — Mode offline complet |
| **State management**| **Riverpod** — Clean Architecture + Repository Pattern |
| **Navigation** | GoRouter — Déclarative, multi-plateforme, gestion des rôles |
| **UI Design** | **Material 3** — Palette institutionnelle (vert Cameroun), dark mode |
| **Graphiques** | fl_chart — Courbes de réalisation, histogrammes budgétaires |
| **Export PDF** | printing + pdf — Rapports institutionnels, canevas, PTBA |
| **Export Excel** | excel (xlsx) — PTBA, tableaux de bord, exports budgétaires |
| **Notifications** | flutter_local_notifications — Alertes échéances, rappels tâches |
| **Sécurité** | Authentification PIN/biométrie, rôles granulaires, BDD chiffrée |

### Structure de navigation
*   **NavigationRail** (sidebar) : accès direct aux 14 modules.
*   **AppBar contextuelle** : titre du module + actions rapides.
*   **Corps principal** : contenu avec onglets (**TabBar**).
*   **FloatingActionButton** : "Nouvelle activité" / "Nouveau rapport".

---

## 4. Schéma de la Base de Données (16 Tables)

| Table | Rôle |
| :--- | :--- |
| `utilisateurs` | Comptes, matricules et rôles des agents |
| `exercices` | Exercices budgétaires (année, statut) |
| `axes_ptba` | Axes stratégiques du PTBA |
| `objectifs` | Objectifs rattachés aux axes |
| `activites` | Activités, indicateurs et moyens de vérification |
| `planning_activites`| Calendrier mensuel de planification |
| `financement` | Budget par activité (Source : État / PTF) |
| `suivi_activites` | Réalisations terrain, statuts et taux de réalisation |
| `rapports_hebdo` | Entêtes des rapports hebdomadaires |
| `lignes_rapport` | Détails des activités par ligne de rapport |
| `taches` | Tâches individuelles assignées aux agents |
| `communes_pdc` | Suivi des Communes et des Plans de Développement (PDC) |
| `partenaires_ptf` | Répertoire des partenaires techniques et financiers |
| `documents` | Gestion Électronique des Documents (GED) |
| `stages_probatoires`| Suivi et rapports des stagiaires |

---

## 5. Rôles et Accès

| Rôle | Accès | Restrictions |
| :--- | :--- | :--- |
| **Chef de Cellule** | Accès total | Aucune |
| **Agent** | Opérationnel (Rapports, activités, tâches) | Pas de modification PTBA/Paramètres |
| **Stagiaire** | Rapport de stage, rapports hebdo | Lecture seule sur données sensibles |
| **Auditeur / SG** | Consultation et Exports | Aucune écriture |
| **Administrateur** | Technique (Utilisateurs, BDD, Paramètres) | Pas d'accès aux données métier |

---

## 6. Livrables Attendus
*   **L1** : Application installable (Windows, Android).
*   **L2** : Code source documenté (Git).
*   **L3** : Manuels utilisateurs par profil (PDF).
*   **L4** : Base de données initiale SQLite pré-chargée.
*   **L5** : Documentation technique complète.
*   **L6** : Rapports de tests (Unitaires, Intégration, Recette).
