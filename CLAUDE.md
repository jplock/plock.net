# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Hugo site that publishes a **Gemini capsule** (gemini://plock.net), not a web site. Every page is
gemtext, served over the Gemini protocol. There is no HTML output format, CSS, or theme in this
repo — the WWW version of the blog lives elsewhere, and the capsule links out to it.

## Content model

Each page is a single `.md` file in `content/` whose **body is raw gemtext, not Markdown**. The
layouts render it with `.RawContent`, so Hugo never runs it through Goldmark and the text reaches
the output byte-for-byte. Nothing in the repo may call `.Content` on these pages — that would
Markdown-render gemtext and mangle it.

Front matter is `title` and, for posts, `date`. Output formats are declared once in `config.yml`
(`outputs.page: [gemtext]`), so pages do **not** need an `outputs:` line.

### Adding a post

Create `content/posts/NNNNN_slug.md`, where `NNNNN` is the next zero-padded sequence number (posts
run `00001`–`00007` today):

```
---
title: Post title
date: "2026-01-02T00:00:00Z"
---

Body in gemtext, starting straight in on the prose.
```

Do **not** start the body with a `# Title` line — `layouts/posts/single.gmi` emits the title
heading, the "was published on …" line, the back link, and the license footer. Standalone pages
like `content/about.md` render through `layouts/_default/single.gmi`, which adds only the footer,
so those files do carry their own heading.

The numeric prefix orders the files on disk and leaks into the permalink
(`/2020/11/02/00001_first-post.gmi`). Changing that would break published URLs.

### Gemtext conventions

- Links are their own line: `=> gemini://example.com Label text`. Gemtext has no inline links, so
  restructure prose to hang links off it rather than embedding them.
- Preformatted blocks use ``` fences; text after the opening fence is alt text (see the ASCII art
  in `content/_index.md`).
- `#`/`##`/`###` headings, `*` bullets. No bold, italics, or tables.

## Layouts

- `layouts/index.gmi` — home page: `_index.md` body, the post list, then About and feed links.
- `layouts/posts/single.gmi` — posts, with the title heading and dated footer.
- `layouts/_default/single.gmi` — everything else (About).
- `layouts/index.gemrss.xml` — the posts feed, published at `/posts.xml`.

The feed is a home-page output format (`GEMRSS` with `baseName: posts`) rather than a section feed,
because that is what puts it at `/posts.xml`; a section feed lands at `/posts/index.xml`. Since it
renders in home context it filters on `where .Site.RegularPages "Section" "posts"` — without that,
the About page shows up as a feed item. The home page links to it through
`.OutputFormats.Get "GEMRSS"` rather than a hardcoded path.

`config.yml` registers the `text/gemini` media type and the `gemtext` output format. `uglyurls` and
`disablePathToLower` keep `.gmi` paths literal; `disableKinds` switches off section pages (nothing
links to `/posts/`), the sitemap (it would emit `https://` URLs into a Gemini capsule), and
taxonomies.

## Build and deploy

```sh
hugo            # builds into public/
make deploy     # hugo, then rsync public/ to ubuntu@10.0.57.58:/srv/gemini/plock.net/, then clean up
```

A clean build produces exactly ten files: seven posts, `index.gmi`, `about.gmi`, `posts.xml`. Any
extra file means a content source is leaking into the output. The deploy mirrors with
`rsync --delete`, so the server holds exactly the build and nothing else — the trailing slash on
`public/` is what makes rsync copy the contents rather than the directory. There is no local
preview — `hugo
server` speaks HTTP, not Gemini — so proofreading the ASCII art and link alignment means pointing a
Gemini server (Agate) at `public/` and opening it in a client such as Lagrange or Amfora.

`.build.yml` is a SourceHut builds manifest (Alpine + hugo) that tars `public/` and publishes it to
pages.sr.ht with `-Fprotocol=GEMINI`. It expects the repo checked out in a `$site` (`plock.net`)
directory.

`public/` and `resources/` are gitignored and `make deploy` deletes them after uploading.

## Hugo version notes

Nothing pins a Hugo version; the site builds warning-free on 0.165 (verified 2026-08-30). Two
constraints worth knowing before touching config or the feed:

- `outputs:` matches the **map key** under `outputFormats`, not a `name:` field.
- `.Site.Author` and `.Site.LanguageCode` no longer exist; the feed uses `.Site.Language.Locale`
  and carries no author elements.
