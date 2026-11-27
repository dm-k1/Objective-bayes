# Objective-bayes: what a default prior should keep flat

The argument behind [flatcor](https://github.com/dm-k1/flatcor), an R package
for objective Bayes factors and estimation in linear regression, and the
paper that makes it: why a choice of default prior is needed, what the four
candidate priors are, how they relate to the priors already in use, and which
to recommend.

> Define what's possible, not what you expect.

When a default Bayes factor tests one regression coefficient, the answer can
depend on how many other predictors are in the model. Whether it does depends
on what the default prior keeps flat as predictors are added.

With one predictor the answer is easy: a flat prior on the correlation. With
more, draw correlation matrices with every valid matrix equally likely and
watch what the number of predictors $k$ does. One quantity stays flat by
itself, the **partial correlation** of the outcome with each predictor; the
marginal correlation narrows, and the explained variance $R^2$ grows
([`docs/1_why_a_choice.md`](https://github.com/dm-k1/flatcor-paper/blob/main/docs/1_why_a_choice.md)):

![What adding predictors does to random correlation matrices](https://raw.githubusercontent.com/dm-k1/flatcor-paper/main/docs/figures/motivation_what_k_does.png)

That leaves four candidate default priors. Three form one family with
$R^2 \sim$ Beta($a$, 1), each flat on one quantity for every $k$: **joint flat
partial r** (what random matrices give; $a = k/2$), **flat R** and **flat R-squared**
(the total held fixed, so each partial correlation narrows as $k$ grows). The
fourth is **independent flat partial r**.

## Three repositories

| Folder | Repository | What it holds |
|---|---|---|
| `flatcor/` | [**flatcor**](https://github.com/dm-k1/flatcor) | the R package |
| `flatcor-simulation-studies/` | [**flatcor-simulation-studies**](https://github.com/dm-k1/flatcor-simulation-studies) | the validation: six studies of whether each prior works correctly within the Bayesian framework |
| `flatcor-paper/` | [**flatcor-paper**](https://github.com/dm-k1/flatcor-paper) | the argument and the paper: the introduction, the four priors and their derivations, the relation to other priors, the reading list, the motivating simulation |

`flatcor` (package) -> `flatcor-simulation-studies` (runs the studies with the
package) -> `flatcor-paper` (the paper; cites the studies).

## Open questions

- **The empirical question between the priors:** how explained variance grows
  with the number of predictors in published regressions. Joint flat partial r
  predicts a median $R^2$ of .76 with 5 predictors; flat R predicts .25 and
  flat R-squared .50 at any size.
- **How the priors behave in use**, a later study: how often the test of a
  term finds an effect, confirms a null or stays undecided as $k$ and $n$
  change, and how well the estimates do.
- **Benchmarks in variable selection** against the robust, hyper-g/n and
  intrinsic priors (BAS package), and a reanalysis of real data.

## Workspace

This repository is a workspace: each part lives in its own repository and is
included as a git submodule, pinned to a specific commit. It holds this
overview and the pins, nothing else.

Clone with the submodules:

```bash
git clone --recurse-submodules https://github.com/dm-k1/Objective-bayes
```

Already cloned without submodules:

```bash
git submodule update --init --recursive
```

Move the pins to the latest commit of each tracked branch (all `main`), then
commit the new pins:

```bash
git submodule update --remote
```

## Author

D.M. Kloppenburg, University of Amsterdam.
