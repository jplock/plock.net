# plock.net

Source for **gemini://plock.net**, a [Gemini](https://geminiprotocol.net/) capsule built with
[Hugo](https://gohugo.io/).

This repository produces gemtext only. There is no HTML output format, no CSS, and no theme — every
page is served over the Gemini protocol. The World Wide Web version of the blog lives elsewhere; the
capsule links out to it from the home page.

## Requirements

- [Hugo](https://gohugo.io/) — builds warning-free on 0.165 (verified 2026-08-30). No version is
  pinned.
- `rsync` and SSH access to the capsule host, for `make deploy`.

## Layout

```
config.yml                    media type, output formats, permalinks
content/
  _index.md                   home page body (ASCII art banner)
  about.md                    standalone page
  posts/NNNNN_slug.md         blog posts, ordered by numeric prefix
layouts/
  index.gmi                   home page: body, post list, About and feed links
  index.gemrss.xml            posts feed, published at /posts.xml
  posts/single.gmi            posts: title heading, dated footer, back link
  _default/single.gmi         everything else: footer only
.build.yml                    SourceHut CI manifest, publishes to pages.sr.ht
Makefile                      deploy target
```

## Content model

Each page is a single `.md` file whose **body is raw gemtext, not Markdown**. The layouts render it
with `.RawContent`, so Hugo never runs it through Goldmark and the text reaches the output
byte-for-byte.

Nothing in this repository may call `.Content` on these pages. That would Markdown-render the
gemtext and mangle it.

Front matter is `title` and, for posts, `date`. Output formats are declared once in `config.yml`
(`outputs.page: [gemtext]`), so individual pages do not need an `outputs:` line.

### Adding a post

Create `content/posts/NNNNN_slug.md`, where `NNNNN` is the next zero-padded sequence number — posts
run `00001` through `00007` today:

```
---
title: Post title
date: "2026-01-02T00:00:00Z"
---

Body in gemtext, starting straight in on the prose.
```

Do not open the body with a `# Title` line. `layouts/posts/single.gmi` already emits the title
heading, the "was published on …" line, the back link, and the license footer. Standalone pages such
as `content/about.md` render through `layouts/_default/single.gmi`, which adds only the footer, so
those files do carry their own heading.

The numeric prefix orders the files on disk and leaks into the permalink
(`/2020/11/02/00001_first-post.gmi`). Renaming a file breaks its published URL.

### Gemtext conventions

- Links occupy their own line: `=> gemini://example.com Label text`. Gemtext has no inline links, so
  restructure prose to hang a link off it rather than embedding one mid-sentence.
- Preformatted blocks use ` ``` ` fences. Text following the opening fence is alt text — see the
  ASCII art in `content/_index.md`.
- `#`, `##`, `###` headings and `*` bullets. No bold, italics, or tables.

## Build and deploy

```sh
hugo            # builds into public/
make deploy     # hugo, rsync public/ to the capsule host, then remove public/ and resources/
```

A clean build produces exactly ten files: seven posts, `index.gmi`, `about.gmi`, and `posts.xml`.
Any extra file means a content source is leaking into the output.

The deploy mirrors with `rsync --delete`, so the server ends up holding exactly the build and
nothing else. The trailing slash on `public/` is what makes rsync copy the directory's contents
rather than the directory itself.

`.build.yml` is a SourceHut builds manifest (Alpine plus hugo) that tars `public/` and publishes it
to pages.sr.ht with `-Fprotocol=GEMINI`. It expects the repository checked out in a `plock.net`
directory.

`public/` and `resources/` are gitignored, and `make deploy` removes them after uploading.

## Previewing

There is no local preview — `hugo server` speaks HTTP, not Gemini. To proofread the ASCII art and
link alignment, point a Gemini server such as [Agate](https://github.com/mbrubeck/agate) at
`public/` and open it in a client like [Lagrange](https://gmi.skyjake.fi/lagrange/) or
[Amfora](https://github.com/makew0rld/amfora).

## Configuration notes

`config.yml` registers the `text/gemini` media type and the `gemtext` output format. `uglyurls` and
`disablePathToLower` keep `.gmi` paths literal. `disableKinds` switches off section pages (nothing
links to `/posts/`), the sitemap (it would emit `https://` URLs into a Gemini capsule), and
taxonomies.

The feed is a home-page output format (`GEMRSS`, with `baseName: posts`) rather than a section feed,
because that is what puts it at `/posts.xml` — a section feed would land at `/posts/index.xml`.
Since it renders in home context it filters on `where .Site.RegularPages "Section" "posts"`; without
that filter the About page shows up as a feed item. The home page links to the feed through
`.OutputFormats.Get "GEMRSS"` rather than a hardcoded path.

Two Hugo details worth knowing before touching the config or the feed:

- `outputs:` matches the **map key** under `outputFormats`, not a `name:` field.
- `.Site.Author` and `.Site.LanguageCode` no longer exist. The feed uses `.Site.Language.Locale` and
  carries no author elements.

## License

Content is CC-BY-SA. Code is MIT.
