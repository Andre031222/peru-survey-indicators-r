# faperu.analysis

**Indicadores oficiales del Perú, estimados con su diseño muestral y cruzados entre encuestas.**
*Peru's official indicators, estimated with their survey design and linked across surveys.*

Acompaña a [faperu](https://github.com/Andre031222/faperu): faperu trae los datos y arma el
diseño; faperu.analysis los convierte en cifras con su error estándar, tablas y mapas. Depende
solo de `faperu` y `survey`; `sf` y `ggplot2` son opcionales, para los mapas.

> [!NOTE]
> **English** — faperu.analysis estimates means, proportions and totals with standard errors,
> confidence intervals, coefficients of variation and INEI's quality bands; ships ready
> indicators checked against INEI's published 2024 figures; links estimates from different
> surveys by department or district (2017 Census frame); and draws maps on INEI's boundaries.
> Independent package, not affiliated with INEI. Function docs are in English.

## Empezar / Get started

```r
remotes::install_github("Andre031222/faperu")
remotes::install_github("Andre031222/faperu.analysis")

library(faperu.analysis)
p <- fpa_indicator("pobreza_monetaria", 2024, by = "department")
fpa_table(p)
fpa_map(p, title = "Pobreza monetaria 2024")
```

La primera vez baja la Sumaria de la ENAHO 2024 y los límites departamentales del INEI a la caché
de faperu. *The first run downloads ENAHO 2024 and INEI's department boundaries to faperu's cache.*

## Funciones / Functions

| Función | Qué hace | What it does |
|---|---|---|
| `fpa_estimate(diseño, "var", type, by)` | Media, proporción o total con EE, IC, CV y calidad | Mean, proportion or total with SE, CI, CV and quality |
| `fpa_quality(cv)` | Banda de calidad del INEI según el CV | INEI quality band from the CV |
| `fpa_indicators()` | Indicadores listos y su fuente oficial | Ready indicators and their official source |
| `fpa_indicator("desempleo", 2024, by = "area")` | Calcula un indicador listo | Computes a ready indicator |
| `fpa_link(a = x, b = y)` | Une encuestas por departamento o distrito y año | Links surveys by department or district and year |
| `fpa_geometry("district")` | Límites del INEI, en caché | INEI boundaries, cached |
| `fpa_map(x, "estimate")` | Mapa coroplético | Choropleth map |
| `fpa_table(x, format = "latex")` | Tabla para el artículo | Table for the paper |

## Calidad de la estimación / Precision

El INEI califica cada estimación por su coeficiente de variación: menos de 5 % muy buena, de 5 % a
10 % buena, de 10 % a 15 % aceptable y más de 15 % referencial. `fpa_estimate()` agrega esa
columna, `fpa_link()` avisa cuando cruza cifras referenciales y `fpa_table()` las marca con un
asterisco.

## Indicadores verificados / Checked indicators

| Indicador | Encuesta | INEI 2024 | faperu.analysis |
|---|---|---|---|
| `pobreza_monetaria` (urbana, rural) | ENAHO | 27,6 (24,8; 39,3) | 27,58 (24,81; 39,30) |
| `pobreza_extrema` | ENAHO | 5,5 | 5,50 |
| `desempleo` | EPEN | 5,6 | 5,57 |
| `informalidad` | EPEN | 70,9 | 70,95 |
| `anemia_6_35`, OMS 2024 (urbana, rural) | ENDES | 35,3 (31,2; 44,7) | 35,33 (31,23; 44,65) |
| `anemia_6_35_rm363`, RM 363-2022 (urbana, rural) | ENDES | 43,7 (40,2; 51,9) | 43,74 (40,17; 51,85) |
| `mujeres_productoras` | ENA | 31,5 | 31,46 |

Las fuentes están en `fpa_indicators()$source` y las pruebas repiten estas comparaciones cuando
los archivos están en disco (`FAPERU_LOCAL`). El rendimiento lechero de la ENA no está: el INEI no
publica una cifra de la ENA con la cual contrastarlo (las de MIDAGRI son registros
administrativos).

## Mapas / Maps

Los límites vienen de la Infraestructura de Datos Espaciales del INEI
([ide.inei.gob.pe](https://ide.inei.gob.pe/), capas `ig_departamento` e `ig_distrito`, servicio
WFS). Se bajan una vez a `fa_cache()/GEO` y no forman parte del paquete. Con
`level = "district", base = 2017` los distritos actuales se funden en el marco del Censo 2017,
el mismo que usa `fpa_link()`.

## Guía / Vignette

`vignette("faperu.analysis")`: pobreza por departamento (ENAHO 2024) cruzada con mujeres
productoras (ENA 2024), tabla y mapas.

## Pruebas / Tests

```sh
Rscript -e 'devtools::test()'
FAPERU_LOCAL=/ruta/a/microdatos Rscript -e 'devtools::test()'   # con las cifras oficiales
FPA_ONLINE=1 Rscript -e 'devtools::test()'                       # y el geoserver del INEI
```

## Licencia / License

MIT. Los microdatos y los límites son del INEI y no se redistribuyen.
*Microdata and boundaries belong to INEI and are not redistributed.*
