---
title: "Hello World"
date: 2026-08-20
draft: false
tags: ["hugo", "meta"]
summary: "Why this site exists and how it is built."
---

This site is a place to write down things I work out at the keyboard. Most of
it will be about software.

## How it is built

The site is Hugo with the PaperMod theme. The theme is a Hugo Module rather
than a git submodule. That matters because the deployment clones this repo and
builds it, and a plain clone does not fetch submodule contents. A module is
recorded in `go.mod` and `go.sum` and is fetched during the build like any
other dependency, so there is no second step to forget.

Deployment is Dokploy. It watches the repo, builds the `Dockerfile` on push,
and serves the result. The build has two stages. The first runs `hugo` and
produces static files. The second copies those files into an nginx image. The
Go toolchain and Hugo itself stay in the first stage, so the image that
actually runs holds nothing but nginx and the generated site.

## What is next

Posts, mostly. The interesting part of a blog is the writing, and the setup is
only worth this much attention once.
