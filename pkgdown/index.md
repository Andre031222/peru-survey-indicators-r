# faperu.analysis <img src="man/figures/logo.png" align="right" height="190" alt="faperu.analysis" />

**Indicadores oficiales del Perú, estimados con su diseño muestral.**
*Peru's official indicators, estimated with their survey design.*

faperu.analysis convierte los datos de [faperu](https://andre031222.github.io/peru-official-surveys-r/)
en cifras como las que publica el INEI: con su error estándar, su intervalo de confianza, su
coeficiente de variación y la banda de calidad del INEI. Trae siete indicadores listos que dan las
cifras oficiales de 2024, une encuestas por distrito y hace tablas y mapas.

## Las cifras de 2024, reproducidas

<div class="an-kpis">
<div class="an-kpi" style="--c: var(--an-1)"><span class="v" data-n="27.58" data-d="2">27,58</span><span class="l">Pobreza monetaria (%)</span><span class="s">ENAHO · INEI: 27,6</span></div>
<div class="an-kpi" style="--c: var(--an-5)"><span class="v" data-n="35.33" data-d="2">35,33</span><span class="l">Anemia 6 a 35 meses (%)</span><span class="s">ENDES · INEI: 35,3</span></div>
<div class="an-kpi" style="--c: var(--an-2)"><span class="v" data-n="5.57" data-d="2">5,57</span><span class="l">Desempleo abierto (%)</span><span class="s">EPEN · INEI: 5,6</span></div>
<div class="an-kpi" style="--c: var(--an-4)"><span class="v" data-n="31.46" data-d="2">31,46</span><span class="l">Mujeres productoras (%)</span><span class="s">ENA · INEI: 31,5</span></div>
</div>

Los siete indicadores, con sus fuentes oficiales, están en la
[galería](articles/galeria.html).

## Un ejemplo

```r
library(faperu.analysis)
p <- fpa_indicator("pobreza_monetaria", 2024, by = "department")
p              # tabla con estimación, intervalo, CV y calidad
fpa_map(p)     # mapa con los límites del INEI
```

<p style="text-align:center"><img src="img/map_poverty.png" alt="Pobreza monetaria 2024 por departamento" style="max-height:420px"></p>

## La calidad, como la mide el INEI

El INEI califica cada estimación por su coeficiente de variación (CV). faperu.analysis agrega esa
columna a cada resultado, la marca en las tablas y avisa cuando se cruzan cifras poco precisas.

| Banda | CV | Qué significa |
|---|---|---|
| <span class="q" style="background:#0d9488"></span>Muy buena | menos de 5 % | Se publica sin reservas |
| <span class="q" style="background:#2563eb"></span>Buena | 5 % a 10 % | Confiable |
| <span class="q" style="background:#d97706"></span>Aceptable | 10 % a 15 % | Usar con cuidado |
| <span class="q" style="background:#e11d48"></span>Referencial | más de 15 % | Solo como referencia |

## Instalar

```r
install.packages("remotes")
remotes::install_github("Andre031222/peru-survey-indicators-r")
```

Instala también faperu, que trae los datos. Cuando esté en CRAN bastará
`install.packages("faperu.analysis")`. ¿Primera vez con R? Mira
[Instalar paso a paso](articles/instalar.html).

faperu.analysis es independiente y no está afiliado al INEI.

*faperu.analysis estimates means, proportions and totals with standard errors and INEI quality
bands, ships seven indicators that match INEI's official 2024 figures, links surveys and draws maps.*
