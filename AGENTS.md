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

## Audio narration

Posts get a spoken version generated with ElevenLabs text to speech, through
the ElevenLabs creative MCP server (`creative_generate_speech`).

Default voice: Liam, voice id `TX3LPaxmHKxFdv7VOQHJ` ("Liam - Energetic,
Social Media Creator", an ElevenLabs premade voice). Model: `eleven_v3`, no
inline audio tags. Chosen on 2026-09-05 from samples by Liam, Charlie and Zane.
Use it for every post unless asked otherwise.

The narration text is the post body with the front matter removed, links
reduced to their text, and HTML lists read as numbered items ("One: ...",
"Two: ..."). Read the title first. Where the spelling misleads the model,
write the sound instead: "templ" becomes "temple", initialisms get hyphens
("A-S-T", "I-O Writer"). Keep the author's wording otherwise.

Files go to `audio/<post-slug>.mp3`, named after the Markdown file. The
directory is gitignored because the files are generated output.

A generation returns a flow id and a session id. Poll
`creative_get_flow_run_status` with them until `all_completed` is true. The
status carries a signed download URL under `media[].url`, valid for two hours.
Fetch it with curl into `audio/`.

Pricing is about one credit per character, so a 3,500 character post costs
roughly 3,500 credits (about 60 US cents in September 2026). Pass
`estimate_only` first for anything long.

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
