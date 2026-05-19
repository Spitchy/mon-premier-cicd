# mon-premier-cicd

[![CI Pipeline](https://github.com/VOTRE_USERNAME/mon-premier-cicd/actions/workflows/ci.yml/badge.svg)](https://github.com/VOTRE_USERNAME/mon-premier-cicd/actions/workflows/ci.yml)

> Premier pipeline CI/CD avec GitHub Actions, Node.js, Jest et ESLint.  
> M1 Expert Dev Full Stack — Séance 1 CI/CD

---

## Structure du projet

```
mon-premier-cicd/
├── .github/
│   └── workflows/
│       └── ci.yml          # Pipeline GitHub Actions
├── src/
│   ├── calculator.js       # Code source
│   └── __tests__/
│       └── calculator.test.js  # Tests Jest
├── .eslintrc.json          # Configuration ESLint
├── .gitignore
├── package.json
└── README.md
```

## Installation

```bash
git clone https://github.com/VOTRE_USERNAME/mon-premier-cicd.git
cd mon-premier-cicd
npm ci
```

## Lancer les tests

```bash
npm test
```

## Lancer le lint

```bash
npm run lint
```

## Pipeline CI/CD

Le pipeline GitHub Actions s'exécute automatiquement à chaque `git push` sur `main` et à chaque Pull Request.

### Étapes du pipeline

| Job | Étapes | Description |
|-----|--------|-------------|
| **lint** | checkout → setup-node → npm ci → eslint | Vérifie la qualité du code |
| **test (Node 18)** | checkout → setup-node → npm ci → jest | Tests sur Node.js 18 + couverture |
| **test (Node 20)** | checkout → setup-node → npm ci → jest | Tests sur Node.js 20 + couverture |

Les jobs `lint` et `test` s'exécutent **en parallèle** (Bonus 4.1).  
Les tests tournent sur **Node.js 18 ET 20** simultanément (Bonus 4.2).  
Un **seuil de couverture de 80%** est configuré — le pipeline échoue en dessous (Bonus 4.3).

## Cycle Red / Green

Pour tester que le pipeline bloque bien les régressions :

```bash
# 1. Introduire un bug volontaire dans src/calculator.js
#    Changer : return a + b  →  return a - b

# 2. Pousser → pipeline passe au rouge ✗
git add . && git commit -m "test: bug volontaire" && git push

# 3. Corriger le bug
#    Remettre : return a + b

# 4. Pousser → pipeline repasse au vert ✓
git add . && git commit -m "fix: correction du bug" && git push
```

---

> **Important** : remplacez `VOTRE_USERNAME` dans le badge en haut de ce fichier par votre vrai nom d'utilisateur GitHub.
