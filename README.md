# grace2pexa

The **GRACE 2.0 one-year models** as a ModelsCloud service: the risk of death,
and of death or myocardial infarction, within one year of presenting with an
acute coronary syndrome.

Fox KAA, FitzGerald G, Puymirat E, et al. Should patients with acute coronary
disease be stratified for management according to their risk? Derivation,
external validation and outcomes using the updated GRACE risk score.
*BMJ Open.* 2014;4:e004425.
[doi:10.1136/bmjopen-2013-004425](https://doi.org/10.1136/bmjopen-2013-004425)

## Which version and source

The BMJ Open paper describes the method but does not print the coefficients.
They come from the **GRACE Risk Score V2 coefficient sheets (02/06/2017)**,
sections 1A (1-year death/MI) and 1B (1-year death). The sheets are reproduced
in Supplementary Appendix 1 of Hara H, et al., *EuroIntervention*
2022;17:1362–1364
([doi:10.4244/EIJ-D-21-00536](https://doi.org/10.4244/EIJ-D-21-00536)).

The sheets carry this request, which is honoured here:

> Please acknowledge use of this royalty-free material as follows:
> ©2012-2017 Center for Outcomes Research – University of Massachusetts Medical
> School

The model keeps all the non-linear terms and scaling from the sheets: age per
10 years, systolic BP per −20 mmHg and pulse per 30 bpm, each with restricted
cubic splines, and creatinine in mg/dL with a spline. Risk = 1 − S₀(365)^exp(xβ),
with S₀ = 0.9983577131 (death) and 0.9865696068 (death/MI).

Not included: other horizons (in-hospital, 6 months, 3 years), the versions
that substitute for missing creatinine or Killip class, and the older GRACE
point scores.

## Inputs

| Field | Coding |
|---|---|
| `age` | years |
| `heart_rate` | beats per minute |
| `sbp` | systolic BP, mmHg |
| `creatinine` | mg/dL (or `creatinine_units = "umol/L"`, divided by 88.4) |
| `killip` | Killip class 1–4 |
| `cardiac_arrest` | yes / no: cardiac arrest at admission |
| `positive_enzymes` | yes / no: positive initial cardiac enzymes |
| `st_deviation` | yes / no: ST-segment deviation |

Returns `risk_death_1y` and `risk_death_mi_1y` (0–1).

## Validation

- Reproduces the four worked checks printed on the authors' sheets: death/MI
  .34 and .07, death .28 and .02. These are shown to only 2 decimals, and
  both patients are Killip I without cardiac arrest.
- Every categorical coefficient matches the hazard ratio printed beside it,
  within 2-decimal rounding.
- No independent GRACE 2.0 one-year calculator could be used for further
  checks. MDCalc's GRACE calculator is the older 6-month version, and QxMD
  requires agreeing to its terms of use.

## Source and reuse

The BMJ Open article is CC BY-NC 3.0. The coefficient sheets are royalty-free
material from the University of Massachusetts Medical School, acknowledged
above. The EuroIntervention article that reproduces them is copyrighted by
Europa Digital & Publishing; only the published coefficients are used here.

## Use

```r
remotes::install_git("https://github.com/raminrzn/grace2pexa", ref = "main")
grace2pexa::model_run(grace2pexa::get_default_input())
```

For research use. Not a medical device.

## License

GPL-3 for this code.
