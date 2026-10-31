(function () {
  "use strict";
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };
  var root = document.documentElement;

  /* Theme */
  var toggle = $("#theme-toggle");
  if (toggle) toggle.addEventListener("click", function () {
    var next = root.dataset.theme === "dark" ? "light" : "dark";
    root.dataset.theme = next;
    try { localStorage.setItem("theme", next); } catch (e) {}
  });

  /* Header: shadow on scroll + reading progress */
  var header = $("#site-header"), bar = $("#progress"), content = $("#content");
  var isPost = document.body.classList.contains("section-posts") && document.body.classList.contains("kind-page");
  function onScroll() {
    var y = window.scrollY;
    header.classList.toggle("scrolled", y > 8);
    if (isPost && content && bar) {
      var top = content.offsetTop, h = content.offsetHeight - window.innerHeight * 0.4;
      var p = Math.min(1, Math.max(0, (y - top + 120) / Math.max(h, 1)));
      bar.classList.toggle("on", y > 120);
      bar.style.transform = "scaleX(" + p + ")";
    }
  }
  window.addEventListener("scroll", onScroll, { passive: true });
  onScroll();

  /* Mobile menu */
  var menuBtn = $("#menu-toggle"), links = $("#nav-links");
  if (menuBtn) {
    menuBtn.addEventListener("click", function () {
      var open = menuBtn.getAttribute("aria-expanded") !== "true";
      menuBtn.setAttribute("aria-expanded", open);
      links.classList.toggle("open", open);
    });
    links.addEventListener("click", function (e) { if (e.target.closest("a")) { menuBtn.setAttribute("aria-expanded", "false"); links.classList.remove("open"); } });
  }

  /* Reveal on scroll */
  var rev = $$(".reveal");
  if ("IntersectionObserver" in window && rev.length) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) { if (en.isIntersecting) { en.target.classList.add("in"); io.unobserve(en.target); } });
    }, { rootMargin: "0px 0px -8% 0px", threshold: 0.05 });
    rev.forEach(function (el) { io.observe(el); });
  } else { rev.forEach(function (el) { el.classList.add("in"); }); }

  /* Topic filter */
  var filters = $("#filters");
  if (filters) {
    var cards = $$("#card-grid .card"), empty = $("#empty");
    filters.addEventListener("click", function (e) {
      var b = e.target.closest(".filter"); if (!b) return;
      $$(".filter", filters).forEach(function (x) { x.classList.toggle("active", x === b); });
      var f = b.dataset.filter, shown = 0;
      cards.forEach(function (c) {
        var ok = f === "*" || (c.dataset.cats || "").split("|").indexOf(f) > -1;
        c.hidden = !ok; if (ok) shown++;
      });
      empty.hidden = shown > 0;
    });
  }

  /* Article enhancements */
  if (content) {
    /* Copy buttons */
    $$("pre", content).forEach(function (pre) {
      var host = pre.parentElement.classList.contains("highlight") ? pre.parentElement : pre;
      var btn = document.createElement("button");
      btn.type = "button"; btn.className = "copy-btn"; btn.textContent = "Copy";
      btn.addEventListener("click", function () {
        var text = pre.innerText.replace(/\n$/, "");
        var done = function () { btn.textContent = "Copied"; btn.classList.add("done"); setTimeout(function () { btn.textContent = "Copy"; btn.classList.remove("done"); }, 1600); };
        if (navigator.clipboard) navigator.clipboard.writeText(text).then(done);
      });
      var wrap = document.createElement("div"); wrap.className = "code-wrap";
      host.parentNode.insertBefore(wrap, host); wrap.appendChild(host); wrap.appendChild(btn);
    });

    /* Lightbox */
    content.addEventListener("click", function (e) {
      var img = e.target.closest("img"); if (!img) return;
      var a = img.closest("a"); if (a) e.preventDefault();
      var lb = document.createElement("div"); lb.className = "lightbox"; lb.setAttribute("role", "dialog");
      var big = document.createElement("img"); big.src = (a && /\.(png|jpe?g|webp|gif)$/i.test(a.href)) ? a.href : img.currentSrc || img.src; big.alt = img.alt;
      lb.appendChild(big); document.body.appendChild(lb);
      var close = function () { lb.remove(); document.removeEventListener("keydown", esc); };
      var esc = function (ev) { if (ev.key === "Escape") close(); };
      lb.addEventListener("click", close); document.addEventListener("keydown", esc);
    });

    /* TOC: open on desktop + scrollspy */
    var toc = $("#toc");
    if (toc) {
      var mq = window.matchMedia("(min-width: 1100px)");
      var sync = function () { toc.open = mq.matches; };
      sync(); (mq.addEventListener ? mq.addEventListener("change", sync) : mq.addListener(sync));
      var tlinks = $$("a", toc), map = {};
      tlinks.forEach(function (a) { map[decodeURIComponent(a.hash.slice(1))] = a; });
      var heads = $$("h2[id], h3[id]", content);
      if ("IntersectionObserver" in window && heads.length) {
        var current;
        var so = new IntersectionObserver(function (entries) {
          entries.forEach(function (en) {
            if (en.isIntersecting && map[en.target.id]) {
              if (current) current.classList.remove("active");
              current = map[en.target.id]; current.classList.add("active");
            }
          });
        }, { rootMargin: "-80px 0px -70% 0px" });
        heads.forEach(function (h) { so.observe(h); });
      }
    }
  }

  /* Copy link */
  $$("[data-copy-link]").forEach(function (b) {
    b.addEventListener("click", function () {
      if (navigator.clipboard) navigator.clipboard.writeText(b.dataset.copyLink).then(function () { b.style.color = "var(--c3)"; setTimeout(function () { b.style.color = ""; }, 1400); });
    });
  });

  /* Search */
  var box = $("#search"), input = $("#search-q"), list = $("#search-results");
  var index = null, sel = -1, shown = [], lastFocus;
  var meta = $('meta[name="search-index"]');
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function load() {
    if (index || !meta) return Promise.resolve();
    return fetch(meta.content).then(function (r) { return r.json(); }).then(function (d) { index = d; });
  }
  function openSearch() {
    lastFocus = document.activeElement;
    box.hidden = false; document.body.style.overflow = "hidden";
    input.value = ""; render(""); input.focus(); load().then(function () { render(input.value); });
  }
  function closeSearch() { box.hidden = true; document.body.style.overflow = ""; if (lastFocus) lastFocus.focus(); }
  function hl(text, terms) {
    var out = esc(text);
    terms.forEach(function (t) { if (t.length > 1) out = out.replace(new RegExp("(" + t.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "ig"), "<mark>$1</mark>"); });
    return out;
  }
  function render(q) {
    var terms = q.toLowerCase().split(/\s+/).filter(Boolean);
    var items = index || [];
    if (terms.length) {
      items = items.map(function (p) {
        var t = (p.t || "").toLowerCase(), d = (p.d || "").toLowerCase(), c = ((p.c || []).concat(p.g || [])).join(" ").toLowerCase(), x = (p.x || "").toLowerCase(), s = 0;
        for (var i = 0; i < terms.length; i++) {
          var w = terms[i], hit = 0;
          if (t.indexOf(w) > -1) hit += 10;
          if (c.indexOf(w) > -1) hit += 6;
          if (d.indexOf(w) > -1) hit += 4;
          if (x.indexOf(w) > -1) hit += 1;
          if (!hit) return null;
          s += hit;
        }
        return { p: p, s: s };
      }).filter(Boolean).sort(function (a, b) { return b.s - a.s; }).map(function (o) { return o.p; });
    }
    shown = items.slice(0, 8); sel = shown.length ? 0 : -1;
    if (!shown.length) { list.innerHTML = '<li class="none">' + (index ? "No guides found for “" + esc(q) + "”." : "Loading…") + "</li>"; return; }
    list.innerHTML = shown.map(function (p, i) {
      return '<li><a href="' + p.u + '" class="' + (i === 0 ? "sel" : "") + '" role="option"><span class="r-title">' + hl(p.t, terms) + '</span><span class="r-desc">' + hl(p.d || "", terms) + "</span></a></li>";
    }).join("");
  }
  function move(d) {
    var as = $$("a", list); if (!as.length) return;
    sel = (sel + d + as.length) % as.length;
    as.forEach(function (a, i) { a.classList.toggle("sel", i === sel); });
    as[sel].scrollIntoView({ block: "nearest" });
  }
  if (box) {
    $$("[data-search-open]").forEach(function (b) { b.addEventListener("click", openSearch); });
    $$("[data-search-close]").forEach(function (b) { b.addEventListener("click", closeSearch); });
    input.addEventListener("input", function () { render(input.value); });
    input.addEventListener("keydown", function (e) {
      if (e.key === "ArrowDown") { e.preventDefault(); move(1); }
      else if (e.key === "ArrowUp") { e.preventDefault(); move(-1); }
      else if (e.key === "Enter" && shown[sel]) { window.location.href = shown[sel].u; }
    });
    document.addEventListener("keydown", function (e) {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") { e.preventDefault(); box.hidden ? openSearch() : closeSearch(); }
      else if (e.key === "Escape" && !box.hidden) closeSearch();
      else if (e.key === "/" && box.hidden && !/input|textarea/i.test(document.activeElement.tagName)) { e.preventDefault(); openSearch(); }
    });
  }
})();
