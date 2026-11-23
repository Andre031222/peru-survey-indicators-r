# faperu.analysis

**Indicadores oficiales del Perú, estimados con su diseño muestral y cruzados entre encuestas.**

Acompaña a [faperu](../faperu/): faperu trae los datos, faperu.analysis los convierte en cifras con
su error estándar.

> [!NOTE]
> Todavía no tiene código. Esta página es el plan.

## Así se verá

```r
library(faperu.analysis)
x <- fpa_indicator("pobreza_monetaria", 2024, "departamento")
fpa_validate(x)
```

`fpa_indicator()` devuelve la estimación, el error estándar, el coeficiente de variación y una
bandera de precisión. `fpa_validate()` la compara con la cifra publicada por el INEI.

## Funciones previstas

| Función | Qué hará |
|---|---|
| `fpa_indicators()` | Lista de indicadores disponibles, cada uno definido en un YAML |
| `fpa_indicator()` | Estima un indicador por año y nivel geográfico, con su diseño muestral |
| `fpa_precision()` | Marca estimaciones poco confiables según el coeficiente de variación |
| `fpa_link()` | Une varias encuestas por ubigeo y año |
| `fpa_map()` | Mapa por departamento, provincia o distrito |
| `fpa_validate()` | Compara con las series oficiales del INEI |

## Primeros indicadores

| Indicador | Fuente | Control oficial |
|---|---|---|
| Pobreza monetaria | ENAHO | Informe técnico de pobreza del INEI |
| Anemia en niños de 6 a 35 meses | ENDES | Indicadores de resultados de la ENDES |
| Rendimiento lechero por vaca | ENA | Resultados de la ENA |
| Tasa de desempleo | EPEN | Informe técnico de empleo |
| Matrícula por mil habitantes | Censo Educativo + Censos 2017 | ESCALE |

## Orden de trabajo

1. Que `faperu` tenga `fa_read()` y `fa_design()`.
2. Formato YAML de indicadores en `inst/indicators/`.
3. `fpa_indicator()` y `fpa_validate()` con pobreza y anemia.
4. `fpa_link()` y `fpa_map()`.

## Licencia y autoría

MIT. Autores: Richar Andre Vilca Solorzano y Dina Maribel Yana-Yucra.
