# Manage The Cloud – next

Hand-written Hugo theme (no external theme, no third-party requests) for https://manage-the.cloud.

## Preview locally

```powershell
hugo server -D --port 1315
```

Open http://localhost:1315/.

## Build

```powershell
hugo --minify
```

## Deploy (GitHub Pages)

Push to `main`. `.github/workflows/hugo.yml` builds and publishes the site. `static/CNAME` keeps the custom domain.
Post URLs keep the old WordPress format (`/:year/:month/:day/:slug/`).

## Write a new post

```powershell
hugo new content posts/my-post-slug
```

This creates `content/posts/my-post-slug/index.md` from `archetypes/posts/index.md`. Then:

1. Fill in the title, `categories`, `tags` and a one-line `description` (used for search results and share cards).
2. Drop screenshots into the same folder and add a `feature.png` for the card and share image.
3. Write in Markdown. Reading time, table of contents, copy buttons, the home page, topics, counts, search, sitemap and RSS update by themselves.
4. Preview with `hugo server -D`, then set `draft: false`, commit and push to `main`. The site publishes in about a minute.

Nothing else needs editing. The only hand-maintained lists are `featuredTopics` in `hugo.toml` (home page topic tiles) and the About page content.

## Structure

- `content/posts/` – posts as page bundles (`index.md` + images)
- `layouts/` – templates; `layouts/partials/` shared pieces
- `assets/css/main.css`, `assets/js/main.js` – design and behavior
- `hugo.toml` – site config, menus, author, featured topics
