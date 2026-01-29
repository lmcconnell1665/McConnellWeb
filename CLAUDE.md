# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

McConnellWeb is a static website/blog built with Hugo using the LoveIt theme (installed as a git submodule). The site is hosted on AWS S3 with CloudFront CDN and uses GitHub Actions for continuous deployment.

## Build Commands

```bash
# Local development (serves with drafts enabled)
hugo serve -D

# Build for production
make clean && hugo

# Deploy (handled by CI, but can run manually)
hugo deploy
```

## Development Setup

```bash
# Create Python virtual environment
make setup

# Activate environment
source ~/.McConnellWeb/bin/activate

# Install dependencies
make install
```

For local preview on a different machine/network:
```bash
hugo serve --bind=0.0.0.0 --port=8080 --baseURL=http://<your-ip> --disableFastRender
```

## Project Structure

- `content/posts/` - Blog posts in Markdown with YAML front matter
- `content/` - Other pages (Resume.md, privacy.md, eula.md)
- `layouts/_default/` - Custom Hugo templates (baseof.html)
- `themes/LoveIt/` - Theme submodule (do not edit directly)
- `static/img/` - Images and static assets
- `config.toml` - Hugo configuration (site settings, menus, deployment target)

## Blog Post Front Matter

```yaml
---
title: "Post Title"
date: 2020-06-18T04:06:22Z
author:
description: "SEO description"
tags: [Tag1, Tag2]
categories: [Category]
draft: false
---
```

## CI/CD

- Push to `master` triggers automatic build and deploy to S3
- Hugo version: 0.131.0 (extended)
- Deployment target configured in config.toml under `[[deployment.targets]]`

## Theme

The LoveIt theme is a git submodule. After cloning, run:
```bash
git submodule update --init
```
