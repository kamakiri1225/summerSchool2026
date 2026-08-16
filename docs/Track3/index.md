# Track3: SALOMEを使ったOpenFOAMメッシュ作成

## 概要

SALOME 9.15 を使って OpenFOAM 用のメッシュを作成する。

- ヘキサメッシュ（六面体メッシュ）の作成方法
- マルチリージョン（複数領域）に対応したメッシュ作成

---

## ダウンロード

| 配布元 | URL | 特徴 |
|--------|-----|------|
| Code_Aster 付属版 | https://www.code-aster.org/ | 構造解析ソフト Code_Aster とセット。**通常はこちら** |
| Salome Platform（EDF） | https://www.salome-platform.org/ | 開発元フランス電力 EDF のサイト。Code_Aster は含まないが最新版を入手可能 |

---

## 講義の全体像

この講義では SALOME を使って OpenFOAM 用メッシュを作成するスキルを段階的に習得する。

![講義の全体像](memo/1.png)

| ステップ | 演習 | 学ぶこと | ファイル |
|----------|------|----------|----------|
| 0 | SALOME導入 | SALOME の概要・モジュール・OpenFOAM との連携 | [000_salome.md](000_salome.md) |
| 1 | 基礎練習（Box） | SALOME の基本操作・境界層・OpenFOAM 変換 | [001_box.md](001_box.md) |
| 2 | 撹拌機 | ヘキサメッシュで複雑形状を作成する方法 | [002_stirrer.md](002_stirrer.md) |
| 3 | ヒートシンク | マルチリージョンメッシュ・熱流体固体連成 | [003_heatsink.md](003_heatsink.md) |

**到達目標**

- SALOME で OpenFOAM 用メッシュを一から作れる
- ヘキサメッシュ（六面体メッシュ）を使いこなせる
- 複数領域（マルチリージョン）に対応したメッシュを作れる
