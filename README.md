# Test technique — Mini catalogue (squelette)

Ce dépôt contient les instructions et les artefacts initiaux pour réaliser le test technique "Développeur-euse Fullstack" demandé par PROXIMITY.

But de ce dépôt :
- Initialiser le repo git.
- Fournir un fichier d'instructions détaillées (`INSTRUCTIONS_FOR_COPILOT.md`) pour que Copilot (ou un développeur) puisse implémenter rapidement le back Symfony (EasyAdmin + ApiPlatform), le front React et les tests.

Les fichiers fournis ici ne contiennent pas encore l'application complète, mais décrivent précisément les étapes à suivre, les bonnes pratiques et la configuration CI/Docker minimale.

Voir `INSTRUCTIONS_FOR_COPILOT.md` pour la procédure complète.

---

Essentiel pour démarrer (exemples) :

- Backend (Symfony) :
  - composer install
  - copier `.env.dist` en `.env` et ajuster DATABASE_URL
  - bin/console doctrine:migrations:migrate

- Frontend (React) :
  - npm install (ou yarn)
  - npm run dev

---

Livrable : un repo GitHub ou un zip contenant le backend et le frontend, fixtures, documentation API et instructions pour démarrer.
