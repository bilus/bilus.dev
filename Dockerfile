# syntax=docker/dockerfile:1

# The go-git variant carries the Go toolchain and git, both of which Hugo
# Modules need in order to resolve the PaperMod dependency during the build.
FROM hugomods/hugo:go-git-0.165.0 AS builder

WORKDIR /src

# Resolve modules before copying content so edits to posts reuse this layer
# instead of re-downloading the theme on every push.
COPY go.mod go.sum hugo.toml ./
RUN hugo mod get

COPY . .
RUN hugo --minify --gc

FROM nginx:alpine AS runtime

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /src/public /usr/share/nginx/html

EXPOSE 80
