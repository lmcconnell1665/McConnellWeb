---
title: "Manifest vs. State: How to Make Your dbt CI/CD Actually Smart"
date: 2026-06-05T00:00:00Z
author:
authorLink:
description: "Stop rebuilding your entire dbt project on every pull request. Here's how dbt's manifest and state comparison work, and how to wire them into GitHub Actions for fast, cheap Slim CI."
tags:
- dbt
- CI/CD
- GitHub Actions
- Data Engineering
- DevOps
categories:
- Tutorial
draft: false
---

***
#### Stop rebuilding your entire dbt project on every pull request. This guide breaks down what dbt's manifest and state comparison actually are, the difference between them, and how to wire them into GitHub Actions for CI that builds only what changed.

***

If your dbt CI pipeline rebuilds every model in your project every time someone opens a pull request, you are paying for it twice: once in warehouse credits, and again in the minutes your team spends waiting for a green check on a one-line change.

There is a better way, and it has been built into dbt for years. It rests on two concepts that get used interchangeably but mean very different things: the **manifest** and **state**. Understanding the difference is the whole game. Once it clicks, the GitHub Actions setup that makes your CI "smart" is surprisingly short.

This post walks through what the manifest actually is, what state comparison does with it, and how to put the two together in GitHub Actions so CI builds only what changed. We will also cover the gotchas that bite teams in production, and what changes with dbt Core v2.0, which landed in June 2026.

## The problem: CI that rebuilds the world

A typical naive dbt CI job runs something like `dbt build` against a CI schema on every pull request. That command parses your project, then runs and tests every model, seed, and snapshot in it.

That is correct, but it is wasteful. If your PR touches one staging model, you do not need to rebuild the three hundred models that have nothing to do with it. You only need to build the model you changed, anything downstream of it, and you need the unchanged upstream models to exist somewhere so your changed model has something to select from.

dbt can do exactly this. The pattern is called **Slim CI**, and it is powered by comparing your branch against a snapshot of production. That snapshot is the manifest.

## Manifest vs. state: clearing up the confusion

The single most common misconception is that "manifest" and "state" are two competing features. They are not. Here is the relationship in one sentence:

**The manifest is the artifact. State is the act of comparing your current project against a previous manifest.**

### What the manifest is

Every time dbt parses your project — which happens at the start of nearly every command — it produces a file called `manifest.json` in the `target/` directory. This file is a complete, structured snapshot of your project: every model, test, macro, source, seed, snapshot, exposure, and metric, along with their configuration and, crucially, the full dependency graph.

If you crack open a `manifest.json`, the top-level keys tell the story:

- `nodes` — your models, tests, seeds, and snapshots, with their compiled SQL, configs, and checksums
- `sources`, `macros`, `metrics`, `exposures` — the rest of your project's resources
- `parent_map` and `child_map` — the DAG, expressed as adjacency lists
- `metadata` — the dbt version, the generation timestamp, and the project name

Every resource appears in the manifest even if you only ran a subset of your project. It is a full repository of project state, not a record of what just executed. dbt itself uses it to render the docs site and to power state comparison, and the community uses it for everything from project health checks to lineage tooling.

### What state is

"State" is what happens when you hand dbt a *previous* manifest and ask it to diff. You do this with the `--state` flag, which points at a directory containing artifacts from an earlier run — typically your production run:

```bash
dbt build --select state:modified+ --state path/to/prod/artifacts
```

With that prior manifest in hand, dbt can compare your current branch's parsed project against it node by node. The `state:modified` selector resolves to every node that is new or has changed relative to the baseline. The trailing `+` extends the selection to everything downstream, because if you change a model, you want to test its dependents too.

So the manifest is the *noun* — the snapshot. State comparison is the *verb* — diffing two snapshots. You cannot do state comparison without a manifest, and a manifest on its own does nothing to speed up CI. They are two halves of one mechanism.

### One rule you must not break

Never compare a project against its own `target/manifest.json`. dbt overwrites that file on every parse, so by the time your command runs, the "previous" manifest has already been replaced by the current one. The diff comes back empty or wrong. The baseline manifest has to live in a *separate* directory that you populated from a prior run — which is exactly what the GitHub Actions setup below arranges.

## The three flags that make Slim CI work

Slim CI is really three flags working together. It is worth understanding each on its own before combining them.

**`--state <dir>`** tells dbt where the baseline manifest lives. This is the production manifest you saved from your last successful prod run. Everything else keys off this comparison.

**`state:modified+`** is the selector. `state:modified` picks new and changed nodes; the `+` pulls in their downstream descendants. This is what shrinks a three-hundred-model build down to the handful your PR actually affects.

**`--defer`** handles the upstream problem. Your changed model still selects `from` its unchanged parents — but in Slim CI you did not build those parents in the CI schema. Defer tells dbt: when a `ref()` points at a node you are not building, resolve it to the version in the baseline environment (production) instead of expecting it in your CI schema. This is what lets you build a subset without first rebuilding its entire upstream lineage.

Put together, the canonical Slim CI command is:

```bash
dbt build --select state:modified+ --defer --state path/to/prod/artifacts
```

Read it out loud: "Build the things I changed and everything downstream of them, borrow any unchanged parents from production, and figure out what changed by diffing against the manifest in this directory."

### Bonus: smarter reruns and source-driven builds

Two related selectors are worth a mention because they extend the same idea. The `result:` family lets you act on the *outcome* of a previous run — for example, rerun only what errored last time:

```bash
dbt build --select state:modified+ result:error+ --defer --state path/to/prod/artifacts
```

And `source_status:fresher+` builds only the models downstream of sources that actually received new data, by comparing `sources.json` artifacts across runs. Both rely on the same artifact-comparison machinery as `state:modified`.

## Wiring it into GitHub Actions

Here is the part that trips people up. dbt Core has no memory between runs. It does not know what production looked like yesterday unless you saved that information somewhere it can reach. So the entire job is: **after every production run, save the manifest; before every CI run, fetch it.**

The flow looks like this:

{{< mermaid >}}
flowchart LR
    subgraph prod["Production run (on merge to main)"]
        A[dbt build] --> B[target/manifest.json]
        B --> C[(Upload artifact<br/>or S3/GCS)]
    end
    subgraph ci["CI run (on PR)"]
        D[Download prod<br/>manifest -> ./prod-artifacts] --> E{manifest<br/>exists?}
        E -- yes --> F["dbt build --select state:modified+<br/>--defer --state ./prod-artifacts"]
        E -- no --> G[dbt build<br/>full fallback]
    end
    C -.serves baseline.-> D
{{< /mermaid >}}

You have two reasonable places to stash the manifest: GitHub Actions artifacts, or cloud object storage like S3, GCS, or Azure Blob. Artifacts are simpler and require no extra credentials; object storage is the better fit if production runs somewhere other than GitHub Actions, or if you want the manifest available to other tooling. The examples below use Actions artifacts, with the S3 variant noted at the end.

### Workflow 1: production publishes the baseline

This runs on every merge to `main`. It does a normal production build, then uploads `manifest.json` as an artifact so CI runs can find it later.

```yaml
name: dbt-prod
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      DBT_PROFILES_DIR: ./
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dbt
        run: pip install dbt-snowflake   # swap for your adapter

      - name: dbt deps
        run: dbt deps

      - name: dbt build (production)
        run: dbt build --target prod

      # Publish manifest.json so CI runs can diff against it
      - name: Upload prod manifest
        uses: actions/upload-artifact@v4
        with:
          name: prod-manifest
          path: target/manifest.json
          retention-days: 90
```

### Workflow 2: CI runs Slim CI against that baseline

This runs on pull requests. It downloads the most recent production manifest, then either runs Slim CI (if a baseline exists) or falls back to a full build (if one does not).

```yaml
name: dbt-ci
on:
  pull_request:
    branches: [main]

jobs:
  slim-ci:
    runs-on: ubuntu-latest
    env:
      DBT_PROFILES_DIR: ./
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dbt
        run: pip install dbt-snowflake

      - name: dbt deps
        run: dbt deps

      # Pull the latest prod manifest from the prod workflow (cross-workflow)
      - name: Download prod manifest
        uses: dawidd6/action-download-artifact@v6
        continue-on-error: true        # first ever run: no baseline yet
        with:
          workflow: dbt-prod.yml
          name: prod-manifest
          path: ./prod-artifacts
          workflow_conclusion: success
          if_no_artifact_found: warn

      - name: dbt build (Slim CI with fallback)
        run: |
          if [ -f ./prod-artifacts/manifest.json ]; then
            echo "Baseline found -> Slim CI"
            dbt build --select state:modified+ \
                      --defer --state ./prod-artifacts \
                      --target ci
          else
            echo "No baseline -> full build"
            dbt build --target ci
          fi
```

A few things worth highlighting in this second workflow:

The download step uses `dawidd6/action-download-artifact`, a community action, because the standard `actions/download-artifact` can only pull artifacts from *the same workflow run*. We need a cross-workflow fetch: the artifact was produced by `dbt-prod`, and we are consuming it in `dbt-ci`.

The `if [ -f ... ]` fallback is the unsung hero of this setup. On a brand-new repo, or before your first production run has ever completed, there is no baseline manifest to compare against. Rather than failing, CI quietly does a full build. Once production has run at least once, Slim CI takes over automatically. This makes the whole thing safe to merge without a chicken-and-egg dance.

### The S3 alternative

If production runs outside GitHub Actions, or you simply prefer object storage, swap the upload and download steps for plain copies:

```bash
# In the prod job, after a successful build:
aws s3 cp target/manifest.json s3://my-bucket/dbt/manifest.json

# In the CI job, before the build:
aws s3 cp s3://my-bucket/dbt/manifest.json ./prod-artifacts/manifest.json
```

Everything else stays the same. The `--state ./prod-artifacts` flag does not care how the manifest got there.

## Gotchas that bite teams in production

Slim CI is reliable once it is set up correctly, but a few sharp edges have cost teams real debugging time. Knowing them in advance is most of the battle.

### False positives from environment-aware configs

The most notorious issue: if your models set configuration dynamically based on the target — for example, choosing a different `database` or `schema` in prod versus dev — older versions of dbt compared the *rendered* values. Since those values legitimately differ between your prod baseline and your CI run, dbt concluded that every model had "changed" and rebuilt the entire project on every PR. Slim CI quietly stopped being slim.

dbt 1.9 fixed this with a behavior flag that compares the *unrendered* config instead. Turn it on in `dbt_project.yml`:

```yaml
flags:
  state_modified_compare_more_unrendered_values: true
```

The catch: your baseline state directory must *also* have been built with dbt 1.9 or later and with this flag enabled. If your production manifest was generated by an older version, you will still get false positives until you rebuild the baseline. When you upgrade, regenerate the prod manifest before trusting the comparison.

### vars and env_vars are hard to trace

If a model's behavior depends on a `var` or `env_var`, dbt cannot always reason cleanly about whether a change to that variable should mark the model as modified. In practice, if the variable change alters the model's rendered configuration, the model usually gets flagged; if it does not, it may not. Do not assume `state:modified` will perfectly track variable-driven logic.

### No sub-selectors (yet)

It would be handy to select only models whose *SQL body* changed, separately from those whose *config* changed — something like `state:modified.body`. As of mid-2026 these sub-selectors do not exist; there is an open feature request, but `state:modified` remains all-or-nothing per node. If any tracked attribute of a node changes, the whole node is selected.

### Incremental models in CI

Incremental models are awkward in CI because the CI schema usually does not contain the existing table to append to, so dbt falls back to a full refresh — which can be slow and expensive. dbt's own recommended pattern is to `clone` your incremental models from production as the first step of the CI job, so they build incrementally against a real existing table rather than rebuilding from scratch.

## What changes with dbt Core v2.0 (June 2026)

If you are reading this in mid-2026 or later, there is a larger shift underway worth factoring into your plans.

On June 1, 2026, dbt Labs shipped the first alpha of **dbt Core v2.0**. The headline is that dbt Core is now built on the same Rust-based runtime as the dbt Fusion engine, with much of Fusion's code open-sourced for the first time. Practically, that means open-source users get the high-performance foundation directly, rather than waiting for features to be ported from Rust back to Python. dbt Core and Fusion now share a runtime.

For our topic specifically, two things matter:

First, there is now a higher-level capability simply called **dbt State** that sits above the manual `state:modified+` pattern described here. Rather than you hand-writing selectors, dbt State can automatically skip or clone nodes when both their logic *and* their data are unchanged, instead of rebuilding on every run. It is available in dbt Core v1.12+, v2.0, the dbt platform, and the Fusion engine, and it works consistently across all of them. The manual pattern in this post still works and is still the right mental model — but expect more of this to become automatic.

Second, defer got smarter: deferral now resolves user-defined function (UDF) calls from the state manifest, so you can run models that depend on UDFs without first building those UDFs in your current target. This is the same "borrow it from production" idea this post is built on, extended to functions.

The takeaway: the manifest-and-state mechanism is not going away. It is becoming faster and more automatic. Understanding it the way this post lays it out will serve you whether you are on dbt Core 1.x today or moving to v2.0.

## Wrapping up

The mental model is the whole thing. The **manifest** is a complete snapshot of your project that dbt writes on every parse. **State** is the act of diffing your current branch against a previous manifest. Slim CI combines a saved production manifest (`--state`), a selector that picks only what changed and its descendants (`state:modified+`), and deferral that borrows unchanged parents from production (`--defer`).

In GitHub Actions, the only real work is plumbing: save the manifest after production runs, fetch it before CI runs, and fall back to a full build when no baseline exists yet. A dozen lines of YAML turns a CI job that rebuilds three hundred models into one that builds three.

Set the `state_modified_compare_more_unrendered_values` flag, watch out for incremental models, regenerate your baseline when you upgrade dbt, and your CI will stay genuinely slim instead of slim in name only.
