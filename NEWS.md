# faperu.analysis 0.1.0

First version.

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
