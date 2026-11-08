/* =====================================================================
   SUBHA INFRA — SITE CONFIGURATION
   ---------------------------------------------------------------------
   Edit this one file to change contact details, social links, team
   members and calculator rates across the whole website.
   No rebuild is needed: save the file and refresh the browser.

   Rules:
   - Keep the quotes around text values.
   - Leave a social link as '' (empty) to hide that icon everywhere.
   - A rate of 0 shows "On enquiry" instead of a price.
   ===================================================================== */
window.SITE_CONFIG = {

  /* ---------- Contact ---------- */
  company: 'SUBHA INFRA',
  phone: '+91 9844334488',            // used for tel: links (no spaces)
  phoneDisplay: '+91 9844334488',   // how the number is shown on the page
  whatsapp: '+91 9844334488',          // country code + number, digits only
  whatsappMessage: "Hello SUBHA INFRA, I'd like to discuss a project.",
  email: 'info@subhainfra.com',
  address: 'Sahakar Nagar, Bengaluru, Karnataka, India',
  mapQuery: 'Sahakar Nagar, Bengaluru, Karnataka',   // Google Maps search text
  website: 'localhost:9090',

  /* ---------- Social profiles ----------
     PLACEHOLDERS: replace each with the full URL of your own profile. */
  social: {
    linkedin:  'https://www.linkedin.com/',
    instagram: 'https://www.instagram.com/',
    facebook:  'https://www.facebook.com/',
    youtube:   'https://www.youtube.com/',
    twitter:   'https://x.com/'
  },

  /* ---------- Enquiry form ----------
     Paste a form-service endpoint (Formspree, Getform, Basin or your CRM
     webhook) to receive enquiries online. While empty, the form prepares
     the enquiry for the visitor to send by email or WhatsApp. */
  formEndpoint: '',

  /* ---------- Image CMS (Google Apps Script) ----------
     Paste the Apps Script web app URL (ends in /exec) to load images
     chosen in the admin panel. While empty, the built-in images show.
     cmsCacheMinutes: how long a visitor's browser keeps the image list
     before checking for newly published changes. */
  cmsApi: 'https://script.google.com/macros/s/AKfycby_T8CrvB89uXSqAU-mfbmil0Kem_LIbFU5hbdBg9HbWqTSQXhG38OrUz3kb1AIY5KCHg/exec',
  cmsCacheMinutes: 0,

  /* ---------- Homepage hero ---------- */
  heroInterval: 3000,   // milliseconds between hero images

  /* ---------- Team page ----------
     photo: path to an image (e.g. 'assets/images/team/member-01.jpg').
     Leave photo as '' to show the "photo coming soon" placeholder. */
  team: [
    { name: 'Team Member', role: 'Principal Architect', photo: '' },
    { name: 'Team Member', role: 'Structural Engineer', photo: '' },
    { name: 'Team Member', role: 'Project Manager', photo: '' },
    { name: 'Team Member', role: 'PEB & Steel Design Lead', photo: '' },
    { name: 'Team Member', role: 'Interior Designer', photo: '' },
    { name: 'Team Member', role: 'Site Engineer', photo: '' }
  ],
  groupPhoto: '',       // e.g. 'assets/images/team/group-photo.jpg'

  /* ---------- Package rates & estimation calculator ----------
     PLACEHOLDER RATES — replace with SUBHA INFRA's current rates (₹).
     Rates are exclusive of GST unless you change gstPercent to 0. */
  gstPercent: 18,
  rates: {
    residential: { essential: 2450, premium: 2750, signature: 3450 },   // ₹ per sq ft built-up
    commercial:  { core: 2350, standard: 2850, premium: 3600 },         // ₹ per sq ft built-up
    peb:         { basic: 650, standard: 900, premium: 1250 },           // ₹ per sq ft plan area
    tensile:     { shade: 450, canopy: 900, signature: 1250 },           // ₹ per sq ft covered area
    design:      { concept: 40, construction: 80, complete: 120 },       // ₹ per sq ft built-up
    extras: {
      sump: 30,            // ₹ per litre, RCC water sump
      septic: 30,          // ₹ per litre, septic tank
      compoundWall: 425,   // ₹ per sq ft of wall face
      pufRoofing: 250,     // ₹ per sq ft, 50 mm PUF sheet roofing / replacement
      skylight: 150,       // ₹ per sq ft, 2 mm polycarbonate skylight
      msStructure: 600     // ₹ per sq ft, MS support structure (e.g. creeper frames)
    }
  }
};
