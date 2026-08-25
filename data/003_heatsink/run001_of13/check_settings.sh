#!/bin/bash
set -euo pipefail

if [[ "${WM_PROJECT_VERSION:-}" != "13" ]]; then
    echo "ERROR: OpenFOAM 13 environment is required."
    exit 1
fi

case_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$case_dir"

check_value()
{
    local file="$1"
    local entry="$2"
    local expected="$3"
    local actual

    actual="$(foamDictionary "$file" -entry "$entry" -value)"
    if [[ "${actual//[[:space:]]/}" != "${expected//[[:space:]]/}" ]]; then
        echo "NG: $file:$entry"
        echo "    expected: $expected"
        echo "    actual:   $actual"
        exit 1
    fi
    printf 'OK: %s:%s = %s\n' "$file" "$entry" "$actual"
}

check_value system/controlDict maxCo 100
check_value system/controlDict maxDi 100
check_value system/controlDict maxDeltaT 0.0217
check_value system/controlDict endTime 60
check_value system/controlDict writeInterval 2

check_value constant/box/physicalProperties thermoType/equationOfState perfectGas
check_value constant/box/physicalProperties mixture/specie/molWeight 28.9
check_value constant/box/physicalProperties mixture/thermodynamics/Cp 1000
check_value constant/box/physicalProperties mixture/transport/mu 1.8e-05
check_value constant/box/physicalProperties mixture/transport/Pr 0.7
check_value constant/box/momentumTransport simulationType RAS
check_value constant/box/momentumTransport RAS/model kOmegaSST
check_value constant/box/thermophysicalTransport RAS/Prt 0.85

check_value constant/heatSink/physicalProperties mixture/equationOfState/rho 2700
check_value constant/heatSink/physicalProperties mixture/thermodynamics/Cv 900
check_value constant/heatSink/physicalProperties mixture/transport/kappa 205
for region in heatSource basis; do
    check_value constant/$region/physicalProperties mixture/equationOfState/rho 8000
    check_value constant/$region/physicalProperties mixture/thermodynamics/Cv 450
    check_value constant/$region/physicalProperties mixture/transport/kappa 80
done

check_value 0/box/U boundaryField/YMax/type fixedValue
check_value 0/box/U boundaryField/YMax/value "uniform (0 -0.5 0)"
check_value 0/box/U boundaryField/YMin/type pressureInletOutletVelocity
check_value 0/box/T boundaryField/YMax/type fixedValue
check_value 0/box/k boundaryField/YMax/type turbulentIntensityKineticEnergyInlet
check_value 0/box/k boundaryField/YMax/intensity 0.05
check_value 0/box/omega boundaryField/YMax/type turbulentMixingLengthFrequencyInlet
check_value 0/box/omega boundaryField/YMax/mixingLength 0.007
check_value 0/box/T boundaryField/box_to_heatSink/type coupledTemperature
check_value 0/heatSink/T boundaryField/heatSink_to_box/type coupledTemperature
check_value 0/basis/T boundaryField/Group_1/type zeroGradient

echo "All OpenFOAM 13 settings checks passed."
