# Comparative Spatial Grade Modeling at Thalanga: Kriging vs PINN-Inspired Neural Model

## Abstract
This study evaluates spatial grade modeling on the Thalanga assay dataset using two approaches: Ordinary Kriging 3D and a PINN-inspired neural model with smoothness regularization. A reproducible preprocessing and domaining workflow was applied on 9,331 assay records. Results show that both models are feasible, while Ordinary Kriging performed better on held-out validation in this run (RMSE 10.521 vs 10.833). The manuscript provides a full method, figures, and deployment-ready outputs for repository integration.

## 1. Introduction
Accurate spatial grade estimation is central to resource modeling. Classical geostatistics (kriging) is robust but may be limited under sparse/non-stationary structures. Neural models can capture nonlinear interactions, and PINN-style constraints can inject physically plausible smoothness. This work benchmarks both approaches on real Thalanga data.

## 2. Data and Study Setup
- Dataset: `assay---...csv` (uploaded by user)
- Records: 9,331 samples; 612 holes
- Key variables: East, North, From_Depth, To_Depth, Cu, Zn
- Derived variables:
  - `mid_depth = (From_Depth + To_Depth)/2`
  - `Cu_Zn_Ratio = Cu/(Zn+0.001)`

### 2.1 Data quality checks
- Duplicate rows (Hole_ID + From_Depth + To_Depth + Sample): 119
- Non-zero coordinate rows: 3,329 (used as spatially valid subset)

## 3. Methods

### 3.1 RPubs-consistent domaining workflow
Using percentile cutoffs from real data:
- Cu P33 = 10
- Cu P67 = 21
- Cu P80 = 38
- Zn P50 = 44

Grade and combined domains were generated to support downstream geostatistics and model interpretation.

### 3.2 Ordinary Kriging 3D
- Model: spherical variogram, OrdinaryKriging3D
- Inputs: East, North, mid_depth
- Target: Cu
- Train/test split from coordinate-valid subset

### 3.3 PINN-inspired neural model
A neural regressor was trained with:
- Data term: MSE(pred, observed)
- Physics-inspired term: smoothness (Laplacian penalty, ∇²f ≈ 0)
- Total loss: `MSE + 0.01 * mean(Laplacian²)`

This enforces physically smoother fields while preserving data fit.

### 3.4 Evaluation metrics
- MAE
- RMSE
- R²

## 4. Results

### 4.1 Domaining results
- Grade-domain and final-domain outputs generated in CSV form.
- Domain proportions are consistent with VMS-style mixed Cu-Zn population.

### 4.2 Kriging vs PINN comparison
Validation metrics:

| Model | MAE | RMSE | R² |
|---|---:|---:|---:|
| OrdinaryKriging3D | 7.342 | 10.521 | 0.136 |
| PINN_SmoothNN | 7.632 | 10.833 | 0.083 |

Key observation:
- Kriging outperformed the current PINN configuration on this split.
- PINN remains promising but likely needs stronger physics constraints, hyperparameter tuning, and domain-specific boundary conditions.

## 5. Discussion
Kriging is currently the more stable baseline for immediate resource workflow. PINN-style modeling should be iterated with:
1. Domain-wise training (not pooled),
2. Explicit geological constraints (fault/contact boundaries),
3. Uncertainty-aware objective and calibration.

## 6. Conclusion
The full workflow has been executed on real Thalanga data with reproducible outputs and figures. Kriging currently performs better than the first PINN-inspired run; therefore, Kriging should be used as production baseline while PINN is advanced as an R&D stream.

## 7. Figures (generated from real analysis)
1. `12-fig1-cu-distribution.png`
2. `12-fig2-final-domain-counts.png`
3. `12-fig3-cu-vs-zn-by-domain.png`
4. `12-fig4-depth-median-cu.png`
5. `12-fig5-kriging-vs-pinn-parity.png`

## 8. Reproducible outputs
- `12-assay-domain-annotated.csv`
- `12-domain-summary.csv`
- `12-kriging-vs-pinn-metrics.csv`
- `12-thalanga-method-results-conclusion.md`
