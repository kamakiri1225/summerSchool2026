# OpenFOAM 13 settings audit

Reference case:

    data/003_heatsink/run001_of2512

Target case:

    data/003_heatsink/run001_of13

## Matched physical settings

| Item | v2512 reference | OpenFOAM 13 |
|---|---|---|
| Regions | box, heatSink, heatSource, basis | Same |
| Fluid model | Compressible perfect gas | Same |
| Turbulence | RAS kOmegaSST | Same |
| Inlet velocity | (0 -0.5 0) m/s | Same |
| Initial temperature | 293.15 K | Same |
| Initial pressure | 100000 Pa | Same |
| Air molecular weight | 28.9 kg/kmol | Same |
| Air Cp | 1000 J/kg/K | Same |
| Air viscosity | 1.8e-5 kg/m/s | Same |
| Air Pr | 0.7 | Same |
| Turbulent Prandtl number | 0.85 | Same |
| Initial k | 0.001 m2/s2 | Same |
| Initial omega | 10 1/s | Same |
| Inlet turbulence intensity | 0.05 | Same |
| Inlet mixing length | 0.007 m | Same |
| heatSink rho, Cp, kappa | 2700, 900, 205 | Same |
| heatSource rho, Cp, kappa | 8000, 450, 80 | Same |
| basis rho, Cp, kappa | 8000, 450, 80 | Same |
| Heat input | 100 W from 0 to 10 s | Same |
| Radiation | Off | Same; no radiation model is configured in OF13 |

## Matched numerical settings

| Item | v2512 reference | OpenFOAM 13 |
|---|---|---|
| Time scheme | Euler | Same |
| Velocity convection | Gauss upwind | Same |
| Energy convection | Gauss upwind | Same |
| Turbulence convection | Gauss upwind | Same |
| Laplacian correction | limited corrected 0.33 | Same for fluid |
| PIMPLE outer correctors | 1 | Same |
| Pressure correctors | 2 | Same |
| Non-orthogonal correctors | 2 | Same for fluid |
| Start mode | latestTime | Same |
| End time | 60 s | Same |
| Initial deltaT | 0.001 s | Same |
| Write interval | 2 s | Same |
| maxCo | 100 | Same |
| maxDi | 100 | Retained for reference |
| Solid time-step limit | maxDi controls it in v2512 | maxDeltaT 0.0217 s in OF13 |

The OpenFOAM 13 solid module does not read maxDi. The maxDeltaT value was
calculated from the v2512 result:

    100 * 0.0195887 / 90.1563 = 0.0217275 s

## OpenFOAM 13 syntax mappings

| v2512 | OpenFOAM 13 |
|---|---|
| chtMultiRegionFoam | foamMultiRun and regionSolvers |
| thermophysicalProperties | physicalProperties |
| turbulenceProperties | momentumTransport |
| turbulent heat transport in turbulence model | thermophysicalTransport |
| turbulentTemperatureRadCoupledMixed | coupledTemperature |
| fvOptions scalarSemiImplicitSource | fvModels heatSource |
| regionType patch and name | patch |
| solid enthalpy h | solid internal energy e |

The basis exterior patch is named defaultFaces in the v2512 result but remains
Group_1 after the OpenFOAM 13 split. Group_1 is therefore assigned
zeroGradient, which is the same adiabatic condition.

## Validation

- ideasUnvToFoam completed.
- transformPoints completed.
- splitMeshRegions created all four regions.
- changeDictionary applied all region boundary conditions.
- checkMesh returned Mesh OK for all four regions.
- A foamMultiRun validation calculation completed through time 0.0197405 s.
- k, omega, velocity, pressure, fluid enthalpy and all solid energy equations
  were solved.
- The heat-flux and area-average diagnostic function objects executed.
- No OpenFOAM fatal error occurred in the final validation run.

Run the repeatable settings check after setup:

    bash check_settings.sh

## Checked implementation differences

- The v2512 solid fields contain p because that solver implementation requires
  it. The OpenFOAM 13 solid module solves internal energy e and temperature T
  and does not require a solid pressure field.
- The v2512 radiationProperties dictionaries explicitly select radiation off.
  OpenFOAM 13 has no radiation model configured, which is the equivalent state.
- The custom v2512 solidDiffNo coded function object reads
  thermophysicalProperties and uses the v2512 API. It is not copied. The same
  time-step restriction is implemented with maxDeltaT 0.0217.
- The built-in CourantNo, wallHeatFlux, surfaceFieldValue heat-flux integrals
  and temperature averages were migrated and executed successfully.
