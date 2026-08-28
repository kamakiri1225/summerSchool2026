# AGENTS.md — 引き継ぎ資料（OpenCAEサマースクール2026 Track3）

このリポジトリで作業するエージェント（Codex等）向けの引き継ぎメモ。最終更新: 2026-08-23。

## このリポジトリは何か

オープンCAE学会サマースクール2026 Track3「SALOMEを使ったOpenFOAMメッシュ作成」の講義資料と、演習用のOpenFOAMケース一式。

- `docs/Track3/` — 講義資料。Markdown（`.md`）が原本で、pandocで `.html` とreveal.jsスライドを生成する。
- `data/` — 各演習のSALOMEメッシュ（UNV）・OpenFOAMケース・計算結果。
- `salome915-docker/` — Mac受講者向けにSALOME 9.15をDocker化する一式（Docker Hub `kamakiri734/salome915` で公開済み）。
- `software/` — SALOME 9.15のapt依存パッケージ一覧とベアメタル導入メモ。

## 最重要: ドキュメントのビルド手順

`docs/Track3/*.md` を編集したら、**必ず対応する `.html` とスライドを再生成してからコミットする**（`.md`だけ直して`.html`を放置しない）。

各ページのHTML再生成（`docs/Track3/` 内で実行）。数式（002の移流方程式など）を
含むため `--mathjax=<CDN>` を付ける（付けないとpandocがローカルパス
`/usr/share/javascript/mathjax/MathJax.js` を埋め込み、Pagesで数式が出ない）。
**重要**: `--mathjax` を付けるとpandocが `https://polyfill.io/...` のスクリプトも
自動挿入する。polyfill.io は乗っ取られてマルウェア配信元になった危険ドメインなので、
ビルド後に必ず `sed -i '/polyfill\.io/d' *.html` で除去する（MathJax 3には不要）。
**キャプションは付けない方針**なので `-f markdown-implicit_figures` を必ず付ける
（付けないとpandocが画像のalt文字列を `<figcaption>` として画像の下に出してしまう）:

```bash
MJ="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"
F="markdown-implicit_figures"   # 画像キャプション(figcaption)を出さない
pandoc 000_salome.md      -f "$F" -s -c pandoc.css --mathjax="$MJ" --metadata pagetitle="000 SALOMEとは" -o 000_salome.html
pandoc 001_box.md         -f "$F" -s -c pandoc.css --mathjax="$MJ" --metadata pagetitle="001 Box: SALOMEでOpenFOAM用メッシュを作る" -o 001_box.html
pandoc 002_stirrer.md     -f "$F" -s -c pandoc.css --mathjax="$MJ" --metadata pagetitle="002 Stirrer: SALOMEで撹拌機のヘキサメッシュを作る" -o 002_stirrer.html
pandoc 003_heatsink.md    -f "$F" -s -c pandoc.css --mathjax="$MJ" --metadata pagetitle="003 Heatsink: SALOMEでヒートシンクの熱流体・固体連成メッシュを作る" -o 003_heatsink.html
pandoc install_salome.md  -f "$F" -s -c pandoc.css --mathjax="$MJ" --metadata pagetitle="SALOME 9.15 のインストール（Windows / Mac）" -o install_salome.html
pandoc index.md           -f "$F" -s -c pandoc.css --mathjax="$MJ" --metadata pagetitle="Track3: SALOMEを使ったOpenFOAMメッシュ作成" -o index.html
sed -i '/polyfill\.io/d' *.html   # 危険なpolyfill.ioスクリプトを除去
```

スライド（`000〜003`を結合したreveal.js）の再生成:

```bash
MJ="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"
F="markdown-implicit_figures"
python3 memo/build_slides.py   # 000〜003.md を結合して slides.md を生成
pandoc slides.md -f "$F" -t revealjs -s --slide-level=2 -c slides.css --mathjax="$MJ" \
  -V revealjs-url=reveal.js -V theme=white -V transition=slide \
  -V width=1280 -V height=800 -V margin=0.06 \
  -V slideNumber=true -V showSlideNumber=all \
  -o slides.html --metadata title="Track3: SALOMEを使ったOpenFOAMメッシュ作成"
sed -i '/polyfill\.io/d' slides.html   # 危険なpolyfill.ioスクリプトを除去
```

コミット前チェック（リンク切れ検出）:

```python
# docs/Track3/ で実行。全mdの画像参照・md間リンクが実在するか確認する
python3 - <<'EOF'
import re, os
ok = True
for md in ['000_salome.md','001_box.md','002_stirrer.md','003_heatsink.md','index.md','004_salome_docker.md']:
    txt = open(md).read()
    refs = re.findall(r'!\[[^\]]*\]\(([^)]+)\)', txt) + \
           [l for l in re.findall(r'(?<!!)\[[^\]]*\]\(([^)]+)\)', txt) if not l.startswith('http') and not l.startswith('#')]
    for r in refs:
        if not os.path.exists(r):
            print(f"{md}: MISSING {r}"); ok = False
print("ALL LINKS OK" if ok else "BROKEN")
EOF
```

## 資料の構成

| ファイル | 内容 |
|----------|------|
| `index.md` | 講義全体像、SALOME/Salome-Mecaの違い、データフォルダ一覧 |
| `000_salome.md` | SALOME概要、Windowsインストール手順、モジュール、メッシュ種類、同梱メッシャー、OpenFOAM連携フロー |
| `001_box.md` | Box演習（メッシュ作成基礎〜OpenFOAM定常流体解析） |
| `002_stirrer.md` | 撹拌機演習（ヘキサメッシュ、topoSet/createBaffles、羽根可動化テスト） |
| `003_heatsink.md` | ヒートシンク演習（マルチリージョン、chtMultiRegionFoam） |
| `004_salome_docker.md` | Mac受講者向けDockerでSALOMEを動かす手順 |

## データフォルダとOpenFOAMバージョン（重要）

| 演習 | フォルダ | OpenFOAM |
|------|----------|----------|
| 001 Box | `data/001_box/run001_of13` | **OpenFOAM 13**（.org版、`foamRun -solver incompressibleFluid`） |
| 002 撹拌機（メッシュ変換・バッフル） | `data/002_Stirrer/sample/mesh/mesh_of13` | **OpenFOAM 13** |
| 002 撹拌機（羽根可動化テスト） | `data/002_Stirrer/sample/mesh/master_curve_of13` | **OpenFOAM 13**（`moveDynamicMesh`） |
| 003 ヒートシンク | `data/003_heatsink/run001_of2512` | **OpenFOAM v2512**（.com版、`chtMultiRegionFoam`、`bash setup.sh`で一括セットアップ） |

- 環境読み込み: OpenFOAM 13 = `. /opt/openfoam13/etc/bashrc`、v2512 = `source /usr/lib/openfoam/openfoam2512/etc/bashrc`。
- 013と2512でコマンドが異なる点に注意（例: transformPointsのオプション、solver名）。`_of2512`系のフォルダは古い実験が混ざることがあるので、資料が参照しているのは上表のフォルダのみ。

## 撹拌機topoSetの注意（過去に修正済み・再発しやすい）

`data/002_Stirrer/sample/mesh/mesh_of13/system/topoSetDict.{wing,circ,rotor}` は羽根/仕切り板/回転領域のゾーンを作る。過去に以下を修正済み（`./Allclean && ./Allrun` で再現、checkMesh OKを確認すること）:

- **wing**: 選択ボックスのz境界がメッシュ面中心とちょうど一致すると端の面が不揃いに拾われ、羽根エッジがガタつく。ボックスを半セル分広げ `normalToFace` で垂直面に絞り、上下とも480面の長方形にした。
- **circ**: z=15mm平面にシャフト底面（境界面）が混ざる。`boundaryToFace` の `action delete` で除外し、上下とも576面の環状にした。

これらのゾーン画像（`docs/Track3/img/002_stirrer/zone_*.png`）とアニメーション（`ani_deform.gif`）はpvpythonで再生成している。`deformed_result.png` / `zone_*.png` は `data/.../img/` 側にも同じものをコピーして同期している（data側は古いまま放置されがちなので注意）。

## 画像生成ツール（この環境で使えるもの）

- **SVG→PNG**: `python3 -c "import cairosvg; cairosvg.svg2png(url=..., write_to=..., output_width=1440)"`（`convert`はSVGの日本語埋め込みフォントを潰すので不可）
- **PDF→PNG**: `gs -dNOPAUSE -dBATCH -sDEVICE=png16m -r150 -dFirstPage=N -dLastPage=N -sOutputFile=out.png in.pdf`
- **ParaViewバッチ**: `pvpython script.py`（`DISPLAY=:0` のWSLgで動作。cellZoneは直接読めないので `foamToVTK -cellSet <name>` でVTK化してから描画。`pointDisplacement`変換でFPEクラッシュする場合は `-noPointValues -fields '()'` を付ける）
- **模式図**: matplotlib（3Dは壊れているので手動等角投影で2D描画。日本語は `/home/kamakiri/.fonts/NotoSansCJKjp-*.otf` をaddfontして `Noto Sans CJK JP`）
- 元PDF: `docs/Track3/img/20260830_サマースクール2026ネタ.pdf`（講義スライドの原本。ページ抜き出しでスクショを差し替えることが多い）

## git運用

- ブランチは `main`、都度コミット＆`git push origin main`。コミットメッセージ末尾のCo-Authored-By行は付ける。
- `.gitignore` は allowlist方式（`/*` を除外して必要なものだけ `!` で許可）。新しい拡張子/フォルダを追跡させたいときは `.gitignore` の追記が必要。
- `salome915-docker/dist/*.tar.gz`（SALOME本体3.8GB）は除外済み。公式サイトから各自DLする前提で `docs/002_install_salome915.md` に記載。

## ユーザーの好み・作業スタイル

- 依頼は小刻みで、資料の1文・1画像単位の修正が多い。編集したら都度ビルド→pushまで完了させる。
- 図は「AIっぽくない」教科書調（白背景・黒線・単色薄塗り）を好む。派手な装飾は避ける。
- 注意書きは箇条書きの `- ※ ...` 形式を好む。
- 応答は日本語。
