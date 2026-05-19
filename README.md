# mon-premier-cicd

[![CI — Lint, Tests & Coverage](https://github.com/VOTRE_USERNAME/mon-premier-cicd/actions/workflows/ci.yml/badge.svg)](https://github.com/VOTRE_USERNAME/mon-premier-cicd/actions/workflows/ci.yml)

> Pipeline CI/CD professionnel — 4 jobs parallèles, matrix Node 18/20, composite action, reusable workflow  
> M1 Expert Dev Full Stack — Séance 4 CI/CD

---

## Architecture du pipeline

```
PUSH (sur src/, package*.json, .github/)
│
├──▶ 🔍 lint         (ubuntu, Node 18, ~25s)  ─┐
│                                               │
├──▶ 🧪 test (18)    (ubuntu, ~35s)            ├──▶ 📊 report (~10s)
│         ↑ via reusable workflow              │
└──▶ 🧪 test (20)    (ubuntu, ~35s)            ─┘

Temps total : MAX(25, 35) + 10 = ~45s  vs  ~105s séquentiel → gain ~57%
```

| Job | Rôle | Durée |
|-----|------|-------|
| **lint** | ESLint via composite action | ~25s |
| **test (18)** | Jest Node 18 via reusable workflow | ~35s |
| **test (20)** | Jest Node 20 via reusable workflow | ~35s |
| **report** | Rapport consolidé Step Summary | ~10s |

## Fonctionnalités avancées

- **Composite action** — `.github/actions/setup-node-cached/` encapsule checkout + setup-node + npm ci
- **Reusable workflow** — `.github/workflows/test-reusable.yml` paramétrable (versions, seuil)
- **Path filters** — le pipeline ne se déclenche que si `src/`, `package*.json` ou `.github/` changent
- **Concurrency** — annule les runs obsolètes sur la même branche (`cancel-in-progress: true`)
- **fail-fast: false** — tous les runs de la matrix se complètent même si l'un échoue
- **Step Summary** — tableau de couverture avec ✅/❌ par version, visible sans télécharger d'artefact
- **Artefacts** — rapports HTML conservés 14 jours (`coverage-node-18`, `coverage-node-20`)

## Structure complète

```
mon-premier-cicd/
├── .github/
│   ├── actions/
│   │   └── setup-node-cached/
│   │       └── action.yml          # Composite action (Challenge ultime)
│   └── workflows/
│       ├── ci.yml                  # Pipeline principal
│       └── test-reusable.yml       # Reusable workflow (Challenge 3)
├── src/
│   ├── calculator.js
│   └── __tests__/
│       └── calculator.test.js      # 9 tests, couverture 100%
├── .eslintrc.json
├── .gitignore
├── NOTES.md                        # Réponses aux expérimentations
├── package.json
└── README.md
```

## Scripts

```bash
npm test          # Jest local (sans flag CI)
npm run test:ci   # Jest mode strict + couverture json-summary (utilisé dans le pipeline)
npm run lint      # ESLint
npm run lint:fix  # Correction automatique
```

## Expérimentations (Partie 3)

### Tester fail-fast (3.1)
```bash
# Ajouter dans calculator.test.js :
# test('node version check', () => {
#   const major = parseInt(process.version.slice(1).split('.')[0]);
#   expect(major).toBeLessThan(20);  // échoue sur Node 20
# });
git add . && git commit -m "test: échec intentionnel Node 20" && git push

# Observer : test(18) ✓  test(20) ✗  report s'exécute quand même (if: always())
# Puis supprimer le test et remettre fail-fast: false
```

### Tester concurrency (3.2)
```bash
git commit --allow-empty -m "ci: test concurrency 1" && git push
git commit --allow-empty -m "ci: test concurrency 2" && git push
git commit --allow-empty -m "ci: test concurrency 3" && git push
# → 2 runs "Cancelled", 1 seul va au bout
```

### Tester path filters (Challenge 1)
```bash
# Modifier uniquement README.md → pipeline NE se déclenche PAS
# Modifier src/calculator.js  → pipeline SE déclenche
```

---

> **Important** : remplacez `VOTRE_USERNAME` dans le badge par votre vrai username GitHub.
