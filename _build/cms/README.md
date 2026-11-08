# SUBHA INFRA — Image Library & Website CMS

A free, Google-hosted CMS that controls **every managed image on www.subhainfra.com**.

```
 Admin (browser)  ──►  Apps Script web app  ──►  Google Sheet  (database: 11 tables)
                              │                  Google Drive  (image files, one folder per category)
                              ▼
            ?api=site  (published image list, JSON, cached)
                              ▲
 Visitor's browser ── /js/cms.js on every page swaps in the published images
                     (the images built into the HTML stay as the fallback)
```

| Piece | Where |
|---|---|
| Apps Script code (paste into script.google.com) | `apps-script/` → `Code.gs`, `Seed.gs`, `Admin.html`, `Styles.html`, `App.html`, `appsscript.json` |
| Website loader | `/js/cms.js` (loaded on every page by `_build/partials/footer.html`) |
| Website switch | `/js/site-config.js` → `cmsApi` |
| Where every image is | `IMAGE-MAP.md` (text) and `image-map.html` (thumbnails — open in a browser) |
| Generator | `generate-cms.ps1` — tags the pages, assigns image IDs, writes `Seed.gs` and the maps |

---

## 1. Two kinds of number

| | Example | What it identifies | Changes? |
|---|---|---|---|
| **Image ID** | `PEB-001` | one photo (one file) | Never. Not reset, not reused after deletion, kept when the file is replaced or the image is moved to another category. |
| **Placement key** | `HOME-HERO-1` | one fixed spot on the website | Never. In the HTML: `<img data-slot="HOME-HERO-1">` |
| **Project number** | `PRJ-001` | one project | Never. |

An image can fill any number of placements without copying the file. Every image row also has a permanent database `uid` (UUID).

The 59 photos already on the site were numbered: `ARCH-001…029` (21 residential + 8 commercial), `FACADE-001…005`, `PEB-001…004`, `STEEL-001…002`, `TENS-001`, `INT-001…009`, `PROC-001…008` (design journey), `TEAM-001`. The 41 portfolio projects are `PRJ-001…041` in website order. The site has **170 placements** on 20 pages and menus. See `IMAGE-MAP.md`.

> **Found during the inventory:** all 9 interior-gallery photos (`INT-001…009`) and all 8 design-journey photos (`PROC-001…008`) are byte-identical copies of exterior project photos. For example, the "Living room interior" image is actually a villa exterior. They are flagged "placeholder copy" in the CMS. Use **Replace** to swap in real photos; their IDs and placements stay the same.

### Finding any image

- **On the live site:** add `?cms_labels=1` to any page URL (for example `https://www.subhainfra.com/services/peb-structures/?cms_labels=1`). Every managed image then shows a badge with its *placement key · image ID*; click a badge to copy it. Use `?cms_labels=0` to turn the badges off.
- **In the admin:** *All Placements* lists every spot page by page, and every card in the *Image Library* lists the placements it fills. The ↗ button on a placement opens the live page scrolled to that spot and outlined.
- **Offline:** `IMAGE-MAP.md` / `image-map.html`.

---

## 2. Set up (about 15 minutes, once)

Use the Google account that should own the images (ideally a company Gmail account such as `subhainfra.web@gmail.com`).

1. Open **https://script.google.com** → **New project**. Rename it `SUBHA INFRA CMS`.
2. **Project Settings** (⚙) → tick **Show "appsscript.json" manifest file in editor**. Back in the Editor, open `appsscript.json` and replace its contents with `apps-script/appsscript.json`.
3. Create the files. The names must match exactly; the editor adds `.gs` / `.html` itself.
   - `Code.gs` → paste `apps-script/Code.gs`
   - **+ → Script** named `Seed` → paste `apps-script/Seed.gs`
   - **+ → HTML** named `Admin` → paste `apps-script/Admin.html`
   - **+ → HTML** named `Styles` → paste `apps-script/Styles.html`
   - **+ → HTML** named `App` → paste `apps-script/App.html`

   *Or with clasp:* `npm i -g @google/clasp`, `clasp login`, then `clasp create --type standalone --title "SUBHA INFRA CMS" --rootDir _build/cms/apps-script` and `clasp push`.
4. Select the function **`setup`** in the toolbar and press **Run**. Approve the permissions. Google shows "unverified app" because it is your own script: choose **Advanced → Go to SUBHA INFRA CMS**.
   The **Execution log** prints the database link, the Drive folder, your login email and a **temporary password**.
5. **Deploy → New deployment →** type **Web app**:
   - Execute as: **Me**
   - Who has access: **Anyone** (the website must be able to read the published image list; the admin panel has its own login)

   Press **Deploy** and copy the **Web app URL** (it ends in `/exec`).
6. Open the URL, sign in, then go to **Settings → Change my password**.
7. **Connect the website:** in `js/site-config.js` set
   ```js
   cmsApi: 'https://script.google.com/macros/s/XXXXXXXX/exec',
   ```
   (Settings in the admin shows this exact line with a Copy button.)
8. Upload the website files to your hosting as usual. Files changed by this CMS work:
   every page `index.html` (rebuilt with `data-slot` keys), `js/cms.js` (new), `js/main.js`, `js/site-config.js`.
9. Check it: open `https://www.subhainfra.com/?cms_labels=1`. Badges should show image IDs (for example `HOME-HERO-1 · PEB-001`).

**Updating the Apps Script code later:** paste the new code, then **Deploy → Manage deployments → ✎ edit → Version: New version → Deploy**. The URL stays the same. A *New deployment* creates a different URL.

**Locked out?** In the editor, run `resetOwnerPassword`. The log prints a new temporary password.

---

## 3. Everyday workflow

| Step | Where |
|---|---|
| 1. Sign in | the web app URL |
| 2. Open **Image Library** | sidebar |
| 3. Upload 20 warehouse photos | **Upload images**, or drag files onto the library |
| 4–5. Choose **PEB Structures** › **Industrial Sheds** | upload dialog (it shows the numbers they will get) |
| 6. Numbers are assigned automatically, e.g. `PEB-005 … PEB-024` | server, under a lock: never duplicated |
| 7. Select the images | they are pre-selected after upload (**Show & select uploaded images**) |
| 8. Assign | **Place on website** (choose page → spot), or the **Landing Page** / **Services Pages** views (click a spot, or drag from the image tray), or **Add to project** in the bulk bar |
| 9. **Preview**, then **Publish** | top bar |
| 10. The website updates | new visitors immediately; returning visitors within `cmsCacheMinutes` (10 min) |

| Action | What happens |
|---|---|
| **Save as draft** | Every edit is saved immediately as a draft. The live site does not change. |
| **Preview** | Opens the real site showing drafts, in your browser only (`?cms_preview=…`). A bar marks preview mode. |
| **Publish** | Writes a new version of the published image list. |
| **Unpublish** | Switch a project's *Published* toggle off (its card leaves the portfolio grid), or press ✕ on a placement (it returns to its built-in image), then Publish. |
| **Replace** | Uploads a new file under the same ID. Every placement follows after Publish. The old file goes to the Drive trash. |
| **Archive / Inactive** | Hidden from the website. A placement using it falls back to its built-in image, and the dashboard warns you. |
| **Delete** | If the image is in use, you get a warning listing every placement and project first. The file goes to the Drive trash (recoverable for 30 days) and the ID is retired. |

---

## 4. Image storage & optimisation

- **Upload:** the browser resizes to max **2400 px** and converts to **WebP** (quality 0.86) before uploading, so files are typically 60–80% smaller with no visible loss. If the original is already smaller, it is kept as is. Older Safari versions without WebP encoding fall back to JPEG 90%. Both values are set in **Settings**.
- **Delivery:** Drive images are served from Google's image CDN at the exact width needed. `cms.js` writes a responsive `srcset` (480, 800, 1200, 1600, 2000 and 2400 px, up to the original width) with `sizes` matched to each placement, so phones download small files and 4K screens get sharp ones. Thumbnails in the admin use 320–640 px.
- **Lazy loading:** existing `loading="lazy"` / `fetchpriority` attributes are kept. `width`/`height` are updated where the page sets them (no layout shift).
- **Fallback:** if the CMS cannot be reached (within 8 s), the image built into the page stays. SEO is unchanged because crawlers still see the built-in `<img>` and its alt text.
- **URL template:** `https://lh3.googleusercontent.com/d/{id}=w{w}`. If Google ever changes this, switch it in Settings to `https://drive.google.com/thumbnail?id={id}&sz=w{w}` and Publish.

---

## 5. Database schema (Google Sheet — one tab per table)

All cells are stored as plain text. Never rename columns.

| Table | Columns | Notes |
|---|---|---|
| `images` | uid, image_id, prefix, seq, original_filename, display_name, category_code, subcategory, project_no, source, file_id, url, alt_text, width, height, bytes, mime, upload_date, updated_at, display_order, status, notes | `source` = `drive` (uploaded) or `site` (original website file in `url`). `status` = active · inactive · archived · deleted (deleted rows are kept so IDs are never reused). |
| `image_categories` | code, name, group, service_url, sort | `code` is the ID prefix. |
| `image_subcategories` | id, category_code, name, sort | Renaming updates the images that use it. |
| `website_sections` | slot_key, page, page_url, section, label, recommended_w, recommended_h, sizes, sort, source_file | One row per placement (from `Seed.gs`). |
| `image_assignments` | slot_key, image_id, updated_at, updated_by | Draft choice per placement. Empty = built-in image. |
| `projects` | project_no, slug, name, category, location, description, featured_image_id, status, year, featured, published, sort, updated_at | `slug` = existing page `/projects/<slug>/`. |
| `project_images` | project_no, image_id, role, sort | role = gallery · before · after. |
| `administrators` | email, name, role, salt, password_hash, active, last_login, created_at | role = owner · editor. |
| `website_settings` | key, value | site_url, image_url_template, upload_max_px, webp_quality, published_version, published_at, published_by |
| `counters` | prefix, last_seq | Next number = max(last_seq, highest used) + 1. |
| `audit_log` | time, user, action, details | Every upload, change, publish and login. |

The published version is also saved as `published.json` in the Drive folder and cached in Apps Script (CacheService, chunked, 6 h).

Editing the Sheet by hand is possible but skips the checks. Afterwards, run `republish` in the editor to push the change live.

---

## 6. API

**Public** — `GET <web app URL>?api=site`
```jsonc
{
  "ok": true, "v": 12, "at": "2026-11-08T10:15:00Z",
  "tpl": "https://lh3.googleusercontent.com/d/{id}=w{w}",
  "slots": {
    "HOME-HERO-1": { "i": "HOME-001", "d": "<drive file id>", "w": 2400, "h": 1350, "a": "alt text", "t": "name", "c": "Landing Page", "s": "100vw" },
    "NAV-SVC-PEB": { "i": "PEB-001", "u": "/assets/project-images/subha-infra-peb-structures-01.jpg", "w": 1600, "h": 900, … }
  },
  "projects": {
    "angular-white-villa": { "no": "PRJ-021", "pub": 1, "f": 0, "img": { …image… }, "gal": [ { …image…, "r": "Before" } ], "loc": "Bengaluru" }
  }
}
```
`d` = Drive file (URL built from `tpl`), `u` = original website file. Only *active* images are included. A placement that is missing from the list keeps its built-in image.

- `GET ?api=site&mode=draft&token=<admin session>` returns the same shape with unpublished drafts (used by Preview).
- `GET ?api=health` returns `{ ok, version, ready }`.

**Admin** — `google.script.run.rpc(token, action, args)` → `{ ok, data | error }`, after `login(email, password)` → `{ ok, token, user }`. Sessions last 6 hours.

| Action | args |
|---|---|
| bootstrap | — (images, categories, placements, projects, pending changes, settings) |
| uploadImage | name, mime, data (base64), width, height, category_code, subcategory, project_no, add_to_gallery, role, display_name, alt_text, status |
| replaceImage | image_id, name, mime, data, width, height |
| updateImage / bulkUpdate | image_id / ids, fields {display_name, alt_text, category_code, subcategory, project_no, status, notes} |
| setOrder | ids (display order) |
| imageUsage / deleteImages | image_id / ids, force |
| assignSlot | slot_key, image_id ('' = built-in) |
| saveProject / deleteProject / setProjectImages | project {…} / project_no / project_no, items [{image_id, role}] |
| saveCategory / saveSubcategory / deleteSubcategory | code, name, group, isNew / category_code, name, id / id |
| publish, downloadZip (ids, max 40), saveSettings, listAdmins, saveAdmin, changePassword, auditLog | |

Write actions run under a script lock, one at a time.

---

## 7. Adding a new image spot to the website (developer)

1. Add the `<img>` to the page in `_build/pages/…` (or a partial).
2. Add a line for it to that page's table in `generate-cms.ps1` (the format is `KEY|Section · Item`). The script refuses to run if the number of `<img>` tags and table lines differ.
3. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File _build\cms\generate-cms.ps1
   powershell -ExecutionPolicy Bypass -File _build\build.ps1
   ```
4. Paste the new `apps-script/Seed.gs` into the Apps Script project and run **`syncPlacements`**. This adds the new keys and keeps all existing choices.
5. Upload the site.

Logos and the favicon are deliberately *not* managed (brand assets).

---

## 8. Free-tier limits (personal Google account, no cost)

| Service | Limit | What it means here |
|---|---|---|
| Google Drive | 15 GB, shared with Gmail and Photos | About 30,000 optimised photos (~500 KB each) |
| Google Sheets | 10 million cells | ~450,000 image rows |
| Apps Script run time | 6 min per request | One upload is about 2–4 s; publish is under 10 s |
| Apps Script concurrency | 30 simultaneous requests | Each visitor calls the API at most once per 10 min (browser cache), and the answer comes from cache, so this is ample for a corporate site |
| UrlFetch | 20,000 / day | Only used by "Download" for original website files |
| CacheService | 100 KB per key, 6 h | The published list is split into chunks automatically |
| Image CDN (`lh3.googleusercontent.com`) | Not a documented Google product | Widely used, but Google could change it. Switch the template in Settings if it ever stops working. |

No paid services are used. If traffic ever grows very large, the published JSON (`published.json` in Drive) can be copied to the web host and `cmsApi` pointed at it.

## 9. Security

- Passwords are salted and hashed (SHA-256, 200 rounds). Sessions are random 64-character tokens that expire after 6 h. 5 failed logins lock that email for 15 minutes.
- Roles: **owner** (also settings and administrators) and **editor** (images, placements, projects, publish).
- Uploaded images are viewable by anyone who has the link, which is required to show them on a public website. Keep private documents out of the CMS Drive folder.
- The Sheet and Drive folder belong to the deploying account. Share them only with people you would trust as owners.

## 10. Not covered (by design, or still to do)

- **Text content** (team names, testimonials, SEO titles, contact details, rates) is still edited in `js/site-config.js` and `_build/pages`. The CMS manages images and project visibility, location and photos.
- **Brand-new project pages:** the CMS stores new projects (PRJ-042…) and their photos, but a new page at `/projects/<slug>/` still needs an entry in `_build/build.ps1` and a rebuild. Existing pages keep their URLs.
- **First visit:** a visitor's first page view shows the built-in image while the CMS list loads, then swaps (usually under a second). After that the list is cached, so the swap is near-instant.
