#!/bin/bash
set -euo pipefail

if [[ -z "${WM_PROJECT_VERSION:-}" || "$WM_PROJECT_VERSION" != "13" ]]; then
    echo "ERROR: OpenFOAM 13 environment is required."
    echo "  source /opt/openfoam13/etc/bashrc"
    exit 1
fi

case_dir="$(cd "$(dirname "$0")" && pwd)"
cd "$case_dir"

rm -rf constant/polyMesh constant/box/polyMesh constant/heatSink/polyMesh
rm -rf constant/heatSource/polyMesh constant/basis/polyMesh 0
rm -f log.ideasUnvToFoam log.transformPoints log.splitMeshRegions
rm -f log.changeDictionary log.checkMesh log.foamMultiRun.of13
find . -maxdepth 1 -name '[0-9]*.[0-9]*' -type d -exec rm -rf {} + 2>/dev/null || true
find . -maxdepth 1 -name '[1-9]*' -type d -exec rm -rf {} + 2>/dev/null || true

ideasUnvToFoam Mesh_1.unv 2>&1 | tee log.ideasUnvToFoam
transformPoints "scale=(0.001 0.001 0.001)" 2>&1 | tee log.transformPoints
splitMeshRegions -cellZones 2>&1 | tee log.splitMeshRegions
cp -r 0.orig/. 0/
for region in box heatSink heatSource basis; do
    changeDictionary -region "$region"
done 2>&1 | tee log.changeDictionary
for region in box heatSink heatSource basis; do
    checkMesh -region "$region"
done 2>&1 | tee log.checkMesh

echo "Setup complete. Run:"
echo "  foamMultiRun 2>&1 | tee log.foamMultiRun.of13"
