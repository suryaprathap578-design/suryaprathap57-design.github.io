# SUBHA INFRA — Website

Static corporate website for **SUBHA INFRA** (www.subhainfra.com) — architecture, structural engineering, steel & PEB, facades and design & build.

Every public URL is clean (no `.html`): `/about/`, `/services/peb-structures/`, `/projects/angular-white-villa/`.
Each page is a folder containing an `index.html`, so clean URLs work on any static host with no special routing.

---

## Folder structure

```text
/
├── index.html                     Home  →  /
├── about/  careers/  contact/  faq/  packages/  process/  quality/
│   team/  privacy/  terms/  sitemap/          one index.html each  →  /about/ …
├── services/
│   ├── index.html                 →  /services/
│   └── architectural-design/ structural-engineering/ interior-design/
│       design-and-build/ facade-engineering/ steel-structures/
│       peb-structures/ tensile-structures/      →  /services/<name>/
├── projects/
│   ├── index.html                 →  /projects/  (portfolio + filters)
│   └── <project-slug>/index.html  →  /projects/<project-slug>/   (41 projects)
├── 404/index.html                 Not-found page (404.html is a copy for Netlify/Vercel/Cloudflare)
│
├── assets/
│   ├── images/          brand logos (brand/), team photos (team/), other site images
│   ├── project-images/  watermarked portfolio photos  subha-infra-<category>-NN.jpg
│   ├── service-images/  interiors/ (interior-01…09.jpg) and journey/ (journey-01…08.jpg)
│   ├── favicon/         favicon.png (+ older favicon.svg)
│   ├── icons/           (icons are inline SVG — folder reserved)
│   └── fonts/           (fonts load from Google Fonts — folder reserved)
├── css/style.css
├── js/
│   ├── site-config.js   ← edit contact details, social links, team, package rates
│   └── main.js
│
├── .htaccess            Apache / cPanel / LiteSpeed routing + legacy redirects
├── _redirects           Netlify / Cloudflare Pages legacy redirects
├── vercel.json          Vercel clean URLs + legacy redirects
├── robots.txt
├── sitemap.xml
└── _build/              Source files and build tools (blocked from public access)
    ├── pages/           page content, one file per page
    ├── partials/        head, header, footer, design-journey section
    ├── templates/       project detail template
    ├── build.ps1        generates every page, sitemap.xml and routing files
    ├── serve.ps1        local preview server with clean URLs
    ├── process-images.ps1 / process-logo.ps1   image & logo tools
```

## Everyday edits — no rebuild needed

| What | Where |
|---|---|
| Phone, WhatsApp, email, address, map | `js/site-config.js` |
| LinkedIn / Instagram / Facebook / YouTube / X links | `js/site-config.js` → `social` (empty = hidden) |
| Team members & group photo | `js/site-config.js` → `team`, `groupPhoto` (photos in `assets/images/team/`) |
| Package rates & estimator rates, GST | `js/site-config.js` → `rates`, `gstPercent` |
| Online form submission | `js/site-config.js` → `formEndpoint` |
| Replace a photo | overwrite the file in `assets/…` keeping the same name |

## Images — Image CMS (no rebuild)

Every managed image has a permanent **placement key** (`<img data-slot="HOME-HERO-1">`) and every photo a permanent **image ID** (`PEB-001`).
Images are chosen in the admin panel (Google Apps Script + Sheets + Drive, free) and published; `js/cms.js` loads them on every page.

- Setup, deployment, schema and API: [`_build/cms/README.md`](_build/cms/README.md)
- Where every image is: [`_build/cms/IMAGE-MAP.md`](_build/cms/IMAGE-MAP.md), or add `?cms_labels=1` to any page URL
- Connect the site: `js/site-config.js` → `cmsApi`

## Content edits — rebuild

1. Edit the page in `_build/pages/` (or a shared part in `_build/partials/`; project titles and descriptions are in `_build/build.ps1`).
2. Rebuild:
   ```powershell
   powershell -ExecutionPolicy Bypass -File _build\build.ps1
   ```
   This regenerates all page folders, `sitemap.xml`, `robots.txt`, `.htaccess`, `_redirects` and `vercel.json`.

Use root-relative paths in sources (`/contact/`, `/assets/project-images/…`). Never link to `.html` files.

## Preview locally

Clean URLs need a web server (double-clicking `index.html` will not follow folder links).

```powershell
powershell -ExecutionPolicy Bypass -File _build\serve.ps1
```

Then open http://localhost:8080/. The preview server mirrors the live behaviour: folder URLs, trailing-slash redirects, old `.html` redirects and the 404 page.

## Deploying

Upload the **site root** (everything except `_build/`, which is optional and blocked if uploaded). The site must be served from the domain root (`https://www.subhainfra.com/`) because links are root-relative.

- **cPanel / Apache / LiteSpeed (most Indian shared hosting):** upload to `public_html/`. `.htaccess` handles index files, `/about` → `/about/`, old `.html` → clean URLs, `/folder/index.html` → `/folder/`, and the 404 page.
- **Netlify / Cloudflare Pages:** deploy the folder; `_redirects` and `404.html` are picked up automatically.
- **Vercel:** deploy the folder; `vercel.json` enables clean URLs and redirects.
- **Nginx:** add to the server block:
  ```nginx
  index index.html;
  try_files $uri $uri/ =404;
  error_page 404 /404/index.html;
  location ^~ /_build/ { return 404; }
  rewrite ^/(.+)/index\.html$ /$1/ permanent;
  rewrite ^/service-(.+)\.html$ /services/$1/ permanent;
  rewrite ^/project-(.+)\.html$ /projects/$1/ permanent;
  rewrite ^/index\.html$ / permanent;
  rewrite ^/([a-z0-9-]+)\.html$ /$1/ permanent;
  ```

Canonical tags on every page point to the clean `https://www.subhainfra.com/...` URL, so old `.html` addresses are never indexed as duplicates.
