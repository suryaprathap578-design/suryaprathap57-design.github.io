/* =========================================================
   SUBHA INFRA — Image CMS loader
   Replaces website images with the ones published from the
   admin panel (Google Apps Script). The images built into the
   HTML stay as the fallback, so the site works (and SEO is
   unchanged) even if the CMS is unreachable.

   Every managed image carries a permanent placement key:
     <img data-slot="HOME-HERO-1" ...>        page placements
     <img data-project="angular-white-villa"> project featured image
     <div data-project-gallery="slug">        project gallery
     <x data-slot-container="TEAM-GROUP">     empty box filled with an image

   Helpers (add to any page URL):
     ?cms_labels=1        show the placement key + image ID on every image (?cms_labels=0 to hide)
     ?cms_highlight=KEY   scroll to and outline one placement
     ?cms_preview=TOKEN   preview unpublished changes (opened from the admin panel)
   ========================================================= */
(() => {
  const CFG = window.SITE_CONFIG || {};
  const API = String(CFG.cmsApi || '').trim();
  const qs = new URLSearchParams(location.search);
  const ss = { get(k) { try { return sessionStorage.getItem(k); } catch (e) { return null; } }, set(k, v) { try { v == null ? sessionStorage.removeItem(k) : sessionStorage.setItem(k, v); } catch (e) { } } };
  const ls = { get(k) { try { return JSON.parse(localStorage.getItem(k)); } catch (e) { return null; } }, set(k, v) { try { localStorage.setItem(k, JSON.stringify(v)); } catch (e) { } } };
  const $$ = (s, c = document) => [...c.querySelectorAll(s)];
  const esc = s => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

  if (qs.has('cms_labels')) ss.set('cms_labels', qs.get('cms_labels') === '0' ? null : '1');
  if (qs.has('cms_preview')) ss.set('cms_preview', qs.get('cms_preview') || null);
  const labels = ss.get('cms_labels') === '1';
  const preview = ss.get('cms_preview');
  const highlight = qs.get('cms_highlight');
  const CACHE_KEY = 'subha-cms-v1';
  const TTL = Math.max(0, Number(CFG.cmsCacheMinutes == null ? 10 : CFG.cmsCacheMinutes)) * 60000;
  const WIDTHS = [480, 800, 1200, 1600, 2000, 2400];
  let data = null;

  /* ---------- image URLs ---------- */
  const tpl = () => (data && data.tpl) || 'https://lh3.googleusercontent.com/d/{id}=w{w}';
  const urlFor = (m, w) => (m.d ? tpl().replace('{id}', m.d).replace('{w}', w) : m.u);
  const srcsetFor = m => {
    if (!m.d) return '';
    const max = Math.max(480, m.w || 2400);
    return WIDTHS.filter(w => w <= max).map(w => urlFor(m, w) + ' ' + w + 'w').join(', ');
  };
  const guessSizes = el => {
    if (el.closest('.ph-bg, .hh-slide, .cta-cine, .card-cine, .ct')) return '100vw';
    if (el.closest('.mega, .next-svc, .peek')) return '(max-width: 760px) 50vw, 320px';
    return '(max-width: 760px) 100vw, 50vw';
  };

  /* ---------- apply one image ---------- */
  const ORIG = new WeakMap();   // built-in attributes / HTML, captured before the first change
  const remember = el => {
    if (ORIG.has(el)) return ORIG.get(el);
    const a = el.closest('a[data-lb]');
    const o = { src: el.getAttribute('src'), srcset: el.getAttribute('srcset'), sizes: el.getAttribute('sizes'), alt: el.getAttribute('alt'),
      w: el.getAttribute('width'), h: el.getAttribute('height'), href: a ? a.getAttribute('href') : null, title: a ? a.dataset.title : null };
    ORIG.set(el, o);
    return o;
  };
  const rememberHtml = box => { if (!ORIG.has(box)) ORIG.set(box, box.innerHTML); return ORIG.get(box); };
  const setAttr = (el, k, v) => (v == null ? el.removeAttribute(k) : el.setAttribute(k, v));
  const restore = el => {
    if (!ORIG.has(el)) return;
    const o = ORIG.get(el);
    ['srcset', 'sizes', 'alt'].forEach(k => setAttr(el, k, o[k]));
    setAttr(el, 'width', o.w); setAttr(el, 'height', o.h); el.setAttribute('src', o.src);
    const a = el.closest('a[data-lb]'); if (a && o.href) { a.setAttribute('href', o.href); if (o.title != null) a.dataset.title = o.title; }
    delete el.dataset.cmsId;
  };
  const setImg = (el, m, sizes) => {
    if (!m) { restore(el); return; }
    const o = remember(el);
    el.dataset.cmsId = m.i;
    if (!m.d && m.u === o.src) { restore(el); el.dataset.cmsId = m.i; return; }   // same as the built-in image
    const ss2 = srcsetFor(m);
    if (ss2) { el.setAttribute('srcset', ss2); el.setAttribute('sizes', sizes || o.sizes || guessSizes(el)); } else { el.removeAttribute('srcset'); el.removeAttribute('sizes'); }
    el.setAttribute('src', m.d ? urlFor(m, 1600) : m.u);
    if (o.w && m.w && m.h) { el.setAttribute('width', m.w); el.setAttribute('height', m.h); }
    if (o.alt !== '' && m.a) el.setAttribute('alt', m.a);
    const a = el.closest('a[data-lb]');
    if (a) { a.setAttribute('href', m.d ? urlFor(m, 2400) : m.u); if (m.t) a.dataset.title = m.t; }
    const slide = el.closest('.hh-slide');
    if (slide && (m.t || m.c)) {
      if (m.t) slide.dataset.title = m.t;
      if (m.c) slide.dataset.cat = m.c;
      if (slide.classList.contains('on')) {
        const cap = document.querySelector('.hh-caption');
        if (cap) { const s = cap.querySelector('small'), b = cap.querySelector('b'); if (s && m.c) s.textContent = m.c; if (b && m.t) b.textContent = m.t; }
      }
    }
  };

  /* ---------- apply everything ---------- */
  const apply = d => {
    data = d || { slots: {}, projects: {} };
    const slots = data.slots || {}, prj = data.projects || {};
    $$('[data-slot-container], [data-project-gallery]').forEach(rememberHtml);
    $$('img[data-slot]').forEach(el => setImg(el, slots[el.dataset.slot], (slots[el.dataset.slot] || {}).s));
    $$('[data-slot-container]').forEach(box => {
      const m = slots[box.dataset.slotContainer];
      if (!m) { if (box.dataset.cmsId) { box.innerHTML = ORIG.get(box); delete box.dataset.cmsId; } return; }
      box.innerHTML = '<img alt="' + esc(m.a || '') + '" loading="lazy">';
      box.dataset.cmsId = m.i; setImg(box.firstChild, m, m.s);
    });
    $$('img[data-project]').forEach(el => { const p = prj[el.dataset.project]; setImg(el, p && p.img); });
    $$('[data-project-location]').forEach(el => { const p = prj[el.dataset.projectLocation]; if (p && p.loc) el.textContent = p.loc; });
    $$('[data-project-gallery]').forEach(box => {
      const p = prj[box.dataset.projectGallery];
      if (!p || !p.gal || !p.gal.length) { if (box.dataset.cmsGal) { box.innerHTML = ORIG.get(box); delete box.dataset.cmsGal; $$('img[data-project]', box).forEach(el => setImg(el, (prj[el.dataset.project] || {}).img)); } return; }
      box.dataset.cmsGal = '1';
      box.innerHTML = p.gal.map(m => '<a class="img zoom" href="' + esc(m.d ? urlFor(m, 2400) : m.u) + '" data-lb="g" data-title="' + esc(m.t || '') + '" data-cat="' + esc(m.r || box.dataset.cat || '') + '"><img data-cms-gal="' + esc(m.i) + '" src="' + esc(m.d ? urlFor(m, 1200) : m.u) + '"' + (m.d ? ' srcset="' + esc(srcsetFor(m)) + '" sizes="(max-width: 760px) 100vw, 50vw"' : '') + ' alt="' + esc(m.a || m.t || '') + '" loading="lazy"></a>').join('');
      $$('img', box).forEach((im, k) => { im.dataset.cmsId = p.gal[k].i; });
    });
    // Unpublished projects disappear from the portfolio grid (their page URL keeps working)
    $$('[data-filter-item] img[data-project]').forEach(el => { const p = prj[el.dataset.project]; const card = el.closest('[data-filter-item]'); if (card) card.hidden = !!(p && p.pub === 0); });
    if (labels) drawLabels();
    document.dispatchEvent(new CustomEvent('subha:cms', { detail: data }));
  };

  /* ---------- labels overlay (?cms_labels=1) ---------- */
  function drawLabels() {
    if (!document.getElementById('cms-lbl-css')) {
      const st = document.createElement('style'); st.id = 'cms-lbl-css';
      st.textContent = '.cms-badge{position:absolute;z-index:30;left:8px;top:8px;max-width:calc(100% - 16px);background:#101D2B;color:#fff;border:1px solid #B69A70;border-radius:6px;padding:4px 8px;font:600 11px/1.3 ui-monospace,Consolas,monospace;letter-spacing:.02em;box-shadow:0 4px 14px rgba(0,0,0,.35);cursor:copy;pointer-events:auto;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.cms-badge i{font-style:normal;color:#E5CF9F}.cms-badge.prj{background:#6b4f1d}.cms-bar{position:fixed;z-index:9999;left:50%;bottom:16px;transform:translateX(-50%);background:#101D2B;color:#fff;border:1px solid #B69A70;border-radius:999px;padding:10px 16px;font:500 13px Inter,Arial,sans-serif;box-shadow:0 10px 30px rgba(0,0,0,.35);display:flex;gap:12px;align-items:center;max-width:calc(100vw - 32px)}.cms-bar a{color:#E5CF9F}';
      document.head.appendChild(st);
    }
    $$('.cms-badge').forEach(b => b.remove());
    const add = (el, key, id, cls) => {
      const host = el.tagName === 'IMG' ? el.parentElement : el;
      if (!host) return;
      if (getComputedStyle(host).position === 'static') host.style.position = 'relative';
      const b = document.createElement('span');
      b.className = 'cms-badge' + (cls ? ' ' + cls : '');
      b.innerHTML = esc(key) + (id ? ' · <i>' + esc(id) + '</i>' : ' · <i>built-in</i>');
      b.title = 'Click to copy ' + key;
      b.addEventListener('click', e => { e.preventDefault(); e.stopPropagation(); if (navigator.clipboard) navigator.clipboard.writeText(key); b.innerHTML = 'Copied ' + esc(key); });
      host.appendChild(b);
    };
    $$('img[data-slot]').forEach(el => add(el, el.dataset.slot, el.dataset.cmsId));
    $$('[data-slot-container]').forEach(el => add(el, el.dataset.slotContainer, el.dataset.cmsId));
    $$('img[data-project]').forEach(el => add(el, 'PROJECT ' + el.dataset.project, el.dataset.cmsId, 'prj'));
    $$('img[data-cms-gal]').forEach(el => add(el, 'GALLERY', el.dataset.cmsId, 'prj'));
    bar('Image labels are on: each badge shows <b>placement key · image ID</b>. Click a badge to copy it. <a href="?cms_labels=0">Hide labels</a>', 'cms-lbl-bar');
  }
  function bar(html, id) {
    let b = document.getElementById(id);
    if (!b) { b = document.createElement('div'); b.id = id; b.className = 'cms-bar'; document.body.appendChild(b); }
    b.innerHTML = '<span>' + html + '</span>';
    if (id === 'cms-prev-bar' && document.getElementById('cms-lbl-bar')) b.style.bottom = '70px';
    return b;
  }
  function doHighlight() {
    if (!highlight) return;
    const el = document.querySelector('[data-slot="' + CSS.escape(highlight) + '"], [data-slot-container="' + CSS.escape(highlight) + '"]');
    if (!el) return;
    const box = el.tagName === 'IMG' ? el.parentElement : el;
    if (el.closest('.mega')) { bar('<b>' + esc(highlight) + '</b> is inside the header menu: hover <b>' + (highlight.indexOf('NAV-SVC') === 0 ? 'Services' : 'Projects') + '</b> to see it.', 'cms-hl-bar'); return; }
    box.style.outline = '4px solid #B69A70'; box.style.outlineOffset = '4px';
    setTimeout(() => box.scrollIntoView({ behavior: 'smooth', block: 'center' }), 400);
  }

  /* ---------- load ---------- */
  window.SubhaCMS = { apply: d => apply(d || data), labels: drawLabels };
  if (labels || highlight) addEventListener('load', () => { if (labels) drawLabels(); doHighlight(); });
  if (!API) { if (labels) drawLabels(); return; }

  const endpoint = API + (API.indexOf('?') > -1 ? '&' : '?') + 'api=site' + (preview ? '&mode=draft&token=' + encodeURIComponent(preview) : '');
  const fetchData = () => {
    const ctl = 'AbortController' in window ? new AbortController() : null;
    const t = setTimeout(() => ctl && ctl.abort(), 8000);
    return fetch(endpoint, { signal: ctl ? ctl.signal : undefined, credentials: 'omit' })
      .then(r => r.json()).then(d => { clearTimeout(t); if (!d || d.ok === false) throw new Error((d && d.error) || 'CMS error'); return d; });
  };

  if (preview) {
    fetchData().then(d => { apply(d); bar('Previewing <b>unpublished</b> image changes (draft v' + esc(d.v) + '). <a href="#" id="cms-exit">Exit preview</a>', 'cms-prev-bar'); const x = document.getElementById('cms-exit'); if (x) x.onclick = e => { e.preventDefault(); ss.set('cms_preview', null); location.href = location.pathname; }; })
      .catch(err => { bar('Preview failed: ' + esc(err.message) + '. Your admin session may have expired — log in again and reopen Preview.', 'cms-prev-bar'); ss.set('cms_preview', null); });
    return;
  }
  const cached = ls.get(CACHE_KEY);
  if (cached && cached.d && cached.api === API) apply(cached.d);
  if (cached && cached.api === API && Date.now() - cached.t < TTL) return;
  fetchData().then(d => {
    ls.set(CACHE_KEY, { t: Date.now(), api: API, d: d });
    if (!cached || !cached.d || cached.d.v !== d.v || cached.api !== API) apply(d);
  }).catch(() => { /* keep built-in or cached images */ });
})();
