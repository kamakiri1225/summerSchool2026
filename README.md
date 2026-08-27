# summerSchool2026

オープンCAE学会 サマースクール2026（2026年8月30日）Track3「SALOMEを使ったOpenFOAMメッシュ作成」の講義資料。

SALOME でジオメトリ・メッシュを作成し、OpenFOAM 用に変換して計算するまでの一連の流れを、直方体（Box）・撹拌機（Stirrer）・ヒートシンク（Heatsink）の3つの題材で段階的に学ぶ。

- `docs/Track3/` — 講義資料（HTML・スライド）
- `data/` — 各題材のSALOMEモデル・OpenFOAMケース一式（重い計算結果ファイルは除く）

## クローンして実行する

このリポジトリをクローンすれば、各演習のOpenFOAMケースをそのまま実行できる。

```bash
git clone https://github.com/kamakiri1225/summerSchool2026.git
```

各ケースフォルダで、対応するOpenFOAM環境を読み込んでから `./Allrun` を実行する。

| ケース | OpenFOAM環境 | 実行 |
|--------|--------------|------|
| `data/001_box/run001_of13` | `source /opt/openfoam13/etc/bashrc` | `./Allrun`（UNV変換〜foamRun、90反復で収束） |
| `data/001_box/run001_of2512` | `source /usr/lib/openfoam/openfoam2512/etc/bashrc` | `./Allrun`（UNV変換〜simpleFoam、80反復で収束） |
| `data/002_Stirrer/sample/mesh/mesh_of13` | OpenFOAM 13 | `./Allrun`（UNV変換〜topoSet〜createBaffles） |
| `data/002_Stirrer/sample/mesh/master_curve_of13` | OpenFOAM 13 | `./Allrun`（rotor固定〜羽根変形〜stitchMesh） |
| `data/002_Stirrer/sample/mesh/fullmodel_of13` | OpenFOAM 13 | `./Allrun`（※先に `master_curve_of13` を実行しておく） |
| `data/002_Stirrer/sample/mesh/mesh_of2512` | OpenFOAM v2512 | `./Allrun` |
| `data/002_Stirrer/sample/mesh/master_curve_of2512` | OpenFOAM v2512 | `./Allrun` |
| `data/002_Stirrer/sample/mesh/fullmodel_of2512` | OpenFOAM v2512 | `./Allrun`（※先に `mesh_of2512` → `master_curve_of2512` を実行しておく） |
| `data/003_heatsink/run001_of13` | OpenFOAM 13 | `./Allrun`（setup.sh〜foamMultiRun。計算は数時間） |
| `data/003_heatsink/run001_of2512` | OpenFOAM v2512 | `./Allrun`（setup.sh〜chtMultiRegionFoam。計算は1時間程度） |

- 003の計算は長時間かかるが、途中で止めても `./Allrun` の再実行で続きから計算される。
- Windows（WSL）の `/mnt/c` などWindows側ドライブで実行する場合の注意は、各 `Allrun` 内のコメントを参照。

## 公開ページ

https://kamakiri1225.github.io/summerSchool2026/

- [講義目次](https://kamakiri1225.github.io/summerSchool2026/Track3/index.html)
- [000 SALOMEとは](https://kamakiri1225.github.io/summerSchool2026/Track3/000_salome.html)
- [001 Box: SALOMEでOpenFOAM用メッシュを作る](https://kamakiri1225.github.io/summerSchool2026/Track3/001_box.html)
- [002 Stirrer: SALOMEで撹拌機のヘキサメッシュを作る](https://kamakiri1225.github.io/summerSchool2026/Track3/002_stirrer.html)
- [003 Heatsink: SALOMEでヒートシンクの熱流体・固体連成メッシュを作る](https://kamakiri1225.github.io/summerSchool2026/Track3/003_heatsink.html)
- [SALOMEのインストール（Windows / Mac）](https://kamakiri1225.github.io/summerSchool2026/Track3/install_salome.html)
