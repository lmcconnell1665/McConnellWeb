---
title: "Fivetran + dbt Labs Merged: What It Actually Means for Your Data Team"
date: 2026-06-17T12:00:00Z
author:
authorLink:
description: "Fivetran and dbt Labs completed their merger in June 2026. Here's what changes, what doesn't, and what data teams using both tools should be paying attention to."
tags:
- dbt
- Fivetran
- Data Engineering
- Modern Data Stack
- ELT
categories:
- Commentary
draft: false
---

***
#### Fivetran and dbt Labs completed their merger on June 1, 2026. If you're a data team running ELT pipelines with Fivetran and transforming data with dbt, here's what you actually need to know.

***

## What Happened

The merger between Fivetran and dbt Labs was first announced in October 2025 and finalized on June 1, 2026 in an all-stock transaction. George Fraser continues as CEO and Tristan Handy (dbt Labs founder) moves into the President role. The combined company now serves over 100,000 data teams and reports $600M in combined revenue.

This wasn't the only move. Fivetran also acquired **Census** in May 2025 (reverse ETL / data activation) and **Tobiko Data** (the team behind SQLMesh). The result: ingestion, transformation, and activation are now under one roof for the first time. If you've been stitching together Fivetran → dbt → Census to build a full ELT-to-activation pipeline, you're now technically a customer of a single vendor for all three layers.

***

## What Changes Tomorrow: Basically Nothing

The official message from both companies is "non-disruptive," and for now that appears to be accurate. dbt is still dbt. Fivetran is still Fivetran. Existing contracts, connectors, and workflows are unchanged.

If you're running dbt Core in self-hosted infrastructure, your day-to-day is unaffected. If you're on dbt Cloud, you're not being migrated or forced onto a new pricing model. The same goes for Fivetran customers — your connectors still work, your schedules still run, nothing broke.

***

## What Actually Changes: dbt Core v2.0 and the Fusion Engine

The most immediately relevant thing for dbt users is the simultaneous release of **dbt Core v2.0**, which open-sources the Fusion engine runtime under an Apache 2.0 license.

Fusion is Rust-based and brings some meaningful improvements:

- **Up to 10x faster parse times** for large dbt projects
- Better scalability as model counts grow
- A cleaner adapter contribution model
- An improved docs experience

For teams running large dbt projects (hundreds or thousands of models), slow parse times have been a genuine quality-of-life problem. A 10x improvement there is worth paying attention to, especially if you've been defaulting to dbt Cloud primarily because the CLI felt sluggish.

The other notable feature is **dbt State** — a caching layer that only rebuilds what's changed in a pipeline run. The company claims this can reduce underlying compute costs by 30% or more for appropriate workloads. This isn't a new concept, but having it built natively into the runtime and integrated with scheduling is a meaningful step toward smarter incremental processing.

***

## The Bigger Picture: The Modern Data Stack Is Consolidating

For the last several years, "the modern data stack" meant assembling a collection of best-in-class point solutions. Fivetran for ingestion. dbt for transformation. Census for activation. A separate orchestrator. A separate catalog. Each with its own pricing, support contract, and integration surface.

The Fivetran + dbt + Census combination closes the most common ELT loop. The pitch is straightforward: integrated pipeline monitoring, transformation-aware scheduling (Fivetran can understand what's downstream in dbt), and unified billing. If you're managing separate renewals and separate support relationships for all three today, consolidation has real operational appeal.

The framing from both companies leans heavily on **AI agents** — the idea that reliable, trustworthy data infrastructure becomes the foundation that AI agents query and act on. That's a reasonable long-term thesis, but for most teams it's not the thing driving your next sprint. The near-term value is simpler: fewer vendors, tighter integration, and a faster open-source runtime.

***

## What to Watch

A few things worth monitoring as this plays out:

**Open source commitments.** Both dbt Core and Fusion are promised to remain open source under their current licenses. The companies have been explicit about this, but product roadmap priorities will inevitably tilt toward the commercial offering over time. Keep an eye on where Cloud-only features land versus Core.

**Vendor lock-in.** The tighter Fivetran and dbt integrate at the platform level, the more friction there is to swap out either piece. That's not necessarily bad, but it's worth understanding before you standardize your entire pipeline on the combined stack.

**Pricing simplification.** Census pricing already migrated to Fivetran's consumption-based model (monthly active rows). It's reasonable to expect dbt Cloud pricing to eventually align as well. If you're on legacy plans, watch your renewal conversations carefully.

***

For most data teams, June 2026 looks a lot like May 2026. But dbt Core v2.0 is worth upgrading to, and the consolidation story is one to understand before your next vendor review.

***

*Have thoughts on the merger or how your team is thinking about the combined stack? I'd like to hear it — reach out on [LinkedIn](https://www.linkedin.com/in/luke-mcconnell/).*
