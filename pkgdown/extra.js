// One button switches the theme. Until someone presses it the site follows
// the system (light or dark); after that it remembers the choice. Uses the
// same storage key as pkgdown's lightswitch.js, which sets the theme before
// the page is painted, so there is no flash when moving between pages.
document.addEventListener("DOMContentLoaded", function () {
  var root = document.documentElement;
  var btn = document.querySelector('.navbar a[href="#theme"]');
  if (btn) {
    btn.setAttribute("role", "button");
    btn.setAttribute("title", "Cambiar tema");
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      var next = root.getAttribute("data-bs-theme") === "dark" ? "light" : "dark";
      var apply = function () {
        root.setAttribute("data-bs-theme", next);
        try { localStorage.setItem("theme", next); } catch (err) {}
      };
      if (document.startViewTransition && !matchMedia("(prefers-reduced-motion: reduce)").matches) {
        document.startViewTransition(apply);
      } else {
        apply();
      }
    });
  }
});

// Cards, tables and figures fade in the first time they scroll into view;
// the numbers on the KPI cards count up once.
document.addEventListener("DOMContentLoaded", function () {
  if (!("IntersectionObserver" in window)) return;
  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (!e.isIntersecting) return;
      e.target.classList.add("an-in");
      var v = e.target.querySelector && e.target.querySelector(".v[data-n]");
      if (v) count(v);
      io.unobserve(e.target);
    });
  });
  // Only what starts below the fold fades in; what is already on screen
  // stays visible, and its numbers count up right away.
  document.querySelectorAll("main .an-kpi, main table, main img, main h2").forEach(function (el) {
    if (el.getBoundingClientRect().top < window.innerHeight) {
      var v = el.querySelector && el.querySelector(".v[data-n]");
      if (v) count(v);
      return;
    }
    el.classList.add("an-reveal"); io.observe(el);
  });
  function count(el) {
    var end = parseFloat(el.dataset.n), d = parseInt(el.dataset.d || "1", 10), t0 = null;
    function step(t) {
      if (!t0) t0 = t;
      var k = Math.min(1, (t - t0) / 900);
      el.firstChild.nodeValue = (end * (1 - Math.pow(1 - k, 3))).toFixed(d).replace(".", ",");
      if (k < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  }
});
