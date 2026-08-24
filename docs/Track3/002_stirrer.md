# 002 Stirrer: SALOMEで撹拌機のヘキサメッシュを作る

## この演習で目指すこと

撹拌機形状を題材に、Shaperで断面形状を作成し、Geometryで回転・押し出し・分割を行い、Meshでヘキサメッシュを作成する。

- Shaperでスケッチを作成する
- 寸法拘束と幾何拘束で形状を確定する
- ShellをGeometryへエクスポートする
- 回転、押し出し、Partitionでブロック分割する
- グループを整理してOpenFOAMへ渡す境界名を作る
- ヘキサメッシュとサブメッシュを作成する

この撹拌槽モデルは、オープンCAEサマースクール2020 Track3で扱った題材でもある。2020年の演習では、`blockMesh` で扇形の6ブロックを作成し、`stitchMesh` で貼り合わせ、`mergeMesh` で組み合わせることで、羽根付きの撹拌槽形状をヘキサメッシュとして作り上げていた。

![Track3-4 OpenFOAMによる形状の組み立て（サマースクール2020資料より）](img/002_stirrer/2020_track3_p013.svg)

この2020年の手法（blockMesh・stitchMesh・mergeMesh）は、技術書典で販売されている技術書「OpenFOAMでメッシュ作成」にも解説されている。

![技術書「OpenFOAMでメッシュ作成」](img/002_stirrer/技術書_OpenFOAMメッシュ作成.png)

- 技術書典: <https://techbookfest.org/product/5752199185432576>

今回の演習では、同じ撹拌槽形状を題材にしつつ、`blockMesh` 手組みではなく **SALOME** でジオメトリとメッシュを作成する方法を扱う。

### この演習のゴール

今回の演習のゴールは、下図のように、羽根形状を含む1/4セクター分の撹拌槽形状に対して、SALOMEでヘキサメッシュを作成することである。実際のOpenFOAM計算では、このセクターメッシュを回転コピー・結合して、全周の撹拌槽形状を組み立てる。

![今回作成するヘキサメッシュのゴール（1/4セクター）](img/002_stirrer/page_140.svg)
![羽根の変位にメッシュが追従変形するアニメーション](img/002_stirrer/ani_deform.gif)

### 使用データの場所

この演習で使うファイル・計算結果は、リポジトリの以下のフォルダにある。

| フォルダ | 内容 |
|----------|------|
| `data/002_Stirrer/sample/mesh/mesh_of13` | SALOMEから出力した `Mesh_1.unv` と、UNV変換・topoSet・createBaffles を行うOpenFOAMケース（OpenFOAM 13） |
| `data/002_Stirrer/sample/mesh/master_curve_of13` | 羽根の可動化テスト（moveDynamicMesh）用のOpenFOAMケース（OpenFOAM 13） |

---

## モデルの作り方

この撹拌槽の形状は、**向きの違う2つの平面にスケッチを描き、それぞれ別の方法で立体化する**ことで作る。下図がその全体像である。

![2つのスケッチから回転と押し出しで撹拌槽形状を作る](img/002_stirrer/model_overview_p82.png)

- ① **X-Z平面**にスケッチした断面を、**Z軸まわりに回転**させて、撹拌槽の壁（円筒状の外周）を作る。
- ② **X-Y平面**にスケッチした断面を、**Z軸方向に押し出し**て、槽の底や羽根まわりのブロックを作る。

このように「回転で作る部分」と「押し出しで作る部分」を組み合わせ、最後にPartitionで分割してヘキサメッシュ用のブロック形状に仕上げていく。以降の手順では、この2つのスケッチを順に作成していく。

---

## モデル作成

### 1. Shaperで断面スケッチを開始する

まず1つ目のスケッチとして、下図のような撹拌槽の壁の断面（X-Z平面）を描く。高さ110mm・幅40mmを基準に、内側の仕切り（幅3mm）や段（高さ15mm・35mm）を寸法拘束で決めていく。これをZ軸まわりに回転させると、槽の外周壁になる。

![X-Z平面に描く壁の断面（寸法つき）](img/002_stirrer/drawing_black_X-Z.svg)

![Geometryへ変更する](img/002_stirrer/page_073.svg)

- (1) `Geometry` に変更し、`Shaper` の画面へ切り替える。

![スケッチ平面を選択する](img/002_stirrer/page_074.svg)

- (2) `Sketch` をクリックする。
- (3) `Z-X` 平面を選択する。

![FRONT表示へ切り替える](img/002_stirrer/page_075.svg)

- (4) `FRONT` をクリックし、スケッチしやすい向きにする。

### 2. 最初のスケッチを描く

![線で概形を描く](img/002_stirrer/page_076.svg)

- (5) `線` を使い、まずは大まかな形状を描く。
- 最初は正確な寸法よりも、必要な線分を作ることを優先する。

![寸法拘束と平行拘束を入れる](img/002_stirrer/page_077.svg)

- (6) 寸法拘束を行う。
- 必要な線は平行拘束で向きをそろえる。

![寸法拘束を確定する](img/002_stirrer/page_078.svg)

- 寸法拘束を入力し、チェックをクリックして確定する。

![拘束完了を確認する](img/002_stirrer/page_079.svg)

- すべての拘束が完了すると、スケッチ線が緑色になる。
- 緑色になっていない場合は、寸法拘束または幾何拘束が不足している。

![追加の線を描く](img/002_stirrer/page_080.svg)

- (7) `線` をクリックして、追加のスケッチと寸法拘束を行う。

![スケッチを終了する](img/002_stirrer/page_081.svg)

- (8) スケッチが完了したら、チェックをクリックしてスケッチを終了する。

---

## 追加断面のスケッチ

2つ目のスケッチは、上から見た（X-Y平面）扇形の断面である。下図のように、中心から半径 `10 / 15 / 25 / 35 / 40` mm の円弧で領域を分け、全体を `60°` の扇形とする。`30°` の二等分線が羽根の位置になる。中心付近は羽根の根本にあたるため、拡大図のように `1.2` / `1.5` / `3` mm の細かい寸法で形を整える。

![X-Y平面に描く扇形の断面（半径・角度つき）](img/002_stirrer/drawing_black_X-Y.svg)

この扇形をZ軸方向に押し出すことで、槽の底や羽根まわりのブロックを作る。円弧で分けた半径方向の区切りは、後でヘキサメッシュのブロック境界（サブメッシュの `r1`〜`r6` など）として使う。

### 1. 2つ目のスケッチを開始する

![XY平面でスケッチを開始する](img/002_stirrer/page_082.svg)

- (1) `Sketch` をクリックする。
- (2) `X-Y` 平面を選択する。

![TOP表示へ切り替える](img/002_stirrer/page_083.svg)

- (3) `TOP` をクリックして、上面からスケッチする。

![原点から線を描く](img/002_stirrer/page_084.svg)

- (4) `線` をクリックし、原点から右方向へ線を描く。

![斜め線を描く](img/002_stirrer/page_085.svg)

- (5) 原点から斜め方向へ線を描く。

![端点を一致拘束する](img/002_stirrer/page_086.svg)

- (6) 端点どうしが拘束されていない場合は、`Coincident` で端点を一致拘束する。

![角度拘束を入れる](img/002_stirrer/page_087.svg)

- (7) 2点を選択し、角度拘束を入れる。

![円弧を描く](img/002_stirrer/page_088.svg)

- (8) 3点を選択して円弧を描く。
- 原点、端点、線上の点を使い、円弧の位置を決める。

![一致拘束を入れる](img/002_stirrer/page_089.svg)

- (9) 必要な点に一致拘束を入れ、線と円弧を接続する。

![半径拘束を入れる](img/002_stirrer/page_090.svg)

- (10) 円弧に半径拘束を入れる。

![スケッチを終了する](img/002_stirrer/page_091.svg)

- (11) スケッチを終了する。

![ファイルを保存する](img/002_stirrer/page_092.svg)

- (12) `File > Save As...` で名前を付けて保存する。
- (13) `Save` をクリックする。

---

## 羽根形状のスケッチ

ここで描いているのは、先ほどのX-Y平面スケッチ（[追加断面のスケッチ](#追加断面のスケッチ) の図）の**中心付近の拡大部分**にあたる。拡大図の `1.2` / `1.5` / `3` mm の寸法で示された、羽根の根本まわりの細かい円弧と補助線を作り込んでいく作業である。

### 1. 円弧と補助線を作成する

![円弧と半径拘束を作る](img/002_stirrer/page_093.svg)

- (1) 円弧を描く。
- (2) 半径拘束を入れる。

![追加の円弧を作る](img/002_stirrer/page_094.svg)

- (3) さらに円弧を描く。
- (4) 半径拘束を入れる。

![補助線へ変更する](img/002_stirrer/page_095.svg)

- (5) 半径 `1.5` の線をクリックし、`Auxiliary` にチェックを入れる。
- 線が補助線になる。

![線を追加する](img/002_stirrer/page_096.svg)

- (6) `線` をクリックして追加スケッチを描く。

![水平方向の寸法拘束を入れる](img/002_stirrer/page_097.svg)

- (7) 2点の水平方向寸法拘束を入れる。

![拡大して線を描く](img/002_stirrer/page_098.svg)

- (8) 拡大し、`線` で細部をスケッチする。

![平行拘束を入れる](img/002_stirrer/page_099.svg)

- (9) 2本ずつ線を選択し、平行拘束を入れる。

![寸法拘束を入れる](img/002_stirrer/page_100.svg)

- (10) 寸法拘束を入れ、形状を確定する。

![直線を補助線にする](img/002_stirrer/page_101.svg)

- (11) 直線をクリックし、`Auxiliary` にチェックを入れる。
- 線が補助線になる。

![細部を確認する](img/002_stirrer/page_102.svg)

- 拡大表示で、拘束と接続が意図通りになっていることを確認する。

### 2. Shellを作成する

![SketchからShellを作成する](img/002_stirrer/page_103.svg)

- (12) `Shell` をクリックし、`Sketch_1` を選択する。
- (13) チェックをクリックし、スケッチからShellを作成する。

![もう一つのShellを作成する](img/002_stirrer/shell2_p116.png)

- (14) `Shell` をクリックし、`Sketch_2` を選択する。
- (15) チェックをクリックし、スケッチから `Shell_2` を作成する。

![Geometryへエクスポートする](img/002_stirrer/page_105.svg)

- (16) `Export to GEOM` をクリックし、Geometryへエクスポートする。

![保存する](img/002_stirrer/page_106.svg)

- (17) `File > Save As...` で名前を付けて保存する。
- (18) `Save` をクリックする。

---

## Geometryで形状を作る

### 1. Geometryへ切り替える

![Geometryへ切り替える](img/002_stirrer/page_107.svg)

- (1) `Geometry` に変更し、Geometry画面へ切り替える。

![必要なShellを表示する](img/002_stirrer/page_108.svg)

- (2) 背景上で右クリックし、`Hide All` をクリックする。
- (3) `Shell_1` と `Shell_2` を表示する。

![軸を表示する](img/002_stirrer/page_109.svg)

- (4) `Create an origin and base Vector` をクリックし、軸を表示する。

### 2. 回転と押し出しを行う

![回転を作成する](img/002_stirrer/page_110.svg)

- (5) `Revolution` をクリックする。
- (6) `Apply and Close` をクリックする。

![押し出しを作成する](img/002_stirrer/page_111.svg)

- (6) `Extrusion` をクリックする。
- (7) `Apply and Close` をクリックする。

![回転押し出しと押し出し結果](img/002_stirrer/page_112.svg)

- 回転押し出しと押し出しで、撹拌機の基本形状を作る。

### 3. Partitionで分割する

![Partitionを作成する](img/002_stirrer/page_113.svg)

- (8) `Partition` をクリックする。
- (9) `Apply and Close` をクリックする。

![分割結果を確認する](img/002_stirrer/page_114.svg)

- Partition後の形状を確認する。

ここで、Shaperのスケッチに入れ忘れていた分割線を追加する。

本来は **Shaper側でスケッチを修正する方が、パラメトリックに（寸法や履歴をたどって）変更でき便利**である。ただしここでは、**Geometry側で直接修正することもできる**ということを体験するために、あえてGeometry上で分割線（分割面）を入れてみる。以下の手順で、後からブロック分割を足していく。

![分割面を作成する](img/002_stirrer/page_115.svg)

- (10) 分割面を作成する。
- (12) `Apply and Close` をクリックする。

![分割面を平行移動する](img/002_stirrer/page_116.svg)

- (13) 作成した `Face_1` を平行移動する。
- (14) `Dz = 10` として `Apply` をクリックする。
- (16) `Dz = 20`、(18) `Dz = 30`、(20) `Dz = 40` として分割面を複製する。
- (21) `Apply and Close` をクリックする。

![分割面でPartitionする](img/002_stirrer/page_117.svg)

- (21) `Partition` をクリックし、Objectsに `Partition_1`、Tool Objectsに平行移動で作った4枚の分割面（`Translation_1`〜`Translation_4`）を指定する（画像内の説明文は `Extrusion` になっているが、実際に開いているのはPartitionのダイアログ）。
- (22) `Apply and Close` をクリックする。`Partition_2` が作成される。

![Partition結果を確認する](img/002_stirrer/page_118.svg)

- `Partition_2` により、z=10〜40mmの4枚の面の位置で形状が水平方向に分割されたことを確認する。

![Propagateを実行する](img/002_stirrer/page_119.svg)

- (23) `Operations > Blocks > Propagate` をクリックする。
- (24) `Apply and Close` をクリックする。

![保存する](img/002_stirrer/page_120.svg)

- (25) `File > Save As...` で名前を付けて保存する。
- (26) `Save` をクリックする。

---

## グループを整理する

OpenFOAMへ渡す面や線を整理するため、Geometry側でグループを作成する。境界条件に使う面、メッシュ分割に使う線を分かりやすい名前にしておく。

ここでは、Propagateで作られた `Compound_1`〜`Compound_15`（方向ごとの辺の集まり）を `Union Groups` でまとめ、後のサブメッシュ設定で使う線グループを作成する。作成する線グループは以下の11個。

| 線グループ | 方向 |
|-----------|------|
| `z1` / `z2` / `z3` | 軸（z）方向。高さ位置ごとの辺 |
| `z_rotor` | 軸（z）方向のうち回転領域まわりの辺 |
| `theta1` | 周方向の辺 |
| `r1`〜`r6` | 半径方向の辺 |

![Union Groupsでz1を作成する](img/002_stirrer/page_121.svg)

- (1) `New Entity > Group > Union Groups` をクリックする。
- (2) Nameを `z1` とし、対象のCompoundを選んで `Apply` をクリックする。

![z2を作成する](img/002_stirrer/page_122.svg)

- (3) 同様にNameを `z2` として `Apply` をクリックする。

![z3を作成する](img/002_stirrer/page_123.svg)

- (4) Nameを `z3` として `Apply` をクリックする。

![z_rotorを作成する](img/002_stirrer/page_124.svg)

- (5) Nameを `z_rotor` とし、回転領域まわりの4つのCompoundを選んで `Apply` をクリックする。

![theta1を作成する](img/002_stirrer/page_125.svg)

- (6) Nameを `theta1` とし、周方向の2つのCompoundを選んで `Apply` をクリックする。

![r1を作成する](img/002_stirrer/page_126.svg)

- (8) Nameを `r1` として `Apply` をクリックする。

![r2を作成する](img/002_stirrer/page_127.svg)

- (9) Nameを `r2` として `Apply` をクリックする。

![r3を作成する](img/002_stirrer/page_128.svg)

- (10) Nameを `r3` として `Apply` をクリックする。

![r4を作成する](img/002_stirrer/page_129.svg)

- (11) Nameを `r4` として `Apply` をクリックする。

![r5を作成する](img/002_stirrer/page_130.svg)

- (12) Nameを `r5` として `Apply` をクリックする。

![r6を作成する](img/002_stirrer/page_131.svg)

- (13) Nameを `r6` として `Apply` をクリックする。

![グループ整理結果を確認する](img/002_stirrer/page_132.svg)

- ツリーに `z1` / `z2` / `z3` / `z_rotor` / `theta1` / `r1`〜`r6` の11個の線グループが並んでいることを確認する。

![不要な線グループを削除する](img/002_stirrer/page_133.svg)

- (14) 不要な線グループは削除する。
- OpenFOAM変換に不要なグループを減らし、境界名の混乱を避ける。

![保存する](img/002_stirrer/page_134.svg)

- (15) `File > Save As...` で名前を付けて保存する。
- (16) `Save` をクリックする。

---

## ヘキサメッシュ作成

### 1. Meshモジュールへ切り替える

![Meshへ切り替える](img/002_stirrer/mesh_switch_p147.png)

- (1) `Mesh` に変更し、Mesh画面へ切り替える。

![Partitionを表示する](img/002_stirrer/page_136.svg)

- (2) `Partition_2` を表示する。
- (3) 拡大し、メッシュ対象の形状を確認する。

![Create Meshを開く](img/002_stirrer/page_137.svg)

- (4) `Mesh > Create Mesh` をクリックする。

![ヘキサメッシュ条件を設定する](img/002_stirrer/page_138.svg)

- (5) `Partition_2` が選択されていることを確認する。
- (6) 3Dヘキサメッシュを設定する。
- (7) 分割数を `15` とする。
- (8) `Apply and Close` をクリックする。

![メッシュを計算する](img/002_stirrer/page_139.svg)

- (9) `Mesh_1` を選択した状態で `Compute` をクリックし、メッシュを作成する。
- メッシュ情報を確認する。

![メッシュ結果を確認する](img/002_stirrer/page_140.svg)

- 作成されたヘキサメッシュを確認する。

![メッシュ拡大結果を確認する](img/002_stirrer/page_141.svg)

- 細部のメッシュ品質を確認する。

![保存する](img/002_stirrer/page_142.svg)

- (10) `File > Save As...` で名前を付けて保存する。
- (11) `Save` をクリックする。

### 2. サブメッシュで部分的に分割数を変える

![Create Sub-meshを開く](img/002_stirrer/page_143.svg)

- (12) `Mesh_1` を選択した状態で `Create Sub-mesh` をクリックする。

![線グループへ分割数を設定する](img/002_stirrer/page_144.svg)

- (12) `Mesh_1` が選択されていることを確認する。
- (13) 線グループ `r1` を選択する。
- (14) `Wire Discretisation` を選択する。
- (15) `Number of Segments` を選択する。
- (16) 分割数を `12` とする。

![サブメッシュ設定を確認する](img/002_stirrer/page_145.svg)

- サブメッシュ条件が対象線グループに設定されていることを確認する。

![再計算する](img/002_stirrer/page_146.svg)

- (17) `Mesh_1` を選択した状態で `Compute` をクリックし、メッシュを再計算する。
- メッシュ情報を確認する。

![再計算結果を確認する](img/002_stirrer/page_147.svg)

- サブメッシュ指定により、対象部分の分割数が変わったことを確認する。

![最終メッシュを確認する](img/002_stirrer/page_148.svg)

- ここでは `r1` 方向の分割数変更のみ確認したが、実際には他の方向（`r2`〜`r6`、`theta1`、`z3`）の線グループにも同様の手順でサブメッシュを設定する。

### 3. 全方向のサブメッシュを設定してメッシュを完成させる

![サブメッシュ一覧を確認する](img/002_stirrer/page_150.svg)

- `r1`〜`r6`、`theta1`、`z3` すべての線グループに対して、同様にサブメッシュ（`Number of Segments`）を設定する。
- `SubMeshes on Compound` の下に、設定した数だけサブメッシュが並んでいることを確認する。

![全体を再計算する](img/002_stirrer/page_151.svg)

- (17) `Mesh_1` を選択した状態で `Compute` をクリックし、全方向のサブメッシュを反映してメッシュを再計算する。
- メッシュ情報を確認する（例: ノード数 238239、ヘキサヘドロン数 223776）。

![拡大してメッシュ品質を確認する](img/002_stirrer/page_152.svg)

- 羽根の根本や角部を拡大し、メッシュが歪みなく生成されていることを確認する。

![Save Asで保存する](img/002_stirrer/page_153.svg)

- (18) `File` > `Save As...` で名前を付けて保存する。
- (19) `Save` をクリックする。

### 4. OpenFOAM用にUNV出力する

![Groups of Edgesを削除する](img/002_stirrer/page_154.svg)

- (1) `Groups of Edges` を削除する。
- 補足: 線グループ（サブメッシュ分割用）はOpenFOAM変換に不要なため、削除して境界名の混乱を避ける。`Groups of Faces` はOpenFOAMの境界パッチ名として引き継がれるため残す。

![UNV形式でエクスポートする](img/002_stirrer/page_155.svg)

- (2) `Mesh_1` 上で右クリックし、`Export` > `UNV file` を選ぶ。
- (3) `Save` をクリックし、`Mesh_1.unv` として保存する。

---

## OpenFOAM側での計算

SALOMEから出力した `Mesh_1.unv` は、そのままではOpenFOAMで使えない。UNV形式からOpenFOAM形式へ変換し、スケール変換（mm→m）を行った上で、羽根（wing）と仕切り板（circ）の位置に `topoSet` + `createBaffles` でバッフル（厚みゼロの内部壁）を作成する。

SALOME で作成したメッシュを OpenFOAM 形式に変換して利用する。全体の流れは以下の通り。

![SALOMEからOpenFOAMへの連携フロー](img/000_salome/salome_to_openfoam_flow.png)

- 作業フォルダ: `data/002_Stirrer/sample/mesh/mesh_of13`

### メッシュ変換とバッフル作成

```bash
cd data/002_Stirrer/sample/mesh/mesh_of13
. /opt/openfoam13/etc/bashrc

ideasUnvToFoam Mesh_1.unv > log.ideasUnvToFoam 2>&1
transformPoints "scale=(0.001 0.001 0.001)" > log.transformPoints 2>&1
checkMesh > log.checkMesh.initial 2>&1

topoSet > log.topoSet 2>&1
createBaffles -overwrite > log.createBaffles 2>&1
checkMesh > log.checkMesh.final 2>&1
```

なお、同フォルダには上記一連の処理をまとめた `Allrun` スクリプトがあり、`./Allclean && ./Allrun` で最初から一括再実行できる。

各コマンドの役割は以下の通り。

- `ideasUnvToFoam Mesh_1.unv`: SALOMEから出力したUNVメッシュを、OpenFOAMの `constant/polyMesh` 形式へ変換する。
- `transformPoints "scale=(0.001 0.001 0.001)"`: 全座標を1/1000倍する。SALOMEはmm単位で形状を作っているため、OpenFOAMが使うm単位へスケール変換する。
- `checkMesh`（1回目）: 変換直後のメッシュ品質・セル数・境界面を確認する。
- `topoSet`: `system/topoSetDict`（`topoSetDict.wing` / `topoSetDict.circ` / `topoSetDict.rotor` をinclude）に従い、羽根・仕切り板・回転領域の3種類のゾーンを作成する（内容は次節）。
- `createBaffles -overwrite`: `system/createBafflesDict` に従い、topoSetで作った羽根・仕切り板の面ゾーンを厚みゼロの `wall` バッフルへ変換する。`owner`/`neighbour` それぞれに `_master` / `_slave` のパッチ名を与え、羽根・仕切り板の両面を表現する。
- `checkMesh`（2回目）: バッフル作成後のメッシュ品質を再確認し、`Mesh OK` になっていることを確認する。

### topoSetで作成する3種類のゾーン

`topoSet` では、後工程で使う次の3種類のゾーンをメッシュ上に定義する。wing / circ は `createBaffles` でバッフル化するための**面ゾーン（faceZone）**、rotor は回転計算用の**セルゾーン（cellZone）**である。

**1. 羽根（wing）の面ゾーン**

`wingFaceZone` / `wingFaceZone2` は、羽根の位置にある面のゾーン（上下2枚分）。羽根のパーティション面はセクターの二等分線（30°）上にあるため、`rotatedBoxToFace` で30°回転させた薄い直方体を使って面を選び出す。

- 補足: 選択ボックスの境界がメッシュの面中心の座標とちょうど一致すると、端の面が拾われたり拾われなかったりして羽根のエッジがガタつく。これを避けるため、ボックスのz範囲は羽根より半セル分広げ、`normalToFace` で羽根の垂直面だけに絞っている。

![topoSetで作成したwingFaceZone / wingFaceZone2](img/002_stirrer/zone_wing.png)

**2. 仕切り板（circ）の面ゾーン**

`circularFaceZone_z015` / `circularFaceZone_z035` は、仕切り板の位置にある面のゾーン。`cylinderToFace` で薄いz範囲を直接指定して選び出す。

- 補足: シャフト（軸）がz=15mmまで刺さっているため、仕切り板はシャフト周りの環状の板になる。z=15mm平面にはシャフト底面（境界面）も含まれてしまうため、`boundaryToFace` の `action delete` で境界面を取り除き、内部面だけを残している。

![topoSetで作成したcircularFaceZone_z015 / circularFaceZone_z035](img/002_stirrer/zone_circ.png)

**3. 回転領域（rotor）のセルゾーン**

`rotor1` / `rotor2` は、羽根の周囲を囲む円柱状の回転領域のセルゾーン（MRFなど回転計算用）。`cylinderToCell` で円柱範囲を指定して作成する。

![topoSetで作成したrotor1 / rotor2セルゾーン](img/002_stirrer/zone_rotor.png)

### 羽根の可動化テスト（master_curve_of13）

羽根（`wall_wing.*` パッチ）に、コード化された点変位（`codedFixedValue`）でx位置に応じた曲線状の変位を与え、`displacementSBRStress` モーションソルバでメッシュ全体を滑らかに追従変形できるかを確認する。

- 作業フォルダ: `data/002_Stirrer/sample/mesh/master_curve_of13`（`mesh_of13` で作成したバッフル済みメッシュを引き継ぐ）

```bash
cd data/002_Stirrer/sample/mesh/master_curve_of13
. /opt/openfoam13/etc/bashrc

rm -rf 0
cp -r 0.orig 0

moveDynamicMesh > log.moveDynamicMesh 2>&1
checkMesh -latestTime > log.checkMesh 2>&1
```

- `constant/dynamicMeshDict` で `displacementSBRStress` モーションソルバを指定する。
- `0.orig/pointDisplacement` の `wall_wing.*` 境界に `codedFixedValue` を設定し、時刻 `t` に応じて羽根表面の点をy方向へ滑らかに変位させる。
- `system/controlDict` で `application moveDynamicMesh`、`endTime 1`、`deltaT 0.1` として、10ステップに分けてメッシュを追従変形させる。
- 各時刻（`0.1`〜`1`）でメッシュが破綻せず追従できているかを、最終時刻の `checkMesh` で確認する（`Mesh OK`）。

![羽根の変位に追従して変形したメッシュ（t=1）](img/002_stirrer/deformed_result.png)

- 羽根表面の変位に合わせて、周囲のメッシュも破綻せず滑らかに追従変形していることを確認する。

### 回転領域メッシュが動いてしまう問題と対処

このまま羽根を`moveDynamicMesh`で曲げると、**羽根だけでなく回転領域（rotor）のメッシュまで一緒に動いてしまう**（下のアニメーションで、羽根の変形が周囲へ広がり rotor 界面 r=35mm が円からずれる様子が確認できる）。

![羽根の変位にメッシュが追従変形するアニメーション](img/002_stirrer/ani_deform.gif)

回転領域に使用する rotor は円柱状のきれいな領域であってほしいので、これは望ましくない。

対処法は、メッシュの作り方によって2通りある。

**（1）別部品で作って後で貼り合わせる方法（サマースクール2020・技術書の方法）**

羽根を含む部品を**別メッシュ**として作り、`createBaffles`＋`moveDynamicMesh`で羽根だけを曲げてから、`mergeMeshes`／`stitchMesh`で rotor のメッシュに貼り合わせる。こうすると変形を羽根の部品内に閉じ込められる。この手順は技術書「OpenFOAMでメッシュ作成」に詳しく解説されているので、そちらを参照。

![別部品で作成しstitchMeshで貼り合わせる手順（サマースクール2020 Track3 p.37）](img/002_stirrer/2020_track3_p037_stitch.png)

**（2）一体もの（1つの連続メッシュ）の場合の対処法（今回の方法）**

今回のようにメッシュが一体で作られている場合は、貼り合わせができないので、**rotor の境界（r=35mm の円筒面）を固定してしまう**方法をとる。具体的には、

- `topoSet` で rotor1 / rotor2 セルゾーンの境界面を faceZone 化する。
- `createBaffles` でその面を固定壁パッチに変換する。
- `pointDisplacement` で `.*`（既定）が `fixedValue (0 0 0)` になっているため、この境界パッチも自動的に変位0で固定される。

これにより、変形は rotor 内部（羽根と境界の間）だけに閉じ込められ、**rotor 界面は円形を保ち、外側のメッシュは完全に静止する**（実測で外側の変位0.000mm・界面の半径ずれ0.05mm、`checkMesh` も `Mesh OK`）。

### 注意点：対処しないと回転領域まで動いてしまう

以下のアニメーションは、対処前（一体ものをそのまま曲げた場合）の変形過程である（マゼンタ: 羽根パッチ、緑: 仕切り板、黄: 上下の羽根高さの水平断面、淡青: 回転領域セルゾーン rotor1 / rotor2、左: メッシュ線あり、右: スムース表示）。羽根がy方向へ曲線状に変位し、周囲のメッシュ（rotor を含む）が追従して動いてしまっている。


