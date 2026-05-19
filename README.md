# mon-premier-cicd

[![CI — Lint, Tests & Coverage](https://github.com/VOTRE_USERNAME/mon-premier-cicd/actions/workflows/ci.yml/badge.svg)](https://github.com/VOTRE_USERNAME/mon-premier-cicd/actions/workflows/ci.yml)

> Pipeline CI/CD avancé — Jobs parallèles, matrice Node.js, cache npm, artefacts  
> M1 Expert Dev Full Stack — Séance 2 CI/CD

---

## Structure du projet

```
mon-premier-cicd/
├── .github/
│   └── workflows/
│       └── ci.yml              # Pipeline GitHub Actions (Séance 2)
├── src/
│   ├── calculator.js           # Code source
│   └── __tests__/
│       └── calculator.test.js  # Tests Jest
├── .eslintrc.json              # Configuration ESLint (+ règle no-var)
├── .gitignore
├── package.json                # + script test:ci
└── README.md
```

## Installation

```bash
git clone https://github.com/VOTRE_USERNAME/mon-premier-cicd.git
cd mon-premier-cicd
npm install
```

## Scripts disponibles

```bash
npm test          # Jest avec couverture (local)
npm run test:ci   # Jest mode strict CI (utilisé dans le pipeline)
npm run lint      # ESLint
npm run lint:fix  # Correction automatique ESLint
```

## Architecture du pipeline (Séance 2)

```
PUSH / PR
│
├──▶ 🔍 lint          (ubuntu-latest, Node 18, ~30s)
│
├──▶ 🧪 test (18)     (ubuntu-latest, Node 18, ~45s)  ─┐
│                                                        ├─▶ ✅ ci-success
└──▶ 🧪 test (20)     (ubuntu-latest, Node 20, ~45s)  ─┘
                                                         └─▶ 🔔 notify-failure (si échec)
```

| Job | Rôle |
|-----|------|
| **lint** | ESLint — qualité du code |
| **test (18)** | Jest sur Node 18 + rapport de couverture |
| **test (20)** | Jest sur Node 20 + rapport de couverture |
| **ci-success** | Vérifie que lint ET test sont verts |
| **notify-failure** | Alerte Slack si échec (nécessite secret `SLACK_WEBHOOK_URL`) |

## Fonctionnalités du pipeline

- **Jobs parallèles** — lint et test s'exécutent en même temps
- **Matrice Node.js 18 + 20** — 2 runs simultanés avec `fail-fast: false`
- **Cache npm** — `node_modules` mis en cache entre les runs (~20-35s économisés)
- **Artefacts** — rapports de couverture conservés 14 jours (`coverage-node-18`, `coverage-node-20`)
- **Step Summary** — tableau de couverture visible dans l'onglet Summary de GitHub Actions
- **PR Comment** — commentaire automatique avec la couverture sur chaque Pull Request
- **Notification Slack** — alerte automatique en cas d'échec (configurer `SLACK_WEBHOOK_URL` dans Settings → Secrets)

## Cycle Red / Green — Séance 2

### Tester needs: (partie 3.1)
```bash
# Dans src/calculator.js, ajouter :
var unused_variable = 'je ne suis jamais utilisée';
# → lint ✗  |  test ✓  |  ci-success ✗  (needs bloque tout)

# Corriger :
# Supprimer la ligne var
git add . && git commit -m "fix: suppression variable inutilisée" && git push
```

### Tester fail-fast: false (partie 3.2)
```bash
# Dans calculator.test.js, ajouter :
# test('version Node.js', () => {
#   expect(parseInt(process.version.slice(1))).toBeLessThan(20);
# });
# → test(18) ✓  |  test(20) ✗  → les DEUX rapports sont visibles

# Supprimer le test ensuite
```

## Branch protection (Bonus 5.1)

Pour bloquer les merges si le CI est rouge :  
`Repo → Settings → Branches → Add rule → main`  
☑ Require status checks: **✅ CI complet**

---

> **Important** : remplacez `VOTRE_USERNAME` dans le badge ci-dessus par votre vrai username GitHub.
