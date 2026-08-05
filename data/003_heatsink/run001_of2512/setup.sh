#!/bin/bash
# setup.sh  ─  Mesh_1.unv からケース設定まで一括実行
# 使い方: bash setup.sh
# ※ Mesh_1.unv を更新した場合も同じスクリプトで再実行可能

# source で実行された場合は警告して中断（set -e が親シェルに波及するため）
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "ERROR: source ではなく bash で実行してください"
    echo "  bash setup.sh"
    return 1
fi

set -e  # エラーで即中断

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ------------------------------------------------------------------
# 0. OpenFOAM 環境チェック
# ------------------------------------------------------------------
if [[ -z "$WM_PROJECT_VERSION" ]]; then
    echo "ERROR: OpenFOAM 環境が読み込まれていません。先に以下を実行してください:"
    echo "  source /usr/lib/openfoam/openfoam2512/etc/bashrc"
    exit 1
fi

echo "=== OpenFOAM version: $WM_PROJECT_VERSION ==="

# ------------------------------------------------------------------
# 1. クリーンアップ（前回実行分を削除）
# ------------------------------------------------------------------
echo "--- cleaning ---"
rm -rf constant/polyMesh
rm -rf 0/box 0/heatSink 0/heatSource 0/basis
rm -f  0/cellToRegion constant/cellToRegion
rm -f  0/T 0/U 0/p 0/p_rgh 0/k 0/omega 0/alphat 0/nut
rm -f  log.ideasUnvToFoam log.transformPoints log.splitMeshRegions
rm -f  log.changeDictionary log.chtMultiRegionFoam log.checkMesh log.decomposePar
rm -rf processor*
find . -maxdepth 1 -name '[0-9]*.[0-9]*' -type d -exec rm -rf {} + 2>/dev/null || true
find . -maxdepth 1 -name '[1-9]*' -type d -exec rm -rf {} + 2>/dev/null || true

# ------------------------------------------------------------------
# 2. UNV → OpenFOAM メッシュ変換
# ------------------------------------------------------------------
echo "--- ideasUnvToFoam ---"
ideasUnvToFoam Mesh_1.unv 2>&1 | tee log.ideasUnvToFoam

# ------------------------------------------------------------------
# 3. mm → m スケール変換
# ------------------------------------------------------------------
echo "--- transformPoints (mm → m) ---"
transformPoints -scale '(0.001 0.001 0.001)' 2>&1 | tee log.transformPoints

# ------------------------------------------------------------------
# 4. 0/ にフィールドテンプレートを配置
#    ・splitMeshRegions がこれを各リージョン（0/box/ 等）へマッピング
#    ・全パッチのデフォルトは ".*" { type calculated; }
#    ・changeDictionary が正式な境界条件に上書き
# ------------------------------------------------------------------
echo "--- writing field templates to 0/ ---"

mkfield() {
    local obj=$1 cls=$2 dim=$3 val=$4
    {
        echo "FoamFile"
        echo "{"
        echo "    version     2.0;"
        echo "    format      ascii;"
        echo "    class       $cls;"
        echo "    object      $obj;"
        echo "}"
        echo "dimensions      $dim;"
        echo "internalField   $val;"
        echo "boundaryField"
        echo "{"
        echo '    ".*"'
        echo "    {"
        echo "        type        calculated;"
        echo "        value       $val;"
        echo "    }"
        echo "}"
    } > 0/$obj
}

mkfield T      volScalarField "[ 0 0 0 1 0 0 0 ]"     "uniform 293.15"
mkfield p      volScalarField "[ 1 -1 -2 0 0 0 0 ]"   "uniform 100000"
mkfield p_rgh  volScalarField "[ 1 -1 -2 0 0 0 0 ]"   "uniform 100000"
mkfield k      volScalarField "[ 0 2 -2 0 0 0 0 ]"    "uniform 0.001"
mkfield omega  volScalarField "[ 0 0 -1 0 0 0 0 ]"    "uniform 10"
mkfield alphat volScalarField "[ 1 -1 -1 0 0 0 0 ]"   "uniform 0"
mkfield nut    volScalarField "[ 0 2 -1 0 0 0 0 ]"    "uniform 0"
mkfield U      volVectorField "[ 0 1 -1 0 0 0 0 ]"    "uniform (0 -0.5 0)"

# ------------------------------------------------------------------
# 5. splitMeshRegions（各リージョンに 0/ フィールドをマッピング）
# ------------------------------------------------------------------
echo "--- splitMeshRegions ---"
splitMeshRegions -cellZones -overwrite 2>&1 | tee log.splitMeshRegions

# ------------------------------------------------------------------
# 5.5 固体リージョンから流体専用フィールドを削除
#     （固体は T と p のみ使用。p は solidThermo が要求するため残す）
# ------------------------------------------------------------------
echo "--- removing fluid fields from solid regions ---"
for region in heatSink heatSource basis; do
    rm -f 0/$region/{U,p_rgh,k,omega,nut,alphat}
done

# ------------------------------------------------------------------
# 6. changeDictionary で境界タイプ・境界条件を設定
#    system/<region>/changeDictionaryDict を参照
# ------------------------------------------------------------------
echo "--- changeDictionary ---"
for region in box heatSink heatSource basis; do
    echo "  region: $region"
    changeDictionary -region $region 2>&1
done | tee log.changeDictionary

echo "=== setup complete ==="
echo "次のコマンドで計算実行:"
echo "  chtMultiRegionFoam 2>&1 | tee log.chtMultiRegionFoam"
