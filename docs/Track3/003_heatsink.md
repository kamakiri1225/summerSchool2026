# 003 Heatsink: SALOMEでヒートシンクの熱流体・固体連成メッシュを作る

## この演習で目指すこと

ヒートシンクを題材に、流体領域（box）と固体領域（heatSink・heatSource・basis）を分けたマルチリージョン用メッシュを作成する。OpenFOAM 13の `foamMultiRun` で流体ソルバと固体ソルバを連成し、熱流体・固体連成解析につなげる。

- STEPファイルを読み込み、ソリッド単位に分解して名前を整理する
- Partitionで4つの領域（box・heatSink・heatSource・basis）を分割する
- 各領域の境界面にグループ名を付け、OpenFOAMへ渡すパッチ名を決める
- テトラメッシュを作成し、フィン周りに境界層（Viscous Layers）を追加する
- Sub-meshで流体領域だけメッシュサイズを調整する
- UNV形式でOpenFOAM用に出力する

モデル構成は次の4リージョンからなる。

- `box`: 周囲を流れる空気の流体領域（240 × 102 × 103 mm）
- `heatSink`: フィン部分の固体領域
- `heatSource`: 発熱源となる底板の固体領域
- `basis`: ヒートシンクを載せる土台の固体領域

![モデル構成（heatSink・heatSource・basis・box）](img/003_heatsink/page_151.svg)

### 使用データの場所

この演習で使うファイル・計算結果は、リポジトリの以下のフォルダにある。

| フォルダ | 内容 |
|----------|------|
| `data/003_heatsink/sample/model` | FreeCADで作成したCADモデル `model.FCStd` と、SALOMEへ読み込むために出力したSTEPファイル `model.step` の保存場所 |
| `data/003_heatsink/run001_of13` | SALOMEから出力した `Mesh_1.unv` と、OpenFOAM 13で `foamMultiRun` を実行するケース一式（セットアップスクリプト `setup.sh` を含む） |
| `data/003_heatsink/run001_of2512` | 同じメッシュをESI版OpenFOAM（v2512）の `chtMultiRegionFoam` で計算するケース一式（`setup.sh`・計算結果を含む） |

なお、CADモデルはFreeCADで作成しており、FreeCADの編集用ファイルを `model.FCStd`、SALOMEへ渡す形状データを `model.step` として保存している。この演習では、作成済みのCADモデルから出力したSTEPファイルをSALOMEへ読み込み、OpenFOAM用のマルチリージョンメッシュを作成するところまでを行う。

![FreeCADで作成したヒートシンクと流体領域のCADモデル](img/003_heatsink/FreeCADmodel.png)

この演習のOpenFOAM計算は **OpenFOAM 13**（www.openfoam.org 版）で行う。最終的には、マルチリージョンソルバによる熱流体・固体連成の計算を行う。

![計算過程のアニメーション（速度・温度分布の時間変化）](img/003_heatsink/ani_comp.gif)

---

## Geometry: STEPファイルを読み込む

### 1. Geometryモジュールへ切り替える

![Geometryへ切り替える](img/003_heatsink/page_152.svg)

- (1) `Geometry` に変更する。

### 2. STEPファイルをインポートする

![STEPファイルをインポートする](img/003_heatsink/page_153.svg)

- (2) `File` > `Import` > `STEP` をクリックする。
- (3) `model.step` を選択し `Open` をクリックする。
- (4) 単位をmm前提で読み込むため、警告ダイアログでは `No` をクリックする（`Yes`にするとモデルのスケールが変わってしまう）。

### 3. 内部形状を確認する

![透過表示で内部形状を確認する](img/003_heatsink/pdf_p176.svg)

- (5) オブジェクトブラウザまたは3Dビューで `model` をクリックして選択し、右クリック > `Transparency` をクリックする。
- (6) `Opaque` のスライダを `60%` にして `Ok` をクリックし、boxの中にあるheatSink・heatSourceの形状を確認する。

---

## Geometry: ソリッドを分解して名前を付ける

### 1. Explodeでソリッド単位に分解する

![Explodeでソリッドに分解する](img/003_heatsink/page_155.svg)

- (7) `Explode（要素に分解）` をクリックする。
- Sub-shapes Type を `Solid` にする。
- (8) `Apply and Close` をクリックする。

### 2. 4つのソリッドをリネームする

![ソリッドをリネームする](img/003_heatsink/page_156.svg)

**この章ではこの操作は不要です。** FreeCADでモデルを作った時点で各ソリッドに `heatSource` / `heatSink` / `basis` / `box` という名前を付けてあり、その名前がSTEPファイルに保存されているため、Explodeした時点で自動的に同じ名前が付く。

- (9) 名前が付いていない場合（`Solid_1` のような名前になっている場合）だけ、分解された4つのソリッドを右クリック > `Rename` で、それぞれ `heatSource` / `heatSink` / `basis` / `box` に名前を変更する。
- ここでの名前は、後の境界面グループ作成や、OpenFOAM側のリージョン設定でそのまま使う。上図と同じ名前になっていることを確認しておく。

---

## Geometry: Partitionで領域を分割する

### 1. Partitionを実行する

![Partitionを実行する](img/003_heatsink/page_157.svg)

- (10) `Partition（分割）` をクリックする。
- Objects に4つのソリッド（heatSource・heatSink・basis・box）を指定する。
- Resulting Type を `Solid` にする。
- (11) `Apply and Close` をクリックする。

![Partition_1の生成を確認する](img/003_heatsink/page_158.svg)

- `Partition_1` の下に、4つのソリッドが子要素として作られたことを確認する。これらの共有面が、後でOpenFOAM側の流体-固体連成境界になる。

### 2. Partition結果を再度分解してリネームする

![Partition_1を再度Explodeする](img/003_heatsink/page_159.svg)

- (12) `Explode` をクリックする。Main Objectは `Partition_1`、Sub-shapes Typeは `Solid` にする。
- (13) `Apply and Close` をクリックする。

![リネームする](img/003_heatsink/page_160.svg)

- (14) 分解された4つのソリッドを右クリック > `Rename` で、`heatSource` / `heatSink` / `basis` / `box` にリネームする。

### 3. 保存する

![名前を付けて保存する](img/003_heatsink/page_161.svg)

- (15) `File` > `Save As...` をクリックする。
- (16) ファイル名 `geometry_heatSink_001.hdf` で `Save` をクリックする。

---

## Geometry: box領域の境界面にグループを作る

OpenFOAMでは境界条件は面の名前に対して設定するため、SALOME側で面グループを作り、後でOpenFOAMのパッチ名として使う。ここではまずbox（流体領域）の8つの境界面グループを作る。

### 1. 外壁面のグループを作る（YMin・ZMax・XMax・YMax・XMin）

![YMinグループを作成する](img/003_heatsink/page_162.svg)

- (1) `Partition_1` を右クリック > `Create Group` をクリックする。
- Shape Typeを面（Face）にし、Group Nameに `YMin` と入力する。
- (2) 対象の面を選択して `Add` をクリックする。
- (3) `Apply` をクリックする。

![ZMaxグループを作成する](img/003_heatsink/page_163.svg)

- (4)(5) 同様に `ZMax` の面を選択して `Add` → `Apply`。

![XMaxグループを作成する](img/003_heatsink/page_164.svg)

- (6)(7) 同様に `XMax` の面を選択して `Add` → `Apply`。

![YMaxグループを作成する](img/003_heatsink/page_165.svg)

- (8)(9) 同様に `YMax` の面を選択して `Add` → `Apply`。

![XMinグループを作成する](img/003_heatsink/page_166.svg)

- (10)(11) 同様に `XMin` の面を選択して `Add` → `Apply`。

### 2. basisとの接触面グループを作る

![basisグループを作成する](img/003_heatsink/pdf_p189.svg)

- (12) `Shape Type` を面にし、`Name` に `basis` と入力する。`basis` の側面4面と底面1面の計5面を選択して `Add` をクリックする。
- (13) `Apply` をクリックする。

### 3. heatSink・heatSourceとの接触面グループを作る

![box外側の面を非表示にする](img/003_heatsink/page_168.svg)

- (14) 内部のheatSink・heatSourceの面を選択しやすくするため、box外側の面（上面・側面など）を選択して `Hide selected` で非表示にする。

![heatSinkグループを作成する](img/003_heatsink/page_169.svg)

- (15) `RIGHT view` に切り替え、heatSinkの表面（フィン部分）を選択して `Add` をクリックする。
- (16) `Apply` をクリックする。

![heatSourceグループを作成する](img/003_heatsink/page_170.svg)

- (17) 同様にheatSourceの表面を選択して `Add` をクリックする。
- (18) `Apply` をクリックする。

### 4. basis側の上面グループを作る

![basis_topグループを作成する](img/003_heatsink/page_171.svg)

- (19) 今度はbasis自体の視点で、heatSourceと接する上面を選択して `Add` をクリックする。
- (20) `Apply and Close` をクリックする。グループ名は `basis_top` とする。

### 5. 完成した境界グループを確認する

![Partition_1配下の全境界グループを確認する](img/003_heatsink/pdf_p194.svg)

- `Partition_1` の配下に、`YMin` / `ZMax` / `XMax` / `YMax` / `basis` / `XMin` / `heatSink` / `heatSource` / `basis_top` の9つの面グループが揃ったことを確認する。
- その上にある `heatSource` / `heatSink` / `basis` / `box` は、Partitionで分割されたソリッド（リージョン）のグループで、面グループとは別物である。

### 6. 保存する

![名前を付けて保存する](img/003_heatsink/page_173.svg)

- (21) `File` > `Save As...` をクリックする。
- (22) ファイル名 `geometry_heatSink_002.hdf` で `Save` をクリックする。

---

## Mesh: テトラメッシュを作成する

### 1. Meshモジュールへ切り替える

![Meshへ切り替える](img/003_heatsink/pdf_p196.svg)

- (1) 画面左上のモジュールのプルダウンを `Mesh` に変更する。Mesh画面に切り替わり、Object Browserには `Partition_1` とその配下の面グループがそのまま表示される。

### 2. メッシュを新規作成する

![Create Meshを開く](img/003_heatsink/page_175.svg)

- (2) `Mesh` > `Create Mesh` をクリックする。

![テトラメッシュの仮設定をする](img/003_heatsink/page_176.svg)

- (3) Geometryに `Partition_1` が選択されていることを確認する。
- (4) 3Dタブで `Assign a set of automatic hypotheses` から `3D: Tetrahedralization` を選ぶ。
- (5) NETGEN 3D ParametersのLengthを `25`（mm）に仮設定する。
- (6) `Apply and Close` をクリックする。

![メッシュを計算する](img/003_heatsink/page_177.svg)

- (7) `Mesh_1` を選択した状態で `Compute` をクリックし、メッシュを作成する。
- 計算成功（Nodes 11864、Tetrahedrons 59943）を確認する。

### 3. 断面で内部形状を確認する

![Clippingで断面を確認する](img/003_heatsink/page_178.svg)

- Clipping平面（Y-Z面）を使い、boxの中のheatSink形状とメッシュの様子を確認する。

### 4. メッシュサイズを調整する

![NETGEN 3D Parametersを編集する](img/003_heatsink/page_179.svg)

- (8) `Mesh_1` を選択した状態で `Edit Mesh` をクリックする。
- (9) `NETGEN 3D Parameters_1` を編集し、Max sizeを `10`、Min sizeを `0.25` に変更する。

---

## Mesh: 境界層（Viscous Layers）を追加する

### 1. heatSink・heatSourceの表面に境界層を追加する

![Viscous Layersを追加する](img/003_heatsink/page_180.svg)

- (10) Add. Hypothesisで `Viscous Layers` を追加する。

![境界層の厚さを設定する](img/003_heatsink/page_181.svg)

- Total thicknessを `0.2`、Number of layersを `3`、Stretch factorを `1` にする。
- Extrusion methodは `Face offset` を選ぶ。
- (11) heatSink・heatSourceの面を選択して `Add` をクリックする。

### 2. basis側の境界層との接続に注意する

![basisとの接続でメッシュが崩れる問題](img/003_heatsink/page_182.svg)

- heatSink・heatSourceだけに境界層を付けると、境界層の外側の輪郭がbasisの表面メッシュとぴったり重ならず、つなぎ目でメッシュ生成エラーになりやすい。
- これを避けるため、basis側にも対応する境界層（Viscous Layers）を追加し、輪郭を合わせる。

### 3. basis側にも境界層を追加する

![basis側にViscous Layers_2を追加する](img/003_heatsink/page_183.svg)

- (12) Viscous Layers_1に続けて、プラスボタンで新たに `Viscous Layers_2` を追加する。
- basis_topの面を選択して `Add` する。
- Total thicknessを `1`、Number of layersを `3` にし、Extrusion methodは `Surface offset + smooth` を選ぶ（heatSink・heatSourceの境界層と滑らかに接続させるため）。

### 4. 再計算して確認する

![メッシュを再計算する](img/003_heatsink/page_184.svg)

- (13) `Compute` をクリックする。計算成功（Nodes 47701、Tetrahedrons 75244、Prisms 63612）を確認する。

![警告内容を確認する](img/003_heatsink/page_185.svg)

![フィン部分の境界層を確認する](img/003_heatsink/page_186.svg)

- 計算は成功するが、フィン間隔が狭いため「Thickness of viscous layers not reached（指定した境界層厚さに届いていない）」という警告が出ることがある。
- 警告が出ていても致命的なエラーでなければ、そのまま次に進めてよい。

### 5. boxの外壁にも境界層を追加する

![Viscous Layers_3を追加する](img/003_heatsink/page_187.svg)

- (14) 新たに `Viscous Layers_3` を追加する。
- Total thicknessを `2`、Number of layersを `3`、Extrusion methodは `Surface offset + smooth` にする。
- (15) boxの外壁（ZMax・XMax・XMin）の面を選択して `Add` をクリックする。

![3つのViscous Layersを確認して確定する](img/003_heatsink/page_188.svg)

- Add. HypothesisにViscous Layers_1〜3がすべて追加されていることを確認し、`Apply and Close` をクリックする。

### 6. 最終メッシュを計算する

![メッシュを計算する](img/003_heatsink/page_189.svg)

- (16) `Compute` をクリックする。計算成功（Nodes 52304、Tetrahedrons 76661、Prisms 72804）、エラーなしを確認する。

![フィン周りの境界層を拡大確認する](img/003_heatsink/page_190.svg)

- フィン間の境界層とテトラメッシュの接続部分を拡大し、品質を確認する。

---

## Mesh: Sub-meshで流体領域だけ細分化する

### 1. box用のSub-meshを作成する

![Create Sub-meshを開く](img/003_heatsink/page_191.svg)

- (17) `Mesh_1` を選択した状態で `Create Sub-mesh` をクリックする。

![Sub-meshの設定をする](img/003_heatsink/page_192.svg)

- (18) Geometryに `box` が選択されていることを確認する。
- (19) 3Dタブで `3D: Tetrahedralization` を選ぶ。
- NETGEN 3D Parameters_2でLengthを `10`（mm）にする。
- (20) Add. HypothesisにViscous Layers_1〜3を追加する。
- (21) `Apply and Close` をクリックする。

### 2. Sub-meshを計算する

![box部分のメッシュを拡大確認する](img/003_heatsink/page_193.svg)

- box領域内のフィン周りが、全体メッシュより細かくなっていることを確認する。

![Compute を実行する](img/003_heatsink/page_194.svg)

- (26) `Mesh_1` を選択した状態で `Compute` をクリックし、Sub-meshを反映してメッシュを再計算する。

### 3. 不要なグループを削除する

![不要なGroup_1を削除する](img/003_heatsink/page_195.svg)

- (29) グループ作成時に重複してできた `Group_1`（basisの底面）は不要なため、右クリック > `Delete` で削除する。

### 4. 保存する

![名前を付けて保存する](img/003_heatsink/page_196.svg)

- (27) `File` > `Save As...` をクリックする。
- (28) ファイル名 `geometry_heatSink_003.hdf` で `Save` をクリックする。

---

## Mesh: OpenFOAM用にUNV出力する

![UNVファイルをエクスポートする](img/003_heatsink/page_197.svg)

- (29) `Mesh_1` を右クリック > `Export` > `UNV file` をクリックする。
- (30) ファイル名 `Mesh_1.unv` として、OpenFOAMの計算フォルダ `run001_of13` に `Save` する。
- 作成した面グループ名（YMin・YMax・ZMax・XMax・XMin・basis・heatSink・heatSource・basis_top）がそのままOpenFOAMのパッチ名になる。

---

## （余裕がある人向け）OpenFOAM側での計算

SALOME で作成したメッシュを OpenFOAM 形式に変換して利用する。全体の流れは以下の通り。

![SALOMEからOpenFOAMへの連携フロー](img/000_salome/salome_to_openfoam_flow.png)

- 作業フォルダ: `data/003_heatsink/run001_of13`

### OpenFOAM 13環境の読み込み

この演習の計算はOpenFOAM 13で行う。まずOpenFOAM 13の環境を読み込む。

```bash
source /opt/openfoam13/etc/bashrc
cd data/003_heatsink/run001_of13
```

### setup.shによるメッシュ変換とケース設定

ケースフォルダには、UNVメッシュの変換からリージョン分割・境界条件設定までを一括実行する `setup.sh` を用意している。

```bash
bash setup.sh
```

`setup.sh` の中では、以下の処理を順に行っている。

![OpenFOAM 13ケースセットアップの流れ](img/003_heatsink/openfoam13_setup_flow.svg)

```text
1. 前回実行分のクリーンアップ
2. ideasUnvToFoam Mesh_1.unv     … UNVメッシュをOpenFOAM形式へ変換
3. transformPoints "scale=(0.001 0.001 0.001)"  … mm単位からm単位へスケール変換
4. splitMeshRegions -cellZones  … セルゾーン名を使い4リージョンへ分割
5. 0.orig/ のフィールドテンプレートを 0/ へコピー
   流体は T・U・p・p_rgh・k・omega・alphat・nut、固体は T を用意し、各境界を calculated にしておく
6. 0・constant・system にリージョン別の入力を用意
7. changeDictionary -region <各リージョン>  … 正式な境界条件へ上書き
8. checkMesh -region <各リージョン>  … 分割後のメッシュを確認
```

- `ideasUnvToFoam` でUNVメッシュをOpenFOAM形式に変換する。SALOMEでmm単位のモデルを作っているため、`transformPoints "scale=(0.001 0.001 0.001)"` でOpenFOAMが使うm単位に変換する。
- `splitMeshRegions -cellZones` は、UNVメッシュ作成時に付けたセルゾーン名（box・heatSink・heatSource・basis）を使ってメッシュを4つのリージョンに分割する。これにより、`constant/<region>/polyMesh` と `0/<region>` が作成される。`system/<region>` には、あらかじめ各リージョンの数値計算設定と境界条件辞書を用意している。
- `system/<region>/changeDictionaryDict` に各パッチの境界条件を記述しておき、`changeDictionary -region <region>` で `0/<region>` の各フィールドへ反映する。流体と固体の接触面には `coupledTemperature` を設定し、リージョン間で温度と熱流束を受け渡す。
- 各リージョンの物性値は `constant/<region>`、数値スキーム・行列ソルバ設定は `system/<region>` に用意している。

![OpenFOAM側でメッシュ全体を確認する](img/003_heatsink/page_198.svg)

- ParaView等で、box（流体）とheatSink・heatSource・basis（固体）を含むメッシュ全体像を確認する。

### foamMultiRunの実行

セットアップが完了したら、熱流体・固体連成ソルバを実行する。

```bash
foamMultiRun > log.foamMultiRun.of13 2>&1
```

- OpenFOAM 13では `foamMultiRun` が `system/controlDict` の `regionSolvers` を読み込み、`box` を流体ソルバ、`heatSink`・`heatSource`・`basis` を固体ソルバとして連成計算する。
- 流体側は乱流モデル（`kOmegaSST`）で速度・圧力・温度・乱流量を解き、固体側は温度を解く。
- v2512の参照ケースと同じ `maxCo 100` を使用する。なお `system/controlDict` には `maxDi 100` も書いてあるが、OpenFOAM 13の `solid` モジュールは `maxDi` を読まず、固体側の時間刻み上限は `maxDeltaT` だけで決まる。この記述はv2512ケースとの対応を残すためのもので、OpenFOAM 13では効果がない。
- `system/controlDict` の設定により、時刻 `2` から `60` まで2秒間隔で結果を書き出す。
- 流入条件は `U = (0 -0.5 0) m/s`（y方向へ0.5 m/s）、初期温度は `293.15 K` としている。発熱源の設定は `constant/heatSource/fvModels`、各リージョンの境界条件は `system/<region>/changeDictionaryDict` を参照する。
- 補足: OpenFOAM 13の `foamMultiRun` は、初期の過渡でフィン近傍の境界層セルに負温度・速度スパイクが発生して発散する（v2512の `chtMultiRegionFoam` は同条件で安定）。このため `system/box/fvConstraints` に温度制限（`limitTemperature` 280〜400 K）と速度制限（`limitMag` 5 m/s）を設定して安定化している。
- なお、`setup.sh` から計算実行までは `./Allrun` で一括実行できる。計算は数時間かかるが、`startFrom latestTime` のため、途中で止めても `./Allrun` の再実行で続きから計算される。

### ESI版OpenFOAM（v2512）で計算する場合

同じメッシュをESI版で計算するケースを `data/003_heatsink/run001_of2512` に用意している。実行方法はOpenFOAM 13側と同じく `./Allrun` だが、**ソルバも設定ファイルの置き場所も異なる**ので注意する。

```bash
cd data/003_heatsink/run001_of2512
. /usr/lib/openfoam/openfoam2512/etc/bashrc
./Allrun          # setup.sh → chtMultiRegionFoam
```

| 項目 | OpenFOAM 13（`run001_of13`） | OpenFOAM v2512（`run001_of2512`） |
|------|------------------------------|-----------------------------------|
| ソルバ | `foamMultiRun`（モジュール式） | `chtMultiRegionFoam` |
| リージョンの指定 | `system/controlDict` の `regionSolvers`（`box fluid;` / `heatSink solid;` …） | `constant/regionProperties` の `regions (fluid (box) solid (heatSink heatSource basis))` |
| 乱流モデル | `constant/box/momentumTransport`（`simulationType RAS;` + `model kOmegaSST;`） | `constant/box/turbulenceProperties`（`RASModel kOmegaSST;`） |
| 発熱源 | `constant/heatSource/fvModels`。`type heatSource;` で `Q` を時刻テーブル指定 | `system/heatSource/fvOptions`。`type scalarSemiImplicitSource;` でエンタルピー `h` に投入 |
| 固体の時間刻み | `maxDi` は読まれない（`maxDeltaT` のみ有効） | `maxDi 100` が有効 |
| 書き出し制御 | `writeControl adjustableRunTime;` | `writeControl adjustable;` |
| 安定化の追加設定 | `system/box/fvConstraints` が必要（下の補足を参照） | 不要（同条件で安定） |

- 発熱条件はどちらも同じで、計算開始から10秒間だけ100 Wを投入し、その後は0にする。
- 流入条件（`U = (0 -0.5 0) m/s`）・初期温度（`293.15 K`）・`maxCo 100`・`endTime 60`・2秒間隔の書き出しも両者で揃えてある。
- `setup.sh` の流れ（`ideasUnvToFoam` → `transformPoints` → `splitMeshRegions` → `changeDictionary`）は共通である。

### 計算結果の確認

![計算結果（速度分布・温度分布）](img/003_heatsink/page_199.svg)

- 流体領域では速度ベクトル分布、固体領域では温度分布を確認する。
- ヒートシンク周りの流れが発熱部からの熱を受け取り、フィン表面から周囲へ熱を逃がしている様子を確認する。

計算が進むにつれて、発熱源からフィン先端まで温度が上昇し、周囲の空気が対流で熱を運び去っていく過程をアニメーションで確認できる。

![計算過程のアニメーション（速度・温度分布の時間変化）](img/003_heatsink/ani_comp.gif)
