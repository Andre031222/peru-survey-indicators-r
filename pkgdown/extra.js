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
  document.querySelectorAll("main .an-kpi, main table, main img, main h2").forEach(function (el) {
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
