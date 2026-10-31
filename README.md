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

## Structure

- `content/posts/` – posts as page bundles (`index.md` + images)
- `layouts/` – templates; `layouts/partials/` shared pieces
- `assets/css/main.css`, `assets/js/main.js` – design and behavior
- `hugo.toml` – site config, menus, author, featured topics
