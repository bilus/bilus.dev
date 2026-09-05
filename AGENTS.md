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

Preview with `devbox run serve`, which includes drafts. Generate and upload the
narration before flipping the draft flag, see Audio narration below. Then commit
and push to master. There is no separate publish or deploy step.

## Audio narration

Every post gets a spoken version, and it is generated before the post goes
live. Treat a post without narration as unfinished. The work is three steps:
generate the mp3 with ElevenLabs, upload it to R2, then point the post's front
matter at the uploaded file.

Generation goes through the ElevenLabs creative MCP server
(`creative_generate_speech`).

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
directory is gitignored, because the files are generated output and the
published copy lives in R2.

A generation returns a flow id and a session id. Poll
`creative_get_flow_run_status` with them until `all_completed` is true. The
status carries a signed download URL under `media[].url`, valid for two hours.
Fetch it with curl into `audio/`.

Pricing is about one credit per character, so a 3,500 character post costs
roughly 3,500 credits (about 60 US cents in September 2026). Pass
`estimate_only` first for anything long.

### Serving the mp3 files from R2

The audio is served from the `blog-assets` R2 bucket in the Cloudflare account
`5da0889dd7cfa1b994f2d87263bc810c`, through the custom domain
`blog-assets.bilus.dev`. Object keys mirror the local paths, so
`audio/porting-liveview-to-go.mp3` becomes
`https://blog-assets.bilus.dev/audio/porting-liveview-to-go.mp3`.

Use the custom domain, not the bucket's `r2.dev` URL. Cloudflare rate-limits
`r2.dev` and does not support it for production traffic.

`blog-assets.bilus.dev` resolves through its own proxied CNAME to
`public.r2.dev`. Attaching the custom domain to the bucket creates that record.
The zone also carries a wildcard `*.bilus.dev` CNAME pointing at the Dokploy
tunnel, and an explicit record for a subdomain takes precedence over the
wildcard. `api-browser-assets.bilus.dev` is the same arrangement for another
bucket. The zone's CAA record restricts certificate issuance to Let's Encrypt
and does not block the certificate for these hostnames.

Upload a narration with wrangler, which is not installed but runs through npx:

    npx wrangler r2 object put \
      blog-assets/audio/<post-slug>.mp3 \
      --file audio/<post-slug>.mp3 \
      --content-type audio/mpeg \
      --cache-control "public, max-age=31536000, immutable" \
      --remote

Pass `--remote`. Wrangler's R2 commands also target a local simulated bucket,
and that flag is what sends the write to the real one.

Wrangler needs credentials. `npx wrangler login` opens a browser and stores an
OAuth token, which covers everything here. For a non-interactive run, set
`CLOUDFLARE_API_TOKEN` to an account token carrying "Workers R2 Storage: Edit".
`npx wrangler whoami` prints no R2 entry in its scope list even when the token
has R2 access, so test with `npx wrangler r2 bucket list` rather than trusting
that list. The Cloudflare MCP server's OAuth grant reads R2 but cannot write it,
so bucket and object changes go through wrangler.

Adding a custom domain is not instant. `npx wrangler r2 bucket domain list
blog-assets` reports `ownership_status` and `ssl_status` as `pending` for the
first minute or two, and requests during that window return HTTP 403 with the
body `error code: 1014`. The domain was set up with a minimum TLS version of
1.2. Wait and retry before treating a 403 as a misconfiguration.

The long `Cache-Control` is safe for a new post, because each post writes a
distinct key. Regenerating a narration overwrites an already cached key, so
after replacing an mp3, purge the Cloudflare cache for that URL. Otherwise
Cloudflare serves the old file until the TTL expires.

### Wiring a post to its audio

Front matter carries the full URL:

    audio: ["https://blog-assets.bilus.dev/audio/porting-liveview-to-go.mp3"]

`layouts/_partials/post_meta.html` reads that parameter and renders two things
into the meta line under the title, on the article page only: a play control
that streams the file in place, and an "mp3" link straight to it. The play
control calls `preventDefault`, so its own href never opens, which is why the
separate link exists. That link carries a `download` attribute, but browsers
apply it only to same-origin files, and the audio sits on another host, so a
click opens the mp3 rather than saving it.

PaperMod's opengraph partial reads the same parameter and emits `og:audio`,
which is why the value is an absolute URL inside a list rather than a bare path.
A post with no `audio` parameter renders neither control, so the feature is
opt-in per post. PaperMod styles `.post-meta a` already, so neither needs its
own colour.

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
