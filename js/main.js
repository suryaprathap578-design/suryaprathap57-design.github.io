/* =========================================================
   SUBHA INFRA — site interactions
   Contact details, social links, team and rates live in site-config.js
   ========================================================= */
(() => {
  const CFG = window.SITE_CONFIG || {};
  const $ = (s, c = document) => c.querySelector(s);
  const $$ = (s, c = document) => [...c.querySelectorAll(s)];
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const body = document.body;
  const inr = n => Math.round(n).toLocaleString('en-IN');
  const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const waLink = text => `https://wa.me/${String(CFG.whatsapp || '').replace(/\D/g, '')}?text=${encodeURIComponent(text || CFG.whatsappMessage || '')}`;
  const asset = p => (/^(https?:|\/|data:)/i.test(String(p)) ? String(p) : '/' + String(p));
  const rateOf = path => path.split('.').reduce((o, k) => (o && o[k] !== undefined ? o[k] : undefined), CFG.rates || {});

  /* ---------- Apply site-config.js ---------- */
  const setText = (el, t) => { if (!el.children.length && t) el.textContent = t; };
  $$('[data-cfg]').forEach(el => {
    const k = el.dataset.cfg;
    if (k === 'tel' && CFG.phone) { el.href = 'tel:' + CFG.phone; setText(el, CFG.phoneDisplay); }
    if (k === 'email' && CFG.email) { el.href = 'mailto:' + CFG.email; setText(el, CFG.email); }
    if (k === 'wa' && CFG.whatsapp) el.href = waLink();
    if (k === 'address' && CFG.address) el.textContent = CFG.address;
    if (k === 'map' && CFG.mapQuery) el.src = 'https://www.google.com/maps?q=' + encodeURIComponent(CFG.mapQuery) + '&output=embed';
  });
  $$('[data-cfg-text]').forEach(el => {
    const k = el.dataset.cfgText;
    if (k === 'phone' && CFG.phoneDisplay) el.textContent = CFG.phoneDisplay;
    if (k === 'email' && CFG.email) el.textContent = CFG.email;
  });
  $$('[data-social]').forEach(a => {
    const k = a.dataset.social;
    const url = k === 'whatsapp' ? (CFG.whatsapp ? waLink() : '') : ((CFG.social || {})[k] || '');
    if (url) a.href = url; else a.hidden = true;
  });
  $$('[data-rate]').forEach(el => {
    const v = Number(rateOf(el.dataset.rate));
    if (v > 0) el.textContent = inr(v);
    else { el.textContent = 'On enquiry'; el.classList.add('enq'); const p = el.closest('.tier-rate, .dz-rate'); if (p) p.classList.add('enq'); }
  });
  $$('[data-rate-inline]').forEach(el => { const v = Number(rateOf(el.dataset.rateInline)); el.textContent = v > 0 ? `(₹${inr(v)} / sq ft)` : '(on enquiry)'; });
  $$('[data-year]').forEach(el => { el.textContent = new Date().getFullYear(); });

  /* ---------- Team (from config) ---------- */
  const teamBox = $('[data-team]');
  if (teamBox && Array.isArray(CFG.team) && CFG.team.length) {
    teamBox.innerHTML = CFG.team.map((m, i) => `<article class="tm zoom reveal"><div class="img"><img data-slot="TEAM-MEMBER-${i + 1}" src="${esc(asset(m.photo || 'assets/images/team/placeholder.svg'))}" alt="${esc(m.name || '')}${m.role ? ', ' + esc(m.role) : ''}" loading="lazy"></div><b>${esc(m.name || '')}</b><span>${esc(m.role || '')}</span></article>`).join('');
  }
  const gp = $('[data-group-photo]');
  if (gp && CFG.groupPhoto) gp.innerHTML = `<img src="${esc(asset(CFG.groupPhoto))}" alt="The SUBHA INFRA team" loading="lazy">`;

  /* ---------- Header ---------- */
  const hdr = $('.hdr');
  let lastY = scrollY;
  const onScroll = () => {
    const y = scrollY;
    if (hdr) {
      hdr.classList.toggle('scrolled', y > 30);
      const hold = $('.has-mega.open') || body.classList.contains('nav-open');
      if (y > 600 && y > lastY + 6 && !hold) hdr.classList.add('hide');
      else if (y < lastY - 6 || y < 600) hdr.classList.remove('hide');
    }
    lastY = y;
  };
  addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ---------- Mega menus ---------- */
  $$('.has-mega').forEach(li => {
    let t;
    const trigger = li.firstElementChild;
    const open = () => { clearTimeout(t); $$('.has-mega.open').forEach(o => o !== li && o.classList.remove('open')); li.classList.add('open'); trigger.setAttribute('aria-expanded', 'true'); };
    const close = () => { t = setTimeout(() => { li.classList.remove('open'); trigger.setAttribute('aria-expanded', 'false'); }, 180); };
    li.addEventListener('pointerenter', e => e.pointerType === 'mouse' && open());
    li.addEventListener('pointerleave', e => e.pointerType === 'mouse' && close());
    li.addEventListener('focusin', open);
    li.addEventListener('focusout', e => { if (!li.contains(e.relatedTarget)) close(); });
    trigger.addEventListener('click', e => { if (!li.classList.contains('open') && matchMedia('(hover: none)').matches) { e.preventDefault(); open(); } });
  });

  /* ---------- Mobile nav ---------- */
  const burger = $('.burger');
  const toggleNav = force => {
    const on = typeof force === 'boolean' ? force : !body.classList.contains('nav-open');
    body.classList.toggle('nav-open', on);
    if (burger) burger.setAttribute('aria-expanded', String(on));
    const m = $('.mnav'); if (m) m.setAttribute('aria-hidden', String(!on));
  };
  if (burger) burger.addEventListener('click', () => toggleNav());
  addEventListener('keydown', e => {
    if (e.key !== 'Escape') return;
    $$('.has-mega.open').forEach(li => { li.classList.remove('open'); li.firstElementChild.focus(); });
    if (body.classList.contains('nav-open')) toggleNav(false);
  });

  /* ---------- Reveal on scroll ---------- */
  const watch = $$('.reveal, .reveal-img, .split-line, .tl, .jr-step');
  if ('IntersectionObserver' in window && !reduce) {
    const io = new IntersectionObserver(entries => {
      entries.forEach(en => { if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); } });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
    watch.forEach(el => io.observe(el));
  } else watch.forEach(el => el.classList.add('in'));

  /* ---------- Home hero ---------- */
  const hh = $('.hh');
  if (hh) {
    const slides = $$('.hh-slide', hh);
    const aside = $('.hh-aside', hh);
    const prog = $('.hh-progress', hh);
    const interval = Number(CFG.heroInterval) || 3000;
    hh.style.setProperty('--hh-int', interval + 'ms');
    if (prog) prog.innerHTML = slides.map(() => '<span><i></i></span>').join('');
    const bars = prog ? $$('span', prog) : [];
    let i = 0, timer;
    const show = n => {
      const prev = i;
      i = (n + slides.length) % slides.length;
      slides.forEach((s, k) => s.classList.toggle('on', k === i));
      bars.forEach((b, k) => { b.classList.remove('run'); b.classList.toggle('done', k < i); });
      if (bars[i]) { void bars[i].offsetWidth; if (!reduce) bars[i].classList.add('run'); }
      if (aside && prev !== i) {
        aside.classList.add('swap');
        setTimeout(() => {
          $('.hh-num', aside).textContent = String(i + 1).padStart(2, '0');
          $('.hh-caption small', aside).textContent = slides[i].dataset.cat || '';
          $('.hh-caption b', aside).textContent = slides[i].dataset.title || '';
          aside.classList.remove('swap');
        }, 420);
      }
      clearTimeout(timer);
      if (!reduce) timer = setTimeout(() => show(i + 1), interval);
    };
    // preload the remaining hero images so crossfades are seamless
    slides.forEach(s => { const im = $('img', s); if (im && im.loading === 'lazy') { im.loading = 'eager'; } });
    document.addEventListener('visibilitychange', () => { if (document.hidden) clearTimeout(timer); else show(i); });
    requestAnimationFrame(() => requestAnimationFrame(() => { hh.classList.add('in'); $$('.split-line', hh).forEach(l => l.classList.add('in')); }));
    show(0);
  }

  /* ---------- Auto-advancing horizontal rails ---------- */
  $$('[data-rail]').forEach(wrap => {
    const rail = $('.rail', wrap);
    if (!rail) return;
    const step = () => (rail.firstElementChild ? rail.firstElementChild.getBoundingClientRect().width + 24 : 400);
    const prog = $('.rail-progress i', wrap);
    const upd = () => {
      if (!prog) return;
      const max = rail.scrollWidth - rail.clientWidth, vis = rail.clientWidth / rail.scrollWidth;
      prog.style.width = (vis * 100) + '%';
      prog.style.transform = `translateX(${max > 0 ? (rail.scrollLeft / max) * ((1 - vis) / vis) * 100 : 0}%)`;
    };
    rail.addEventListener('scroll', upd, { passive: true }); addEventListener('resize', upd); upd();
    let paused = false, resumeT;
    const pause = () => { paused = true; clearTimeout(resumeT); };
    const resume = (ms = 0) => { clearTimeout(resumeT); resumeT = setTimeout(() => { paused = false; }, ms); };
    wrap.addEventListener('pointerenter', e => e.pointerType === 'mouse' && pause());
    wrap.addEventListener('pointerleave', e => e.pointerType === 'mouse' && resume());
    wrap.addEventListener('focusin', pause); wrap.addEventListener('focusout', () => resume());
    rail.addEventListener('touchstart', pause, { passive: true });
    rail.addEventListener('touchend', () => resume(6000), { passive: true });
    if (!reduce) setInterval(() => {
      if (paused || document.hidden) return;
      const r = rail.getBoundingClientRect();
      if (r.bottom < 0 || r.top > innerHeight) return;
      const max = rail.scrollWidth - rail.clientWidth;
      if (rail.scrollLeft >= max - 8) rail.scrollTo({ left: 0, behavior: 'smooth' });
      else rail.scrollBy({ left: step(), behavior: 'smooth' });
    }, 3000);
    // mouse drag
    let down = false, sx = 0, sl = 0, moved = false;
    rail.addEventListener('pointerdown', e => { if (e.pointerType !== 'mouse') return; down = true; moved = false; sx = e.clientX; sl = rail.scrollLeft; });
    addEventListener('pointermove', e => { if (!down) return; const dx = e.clientX - sx; if (Math.abs(dx) > 5) { moved = true; rail.classList.add('drag'); } rail.scrollLeft = sl - dx; });
    addEventListener('pointerup', () => { if (!down) return; down = false; setTimeout(() => rail.classList.remove('drag'), 0); });
    rail.addEventListener('click', e => { if (moved) { e.preventDefault(); moved = false; } }, true);
  });

  /* ---------- Portfolio filters ---------- */
  $$('[data-filter-group]').forEach(group => {
    const target = group.dataset.filterGroup;
    const items = $$(`[data-filter-item="${target}"]`);
    const chips = $$('.chip', group);
    const count = $(`[data-filter-count="${target}"]`);
    const apply = key => {
      chips.forEach(c => c.setAttribute('aria-pressed', String(c.dataset.filter === key)));
      let n = 0;
      items.forEach(it => { const show = key === 'all' || (it.dataset.cats || '').split(' ').includes(key); it.classList.toggle('hidden', !show); if (show) n++; });
      if (count) count.textContent = n;
    };
    chips.forEach(c => c.addEventListener('click', () => {
      apply(c.dataset.filter);
      if (group.hasAttribute('data-hash')) history.replaceState(null, '', c.dataset.filter === 'all' ? location.pathname : '#' + c.dataset.filter);
    }));
    const fromHash = () => { const h = location.hash.slice(1); apply(chips.some(c => c.dataset.filter === h) ? h : 'all'); };
    fromHash();
    if (group.hasAttribute('data-hash')) addEventListener('hashchange', fromHash);
  });

  /* ---------- Package tabs ---------- */
  const tabs = $$('.pkg-tabs [data-tab]');
  if (tabs.length) {
    const panels = $$('[data-panel]');
    const bar = $('.pkg-tabs-bar');
    const select = (id, scroll) => {
      if (!panels.some(p => p.dataset.panel === id)) return false;
      tabs.forEach(t => t.setAttribute('aria-selected', String(t.dataset.tab === id)));
      panels.forEach(p => p.classList.toggle('on', p.dataset.panel === id));
      if (scroll && bar) scrollTo({ top: bar.getBoundingClientRect().top + scrollY - 82 + 1, behavior: reduce ? 'auto' : 'smooth' });
      return true;
    };
    tabs.forEach(t => t.addEventListener('click', () => { select(t.dataset.tab); history.replaceState(null, '', '#' + t.dataset.tab); }));
    const fromHash = () => { const h = location.hash.slice(1); if (!select(h, true)) select(tabs[0].dataset.tab); };
    if (!select(location.hash.slice(1), true)) select(tabs[0].dataset.tab);
    addEventListener('hashchange', fromHash);
  }

  /* ---------- Cost estimator ---------- */
  const calc = $('[data-calc]');
  if (calc) initCalc(calc);

  function initCalc(box) {
    const form = $('form', box);
    const TIERS = {
      residential: [['essential', 'Essential'], ['premium', 'Premium'], ['signature', 'Signature']],
      commercial: [['core', 'Shell & Core'], ['standard', 'Standard Commercial'], ['premium', 'Premium Commercial']],
      peb: [['basic', 'Basic Shed'], ['standard', 'Standard PEB'], ['premium', 'Premium Insulated PEB']],
      tensile: [['shade', 'Shade Structure'], ['canopy', 'Cantilever Tensile Canopy'], ['signature', 'Signature Entrance Canopy']],
      design: [['concept', 'Concept Design'], ['construction', 'Construction Design'], ['complete', 'Complete Design']]
    };
    const TYPE_LABEL = { residential: 'Residential', commercial: 'Commercial', peb: 'PEB & Industrial', tensile: 'Tensile Fabric', design: 'Architectural Design' };
    const CODE = { residential: 'res', commercial: 'com', peb: 'peb', tensile: 'ten', design: 'design' };
    const CAT = { residential: 'Residential', commercial: 'Commercial', peb: 'PEB', tensile: 'Tensile', design: '' };
    const FLOOR = ['Ground floor', 'First floor', 'Second floor', 'Third floor', 'Fourth floor'];
    const tierSel = form.tier, floorsSel = form.floors, floorBox = $('.calc-floors', box);
    const floorVals = [];
    const num = el => Math.max(0, parseFloat(el && el.value) || 0);
    const type = () => (form.querySelector('[name="ctype"]:checked') || {}).value || 'residential';
    const ex = k => Number(((CFG.rates || {}).extras || {})[k]) || 0;

    const fillTiers = keep => {
      const t = type();
      tierSel.innerHTML = TIERS[t].map(([k, l]) => {
        const r = Number(rateOf(`${t}.${k}`));
        return `<option value="${k}">${l} — ${r > 0 ? '₹' + inr(r) + ' / sq ft' : 'on enquiry'}</option>`;
      }).join('');
      if (keep && TIERS[t].some(x => x[0] === keep)) tierSel.value = keep;
      $$('[data-show]', box).forEach(el => el.classList.toggle('off', !el.dataset.show.split(' ').includes(t)));
    };
    const fillFloors = () => {
      $$('input', floorBox).forEach((inp, k) => { floorVals[k] = inp.value; });
      const n = Number(floorsSel.value) || 1;
      floorBox.innerHTML = Array.from({ length: n }, (_, k) => `<label class="calc-f"><span class="calc-lbl">${FLOOR[k]} (sq ft)</span><input type="number" min="0" inputmode="decimal" data-floor="${k}" placeholder="e.g. 1200" value="${esc(floorVals[k] || '')}"></label>`).join('');
    };

    const compute = () => {
      const t = type(), tier = tierSel.value;
      const tierName = (TIERS[t].find(x => x[0] === tier) || ['', ''])[1];
      const rate = Number(rateOf(`${t}.${tier}`)) || 0;
      const rows = [];
      const add = (label, qty, unit, r) => rows.push({ label, qty, unit, r, amt: r > 0 ? qty * r : null });
      if (t === 'residential' || t === 'commercial') {
        $$('[data-floor]', floorBox).forEach(inp => { const a = num(inp); if (a) add(`${FLOOR[+inp.dataset.floor]} — ${tierName}`, a, 'sq ft', rate); });
        if (num(form.sump)) add('RCC water sump', num(form.sump), 'L', ex('sump'));
        if (num(form.septic)) add('Septic tank', num(form.septic), 'L', ex('septic'));
        const cw = num(form.cwl) * num(form.cwh);
        if (cw) add('Plain compound wall', cw, 'sq ft', ex('compoundWall'));
      } else if (t === 'peb' || t === 'tensile') {
        const a = num(form.len) * num(form.wid);
        if (a) add(t === 'peb' ? `PEB structure — ${tierName}` : tierName, a, 'sq ft', rate);
        if (t === 'peb' && a) {
          if (form.puf.checked) add('50 mm PUF sandwich roofing', a, 'sq ft', ex('pufRoofing'));
          const sky = Math.min(30, num(form.sky));
          if (sky) add(`Polycarbonate skylight (${sky}%)`, a * sky / 100, 'sq ft', ex('skylight'));
        }
        if (t === 'peb' && num(form.ms)) add('MS support structure', num(form.ms), 'sq ft', ex('msStructure'));
      } else {
        const a = num(form.darea);
        if (a) add(tierName, a, 'sq ft', rate);
      }
      const sub = rows.reduce((s, r) => s + (r.amt || 0), 0);
      const gstP = Number(CFG.gstPercent) || 0;
      const gst = sub * gstP / 100;
      const enquiry = rows.some(r => r.amt === null);

      $('[data-calc-title]', box).textContent = `${TYPE_LABEL[t]} · ${tierName}`;
      $('[data-calc-rows]', box).innerHTML = rows.length
        ? rows.map(r => `<tr><td>${esc(r.label)}</td><td>${inr(r.qty)} ${r.unit}</td><td>${r.r > 0 ? '₹' + inr(r.r) : '—'}</td><td>${r.amt === null ? 'On enquiry' : '₹ ' + inr(r.amt)}</td></tr>`).join('')
        : '<tr class="calc-empty"><td colspan="4">Enter your areas to see the estimate.</td></tr>';
      $('[data-calc-sub]', box).textContent = '₹ ' + inr(sub);
      $('[data-calc-gstlbl]', box).textContent = gstP ? `GST ${gstP}%` : 'GST';
      $('[data-calc-gst]', box).textContent = '₹ ' + inr(gst);
      $('[data-calc-total]', box).textContent = '₹ ' + inr(sub + gst) + (enquiry ? ' +' : '');

      const lines = rows.map(r => `• ${r.label}: ${inr(r.qty)} ${r.unit}${r.amt === null ? ' (rate on enquiry)' : ' × ₹' + inr(r.r) + ' = ₹' + inr(r.amt)}`);
      const msg = `Hello ${CFG.company || 'SUBHA INFRA'}, I used the cost estimator on your website.\n\nPackage: ${TYPE_LABEL[t]} — ${tierName}\n${lines.join('\n')}\n\nSubtotal: ₹${inr(sub)}\nGST ${gstP}%: ₹${inr(gst)}\nEstimated total: ₹${inr(sub + gst)}\n\nPlease share a detailed quotation.`;
      $('[data-calc-wa]', box).href = waLink(msg);
      const q = new URLSearchParams({ package: `${CODE[t]}-${tier}` });
      if (CAT[t]) q.set('category', CAT[t]);
      $('[data-calc-quote]', box).href = '/contact/?' + q.toString();
    };

    form.addEventListener('change', e => {
      if (e.target.name === 'ctype') fillTiers();
      if (e.target.name === 'floors') fillFloors();
      compute();
    });
    form.addEventListener('input', compute);
    $$('[data-preset]').forEach(a => a.addEventListener('click', () => {
      const [t, tier] = a.dataset.preset.split(':');
      const r = form.querySelector(`[name="ctype"][value="${t}"]`);
      if (r) { r.checked = true; fillTiers(tier); compute(); }
    }));
    fillTiers(); fillFloors(); compute();
  }

  /* ---------- Lightbox ---------- */
  // Delegated, so gallery links added later (e.g. by js/cms.js) open in the viewer too.
  if ($('[data-lb]')) {
    const dlg = document.createElement('dialog');
    dlg.className = 'lb';
    dlg.setAttribute('aria-label', 'Image viewer');
    dlg.innerHTML = '<div class="lb-top"><span data-c></span><button type="button" data-x aria-label="Close"><svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M2 2l12 12M14 2L2 14"/></svg></button></div><div class="lb-stage"><img alt="" title="Click for next image"></div><div class="lb-cap"><div><small class="cap-label" data-k></small><br><b data-t></b></div></div>';
    body.appendChild(dlg);
    let list = [], idx = 0, auto;
    const img = $('img', dlg);
    const render = () => {
      const a = list[idx];
      img.src = a.getAttribute('href'); img.alt = a.dataset.title || '';
      $('[data-t]', dlg).textContent = a.dataset.title || '';
      $('[data-k]', dlg).textContent = a.dataset.cat || '';
      $('[data-c]', dlg).textContent = `${String(idx + 1).padStart(2, '0')} / ${String(list.length).padStart(2, '0')}`;
    };
    const go = d => { idx = (idx + d + list.length) % list.length; render(); };
    document.addEventListener('click', e => {
      const a = e.target.closest('a[data-lb]');
      if (!a || e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey) return;
      e.preventDefault();
      list = $$('a[data-lb]').filter(x => x.dataset.lb === a.dataset.lb && !x.closest('.hidden'));
      idx = list.indexOf(a); render();
      if (dlg.showModal) dlg.showModal(); else dlg.setAttribute('open', '');
      clearInterval(auto); if (!reduce && list.length > 1) auto = setInterval(() => go(1), 3500);
    });
    img.addEventListener('click', () => go(1));
    $('[data-x]', dlg).addEventListener('click', () => dlg.close());
    dlg.addEventListener('close', () => clearInterval(auto));
    dlg.addEventListener('click', e => { if (e.target === dlg || e.target.classList.contains('lb-stage')) dlg.close(); });
    dlg.addEventListener('keydown', e => { if (e.key === 'ArrowLeft') go(-1); if (e.key === 'ArrowRight') go(1); });
  }

  /* ---------- Timelines (process page + design journey) ---------- */
  const vt = $('.vt');
  const journeys = $$('.journey');
  if (vt || journeys.length) {
    const upd = () => {
      const mid = innerHeight * 0.6;
      if (vt) {
        const r = vt.getBoundingClientRect(), fill = $('.vt-line i', vt);
        if (fill) fill.style.transform = `scaleY(${Math.min(1, Math.max(0, (mid - r.top) / r.height))})`;
        $$('.vt-step', vt).forEach(s => s.classList.toggle('active', s.getBoundingClientRect().top < mid));
      }
      journeys.forEach(j => {
        const r = j.getBoundingClientRect();
        j.style.setProperty('--jp', Math.min(1, Math.max(0, (mid - r.top) / r.height)).toFixed(3));
        $$('.jr-step', j).forEach(s => s.classList.toggle('lit', s.getBoundingClientRect().top + 28 < mid));
      });
    };
    addEventListener('scroll', upd, { passive: true }); addEventListener('resize', upd); upd();
  }

  /* ---------- Gentle parallax ---------- */
  const par = $$('[data-parallax]');
  if (par.length && !reduce) {
    let ticking = false;
    const run = () => {
      par.forEach(el => {
        const r = el.parentElement.getBoundingClientRect();
        if (r.bottom < 0 || r.top > innerHeight) return;
        el.style.transform = `translate3d(0, ${(r.top + r.height / 2 - innerHeight / 2) * -(parseFloat(el.dataset.parallax) || 0.12)}px, 0)`;
      });
      ticking = false;
    };
    addEventListener('scroll', () => { if (!ticking) { ticking = true; requestAnimationFrame(run); } }, { passive: true });
    run();
  }

  /* ---------- Page transitions (soft fade with logo) ---------- */
  const veil = $('.veil');
  if (veil && !reduce) {
    document.addEventListener('click', e => {
      const a = e.target.closest('a');
      if (!a || e.defaultPrevented || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button !== 0) return;
      const href = a.getAttribute('href') || '';
      if (a.target || a.hasAttribute('download') || a.dataset.lb !== undefined || href.charAt(0) === '#' || /^[a-z]+:/i.test(href)) return;
      const url = new URL(a.href, location.href);
      if (url.origin !== location.origin || url.pathname === location.pathname) return;
      if (/\.[a-z0-9]{2,5}$/i.test(url.pathname) && !/\.html$/i.test(url.pathname)) return;
      e.preventDefault();
      veil.classList.add('on');
      setTimeout(() => { location.href = a.href; }, 520);
    });
  }
  addEventListener('pageshow', () => veil && veil.classList.remove('on'));

  /* ---------- Enquiry form ---------- */
  const form = $('#enquiry');
  if (form) initForm(form);

  function initForm(form) {
    const steps = $$('.fstep', form);
    const ind = $$('.steps-ind li', form.parentElement);
    const prev = $('[data-prev]', form), next = $('[data-next]', form), submit = $('[data-submit]', form);
    const result = $('#form-result');
    let cur = 0;

    const qs = new URLSearchParams(location.search);
    const norm = s => String(s || '').toLowerCase().replace(/s$/, '');
    const pre = (name, val) => { if (!val) return; $$(`[name="${name}"]`, form).forEach(i => { if (norm(i.value) === norm(val) || (i.dataset.key && i.dataset.key === val)) i.checked = true; }); };
    pre('category', qs.get('category'));
    pre('services', qs.get('service'));
    if (qs.get('package')) { const sel = $('[name="package"]', form); if (sel) sel.value = qs.get('package'); }

    const showStep = n => {
      cur = n;
      steps.forEach((s, k) => s.classList.toggle('on', k === n));
      ind.forEach((li, k) => { li.classList.toggle('on', k === n); li.classList.toggle('done', k < n); });
      prev.hidden = n === 0; next.hidden = n === steps.length - 1; submit.hidden = n !== steps.length - 1;
      if (n === steps.length - 1) buildReview();
      const top = form.parentElement.getBoundingClientRect().top + scrollY - 110;
      if (scrollY > top) scrollTo({ top, behavior: reduce ? 'auto' : 'smooth' });
    };
    const setErr = (field, msg) => { field.classList.toggle('invalid', !!msg); const e = $('.err', field); if (e) e.textContent = msg || ''; };
    const validateStep = n => {
      let ok = true, first = null;
      $$('.field', steps[n]).forEach(f => {
        const inp = $('input, select, textarea', f);
        let msg = '';
        if (f.hasAttribute('data-group')) { if (f.hasAttribute('data-required') && !$$('input:checked', f).length) msg = 'Please choose at least one option.'; }
        else if (inp && inp.type !== 'file') {
          const v = inp.value.trim();
          if (inp.required && !v) msg = 'This field is required.';
          else if (v && inp.type === 'email' && !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v)) msg = 'Enter a valid email address.';
          else if (v && inp.type === 'tel' && v.replace(/[^\d]/g, '').length < 8) msg = 'Enter a valid phone number.';
          else if (v && inp.name === 'area' && !/^[\d,.\s]+$/.test(v)) msg = 'Use numbers only (square feet).';
        } else if (inp && inp.type === 'file' && [...inp.files].some(x => x.size > 10 * 1024 * 1024)) msg = 'Each file must be under 10 MB.';
        setErr(f, msg);
        if (msg) { ok = false; if (!first) first = f; }
      });
      if (n === steps.length - 1) {
        const c = $('[name="consent"]', form);
        if (c && !c.checked) { ok = false; c.closest('.consent').style.color = '#A0412D'; first = first || c; } else if (c) c.closest('.consent').style.color = '';
      }
      if (first) ($('input, select, textarea', first) || first).focus();
      return ok;
    };
    $$('input, select, textarea', form).forEach(i => i.addEventListener('input', () => { const f = i.closest('.field'); if (f && f.classList.contains('invalid')) setErr(f, ''); }));
    next.addEventListener('click', () => { if (validateStep(cur)) showStep(cur + 1); });
    prev.addEventListener('click', () => showStep(cur - 1));

    const drop = $('.drop', form), fileIn = $('input[type="file"]', form), list = $('.file-list', form);
    if (drop && fileIn) {
      const renderFiles = () => { list.innerHTML = [...fileIn.files].map(f => `<span>${esc(f.name)} · ${(f.size / 1024 / 1024).toFixed(1)} MB</span>`).join(''); };
      fileIn.addEventListener('change', renderFiles);
      ['dragenter', 'dragover'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.add('over'); }));
      ['dragleave', 'drop'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.remove('over'); }));
      drop.addEventListener('drop', e => { if (e.dataTransfer.files.length) { fileIn.files = e.dataTransfer.files; renderFiles(); } });
    }
    const data = () => {
      const fd = new FormData(form);
      const get = k => (fd.getAll(k).filter(Boolean).join(', ') || '—');
      const pkgSel = $('[name="package"]', form);
      const pkgText = pkgSel && pkgSel.value ? pkgSel.options[pkgSel.selectedIndex].text : '—';
      return { fd, rows: [['Name', get('name')], ['Company', get('company')], ['Phone', get('phone')], ['Email', get('email')], ['Category', get('category')], ['Location', get('location')], ['Area (sq ft)', get('area')], ['Services', get('services')], ['Package', pkgText], ['Budget', get('budget')], ['Files', [...(fileIn ? fileIn.files : [])].map(f => f.name).join(', ') || '—'], ['Description', get('description')]] };
    };
    const buildReview = () => { const box = $('.review', form); if (box) box.innerHTML = data().rows.map(([k, v]) => `<div><dt>${k}</dt><dd>${esc(v)}</dd></div>`).join(''); };

    form.addEventListener('submit', async e => {
      e.preventDefault();
      if (!validateStep(cur)) return;
      const hp = $('.hp input', form); if (hp && hp.value) return;
      const { fd, rows } = data();
      const text = `New project enquiry — ${CFG.company || 'SUBHA INFRA'} website\n\n` + rows.map(([k, v]) => `${k}: ${v}`).join('\n');
      result.hidden = false; result.className = 'form-result'; result.setAttribute('tabindex', '-1');
      if (!CFG.formEndpoint) {
        const mail = `mailto:${CFG.email}?subject=${encodeURIComponent('Project enquiry — ' + (fd.get('name') || ''))}&body=${encodeURIComponent(text)}`;
        result.innerHTML = `<h3>Your enquiry is ready to send</h3><p>Online submission is not connected on this website yet, so nothing has been sent. Choose how you would like to send your enquiry — the details you entered are already filled in.${fileIn && fileIn.files.length ? ' Please attach your drawings to the email before sending.' : ''}</p><div class="actions"><a class="btn btn-bronze" href="${mail}">Send by email</a><a class="btn btn-line" href="${waLink(text)}" target="_blank" rel="noopener">Send on WhatsApp</a></div>`;
        result.focus(); return;
      }
      submit.disabled = true; submit.querySelector('span').textContent = 'Sending…';
      try {
        const res = await fetch(CFG.formEndpoint, { method: 'POST', body: fd, headers: { Accept: 'application/json' } });
        if (!res.ok) throw new Error('HTTP ' + res.status);
        result.classList.add('ok');
        result.innerHTML = '<h3>Thank you — your enquiry has been received.</h3><p>Our team will review your requirements and contact you using the details you provided.</p>';
        form.reset(); steps.forEach(s => s.classList.remove('on')); $('.form-nav', form).hidden = true;
        ind.forEach(li => { li.classList.remove('on'); li.classList.add('done'); });
      } catch (err) {
        result.classList.add('bad');
        result.innerHTML = `<h3>We couldn't send your enquiry</h3><p>Please check your connection and try again, or contact us directly at <a href="mailto:${esc(CFG.email)}">${esc(CFG.email)}</a> or <a href="tel:${esc(CFG.phone)}">${esc(CFG.phoneDisplay)}</a>.</p>`;
      } finally {
        submit.disabled = false; submit.querySelector('span').textContent = 'Submit enquiry';
        result.focus();
      }
    });
    showStep(0);
  }
})();
