# 🗺️ ROADMAP - Sprints de Remédiation UI (Phase 6)

Cette feuille de route vise à rendre le logiciel cohérent et prêt pour la production.

---

## ✅ Sprint A : Restauration des Processus Orphelins
- [x] Liste des TdR `tdrs_list_page.dart`
- [x] Liste des Ordres de Mission `ordres_mission_list_page.dart`
- [x] Liste des Rapports de Stage `rapports_stage_list_page.dart`
- [x] Navigation connectée (`app_router.dart` + `custom_sidebar.dart`)

---

## ✅ Sprint B : Synchronisation DB
- [x] Kanban Drag & Drop → update SQLite immédiat (déjà implémenté)
- [-] `project_detail_page.dart` (Onglets Activités) → à faire en Sprint D

---

## ✅ Sprint C : Persistance des Paramètres
- [x] Année d'exercice → `SharedPreferences` (survive au redémarrage)
- [x] Nom d'institution → `SharedPreferences` + dialogue de modification

---

## 📅 Sprint D : Nettoyage du Détail Projet (En cours)
**Objectif :** Dans la vue détail d'un projet (`/projects/:id`), les onglets Activités, Planning et Budget doivent afficher les vraies données SQLite liées au `projet_id` au lieu de listes vides.

- [ ] Créer un provider `activitesByProjectProvider(projetId)` 
- [ ] Relier les onglets du détail projet aux vraies données DB

---

_Une fois le Sprint D terminé, la navigation complète est 100% bout-en-bout._
