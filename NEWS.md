# faperu.analysis (development version)

- `fpa_estimate()` and `fpa_indicator()` return class `fpa_estimate`, and `fpa_link()` class
  `fpa_link`. They are still data frames, but now print as a formatted table with the INEI
  quality band; `summary()` counts estimates per quality band and `plot()` draws each estimate
  with its confidence interval (base graphics, no new dependency).
- A factor used as domain (`by = "stype"`) is named by its levels; it came out as its internal
  codes (1, 2, 3).

# faperu.analysis 0.1.0

First version.

- Needs faperu 0.3.0 or later. Tests that use a local copy of the microdata run only when
  `FAPERU_LOCAL` points to it. Site configuration for pkgdown (`_pkgdown.yml`).
- `fpa_estimate()`: mean, proportion or total by domain (national, department, area, district or
  any column) with standard error, confidence interval, coefficient of variation and the INEI
  quality band (`fpa_quality()`).
- `fpa_indicator()` and `fpa_indicators()`: monetary and extreme poverty (ENAHO), open
  unemployment and informal employment (EPEN), anaemia in children 6-35 months under both
  criteria (ENDES) and women among agricultural producers (ENA). The 2024 values match the
  figures published by INEI.
- `fpa_link()`: joins estimates of several surveys by department or by district on the 2017
  Census frame, with warnings for multi-parent districts and low precision.
- `fpa_map()` and `fpa_geometry()`: choropleth maps on the INEI boundaries, cached outside the
  package.
- `fpa_table()`: table for a paper as a data frame, markdown or LaTeX.
