# bilus.dev

Hugo blog served at https://blog.bilus.dev/. Posts are Markdown under
`content/posts/`, the theme is PaperMod pulled in as a Hugo Module, and what
gets deployed is an nginx image built from the `Dockerfile` at the repo root.

## Working locally

Hugo is not on the PATH. It comes from devbox:

    devbox run serve    # hugo server --buildDrafts, serves on :1313
    devbox run build    # hugo --minify --gc into public/
    devbox run -- hugo <anything else>

devbox pins Hugo 0.164.0 but the Docker build uses 0.165.0. If something
renders differently in production than it did locally, check that first.

## Publishing a post

    devbox run -- hugo new content/posts/my-title.md

The archetype sets `draft = true`, and drafts are excluded from the build:
`buildDrafts = false` in hugo.toml, and the Dockerfile does not pass
`--buildDrafts`. Setting that flag to false is what actually publishes the
post, and it is the step that gets forgotten.

The archetype writes TOML front matter (`+++`) while the existing post uses
YAML (`---`). Hugo reads either, just do not mix them within one file.

`mainSections` is `["posts"]`, so only `content/posts/` reaches the home page
listing. A file elsewhere still builds but nothing links to it.

Preview with `devbox run serve`, which includes drafts. Then commit and push to
master. There is no separate publish or deploy step.

## Hosting

Dokploy runs the site as an application named `blog.bilus.dev` in the Tools
project, production environment (applicationId `nGMnauxkQuDpoViw2j5Jb`). It is
connected to this repo through the `Dokploy-bilus` GitHub App and rebuilds on
every push to master, merges included. Push to live takes a little over a
minute.

The build is the root `Dockerfile`: `hugo mod get` then `hugo --minify --gc` in
a `hugomods/hugo:go-git` stage, with the generated `public/` copied into
`nginx:alpine` alongside `nginx.conf`. Only the nginx stage ships. The build
commits nothing back to the repo, and `public/` is gitignored.

Cloudflare sits in front and terminates TLS, so Traefik and the container only
ever speak plain HTTP on port 80. The Dokploy domain entry is deliberately
`https: false` with no certificate. Do not enable Let's Encrypt on this host.

The `gh-pages` branch is left over from when the site was on GitHub Pages. It
is not used and nothing publishes to it.

If a push does not show up on the site, check the app's deployment list in
Dokploy. Build logs live on the server under `/etc/dokploy/logs/`, in a
directory named after the app's internal name,
`app-connect-redundant-program-rerfjk`.
