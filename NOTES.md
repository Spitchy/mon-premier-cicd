# NOTES.md — Séance 4 CI/CD

## Partie 3.1 — Expérience fail-fast

### Questions (à observer sur GitHub Actions après le push du test volontaire)

**1. test(18) est-il annulé quand test(20) échoue ?**

Avec `fail-fast: false` (config actuelle) :
→ NON. Les deux runs se complètent indépendamment.
  test(18) continue et termine normalement même si test(20) échoue.

Avec `fail-fast: true` :
→ OUI. Dès que test(20) échoue, test(18) est immédiatement annulé (statut "Cancelled").

**2. Le job report démarre-t-il malgré l'échec de test(20) ?**

→ OUI, car il possède `if: always()`.
  Sans ce flag, le job `report` serait sauté si un de ses `needs` échoue.
  `if: always()` force l'exécution quoi qu'il arrive.

**3. Que contient le Step Summary dans le rapport ?**

→ Le tableau de couverture s'affiche pour les versions dont les artefacts ont été uploadés.
  Si test(20) a échoué avant l'upload, seul le rapport Node 18 apparaît.
  Le Step Summary se termine par "❌ CI échoué" car needs.test.result != 'success'.

**4. Quel est l'exit code final du workflow ?**

→ Exit code 1 (échec).
  Le job `report` fait un `exit 1` explicite si lint ou test n'est pas 'success'.
  Le workflow global passe au rouge (❌) sur GitHub.

---

## Partie 3.2 — Expérience concurrency

### Observation après 3 pushes rapides

→ 2 des 3 runs ont le statut "Cancelled" dans l'onglet Actions.
→ Seul le 3ème run (le plus récent) s'exécute jusqu'au bout.

**Pourquoi ?**
La clé `concurrency.group` est identique pour tous les runs sur la même branche.
Quand un nouveau run démarre avec la même clé, `cancel-in-progress: true` annule le run précédent.
→ On économise des minutes de CI et on évite les conflits d'artefacts entre commits proches.

---

## Partie 3.3 — Comparaison des rapports Node 18 vs Node 20

### Résultat observé

→ Les deux rapports affichent des pourcentages identiques (100% sur toutes les métriques).

**Pourquoi identiques ?**
Le code de `calculator.js` n'utilise aucune API spécifique à une version de Node.js.
Les opérations arithmétiques de base (`+`, `-`, `*`, `/`) se comportent de manière identique
sur Node 18 et Node 20.

**Quand seraient-ils différents ?**
Si le code utilisait des APIs Node.js dont le comportement change entre versions,
par exemple : `fs.promises`, les Streams, ou des APIs expérimentales.
Le but de la matrix est précisément de détecter ces différences.

---

## Challenge 1 — Path filters

### Risque d'un filtre trop restrictif

Si `paths` est trop restrictif, un commit qui modifie uniquement `README.md` ou
la configuration ESLint ne déclenchera pas le pipeline.
→ Risque : des changements qui semblent non-fonctionnels peuvent en réalité affecter
le build (ex : modifier `.eslintrc.json` sans relancer le lint).

**Bonne pratique** : toujours inclure `.github/workflows/**` dans les paths pour
s'assurer que les changements de pipeline déclenchent bien un run.

---

## Gains de performance mesurés

| Pipeline | Durée estimée |
|----------|--------------|
| Séquentiel (S1) | ~105s |
| Parallèle (S4) | ~45s |
| Gain | ~57% |

Formule : (105 - 45) / 105 × 100 = **~57% de gain**
