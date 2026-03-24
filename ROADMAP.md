# Roadmap de Développement — Eval360 (CPDSE-CT)

Ce document définit les priorités pour compléter les 14 modules du cahier des charges.

## 📅 Phase 1 : Rapports Institutionnels & Suivi Hebdo (Priorité Haute)
*Objectif : Automatiser la paperasse hebdomadaire et mensuelle.*

- [ ] **Migration DB (Sprint 1.1)** : Ajout des tables `rapports_hebdo` et `lignes_rapport`.
- [ ] **Module 04 : Canevas Rapport Hebdomadaire** :
    - Interface de saisie structurée.
    - Liaison automatique avec les activités du PTBA.
    - Export PDF conforme au modèle MDDL.
- [ ] **Module 05 : Rapport Mensuel d'activités** :
    - Synthèse automatique des 4 rapports hebdo du mois.
    - Calcul automatique du taux de réalisation par axe.

## 📅 Phase 2 : Gestion Opérationnelle & Tâches (Priorité Moyenne)
*Objectif : Améliorer la collaboration et le suivi des agents.*

- [ ] **Migration DB (Sprint 2.1)** : Ajout de la table `taches`.
- [ ] **Module 06 : Gestion des Tâches** :
    - Vue Kanban des tâches par agent.
    - Système de priorité et d'échéances.
- [ ] **Module 07 : Gestion des Agents** :
    - Fiche agent détaillée et historique de charge de travail.
- [ ] **Notifications** : Alertes locales pour les échéances de tâches et d'activités.

## 📅 Phase 3 : Digitalisation & Spécificités (Priorité Moyenne)
*Objectif : Couvrir les besoins spécifiques (Stagiaires, Communes, GED).*

- [ ] **Module 12 : Rapport de Stage Probatoire** :
    - Interface dédiée à la saisie des rapports de stage.
    - Workflow de validation superviseur.
- [ ] **Module 13 : Gestion Documentaire (GED)** :
    - Archivage des TdR, CR et rapports (liaison avec les activités).
- [ ] **Module 09 : Suivi des PDC (Communes)** :
    - Base de données des communes (5 régions du Togo) et taux d'avancement des PDC.

## 📅 Phase 4 : Finalisation & Livraison (Priorité Basse)
*Objectif : Qualité, reporting global et clôture.*

- [ ] **Module 11 : Reporting & Statistiques** :
    - Consolidation des graphiques (axes PTBA).
    - Exports Excel complexes pour le suivi budgétaire global.
- [ ] **Nettoyage UI/UX** : Thème Material 3 (Vert Togo) et dark mode.
- [ ] **Livrables L3 & L6** : Manuel utilisateur et rapport de tests finaux.

---
**Note :** Le développement suivra une approche itérative (Scrum/Agile) avec des validations régulières par le Chef de Cellule.
