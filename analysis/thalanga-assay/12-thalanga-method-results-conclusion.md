# Thalanga Assay Analysis — Method, Results, and Conclusion

## Method (following user-published RPubs workflow)
- Data source: uploaded assay CSV (`assay---...csv`)
- Core variables: `Cu`, `Zn`, plus `Cu_Zn_Ratio = Cu / (Zn + 0.001)`
- Domain thresholds (data-driven):
  - Cu P33 = **10.000**
  - Cu P67 = **21.000**
  - Cu P80 = **38.000**
  - Zn P50 (median) = **44.000**
- Grade domains: Unmineralized / Low / Medium / High / Very High (P33-P67-P80 scheme)
- Final domains (combined method): Cu grade bands + Cu/Zn ratio rules (7 classes)

## Results
- Total rows: **9,331**
- Total holes: **612**

### Grade-domain counts
- Low-Grade: **2,099** (22.49%)
- Medium-Grade: **2,847** (30.51%)
- High-Grade: **1,039** (11.13%)
- Very High-Grade: **1,503** (16.11%)
- Unmineralized: **1,843** (19.75%)

### Final combined-domain counts
- Domain_1_Cu_Core_HighGrade: **224** (2.40%)
- Domain_2_Cu_Core_MedGrade: **62** (0.66%)
- Domain_3_CuZn_Transition: **1,691** (18.12%)
- Domain_4_ZnPb_Cap: **2,936** (31.47%)
- Domain_5_LowGrade_Peripheral: **1,666** (17.85%)
- Domain_6_Unmineralized: **1,843** (19.75%)
- Domain_7_Undefined: **909** (9.74%)

### QC notes
- Duplicate rows by key (`Hole_ID`,`From_Depth`,`To_Depth`,`Sample`): **119**
- Rows with non-zero East/North coordinates: **3,329** (35.68%)
- Implication: geostatistical interpolation/kriging must use coordinate-valid subset + dedup pass.

## Conclusion
The RPubs method is reproducible on the uploaded Thalanga assay dataset and yields stable domain thresholds and interpretable class separation.
Operationally, the dataset is ready for next-stage modeling with two mandatory pre-steps: (1) duplicate handling, and (2) coordinate-valid filtering for spatial estimation.
For estimation workflow, the result is directly compatible with `geosR` pipeline (`fit_var` -> `est_krige` -> `calc_res` -> `ev_rest`).

## Generated files
- `/root/.openclaw/workspace/reports/research/2026-03-09/12-thalanga-method-results-conclusion.md`
- `/root/.openclaw/workspace/reports/research/2026-03-09/12-assay-domain-annotated.csv`
- `/root/.openclaw/workspace/reports/research/2026-03-09/12-domain-summary.csv`