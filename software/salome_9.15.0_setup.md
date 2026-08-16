# SALOME 9.15.0 セットアップ手順

## 結局やること

新しい環境でSALOME 9.15.0を使えるようにする場合は、基本的に以下だけ行う。
今回の環境では、特に `software/install_salome_9.15.0_runtime_deps.sh` の実行が重要で、このスクリプトで不足していたランタイム依存をまとめて入れた後にSALOMEが起動した。

```bash
cd /mnt/f/work/002_CAE/openfoam/summerSchool/20260830_summerSchool2026

# 1. SALOMEをLinux側へ解凍する
mkdir -p /home/kamakiri/software
tar -xzf /mnt/d/software/SALOME-9.15.0-native-UB24.04-SRC.tar.gz -C /home/kamakiri/software

# 2. 必要なUbuntuパッケージをまとめて入れる
./software/install_salome_9.15.0_runtime_deps.sh

# 3. ~/.bashrcに起動エイリアスを追加する
cat >> ~/.bashrc <<'EOF'

# SALOME 9.15.0
alias salome.9.15.0='/home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC/salome'
EOF

# 4. 設定を読み込んで起動する
source ~/.bashrc
salome.9.15.0
```

すでに解凍済みで、依存パッケージも入っている場合は、以下だけでよい。

```bash
source ~/.bashrc
salome.9.15.0
```

依存パッケージだけを入れ直したい場合は、以下を実行する。

```bash
cd /mnt/f/work/002_CAE/openfoam/summerSchool/20260830_summerSchool2026
./software/install_salome_9.15.0_runtime_deps.sh
```

## 今回の結果

SALOME 9.15.0 は起動確認済み。

起動コマンド:

```bash
salome.9.15.0
```

確認用コマンド:

```bash
salome.9.15.0 info
```

確認できた出力:

```text
Running with python 3.12.3
Salome 9.15.0
```

## 使用したアーカイブ

ダウンロード済みのSALOMEアーカイブは以下。

```bash
/mnt/d/software/SALOME-9.15.0-native-UB24.04-SRC.tar.gz
```

このパッケージは、SALOME 9.15.0のソースとUbuntu 24.04向けバイナリを含む。通常利用ではソースビルドせず、同梱バイナリを展開して使う。

## 展開先

SALOME本体はLinux側のファイルシステムへ展開した。

```bash
/home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC
```

`/mnt/d` や `/mnt/f` はWindows側ファイルシステムをWSLから見ている場所である。SALOMEのアーカイブには多数のシンボリックリンクが含まれるため、Windows側マウントへ直接展開すると以下のようなエラーになる。

```text
Cannot create symlink ... Operation not permitted
```

そのため、アーカイブは `/mnt/d/software` に保存し、実行用の展開先は `/home/kamakiri/software` とした。

## 解凍

```bash
mkdir -p /home/kamakiri/software
tar -xzf /mnt/d/software/SALOME-9.15.0-native-UB24.04-SRC.tar.gz -C /home/kamakiri/software
```

展開後、以下を確認する。

```bash
ls /home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC
```

主なファイル:

```text
README
salome
mesa_salome
binsalome
env_launch.sh
install_bin.sh
sat/
BINARIES-UB24.04/
ARCHIVES/
```

## 依存パッケージ

SALOME本体は展開するだけで入るが、起動にはUbuntu側のランタイムライブラリが必要になる。不足ライブラリが順番に出るのを避けるため、以下のスクリプトでまとめて入れる。

```bash
cd /mnt/f/work/002_CAE/openfoam/summerSchool/20260830_summerSchool2026
./software/install_salome_9.15.0_runtime_deps.sh
```

スクリプト:

```bash
software/install_salome_9.15.0_runtime_deps.sh
```

このスクリプトは `sudo apt install` を使うため、実行時にsudoパスワードを入力する。

依存パッケージの整理では、SALOME DiscourseのUbuntu 24.04向け起動問題の投稿も参考にした。

```text
https://discourse.salome-platform.org/t/salome-9-14-run-problem-on-ubuntu-24-04/1794
```

この投稿では、SALOME 9.14のUbuntu 24.04用バイナリでも多数のランタイム依存が不足する例が示されている。SALOME側の回答では、Ubuntu 24.04向けの依存リストはSALOME 9.13以降で更新されており、対応方法は以下のどちらかと説明されている。

- 不足として報告されたUbuntuパッケージをインストールする
- 必要なシステム依存を同梱したuniversal binaryを使う

今回はダウンロード済みのUbuntu 24.04向けSALOME 9.15.0を使うため、前者の方針で `install_salome_9.15.0_runtime_deps.sh` にランタイム依存をまとめた。

## エイリアス設定

毎回フルパスを入力しなくてよいように、`~/.bashrc` に以下を追加した。

```bash
# SALOME 9.15.0
alias salome.9.15.0='/home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC/salome'
```

反映:

```bash
source ~/.bashrc
```

確認:

```bash
type salome.9.15.0
```

起動:

```bash
salome.9.15.0
```

## 通常起動とMESA起動

エイリアスを使わずに起動する場合:

```bash
/home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC/salome
```

リモート接続やX11転送で3D表示が不安定な場合は、MESA版ランチャを使う。

```bash
/home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC/mesa_salome
```

## 依存確認

SALOME付属の `sat` で依存パッケージを確認できる。

```bash
cd /home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC
HOME=/tmp/salome_check_home ./sat/sat config SALOME-9.15.0-native --check_system
```

## 起動時に出た主なエラー

今回、起動までに以下の不足が出た。現在は依存パッケージのインストールにより解消済み。

### Python psutil不足

```text
ModuleNotFoundError: No module named 'psutil'
```

対応:

```bash
sudo apt install python3-psutil
```

### Graphviz系ライブラリ不足

```text
libcdt.so.5: cannot open shared object file
libcgraph.so.6: cannot open shared object file
```

対応:

```bash
sudo apt install libcdt5 libcgraph6 libgvc6 libpathplan4 graphviz
```

### Boost filesystem不足

```text
libboost_filesystem.so.1.83.0: cannot open shared object file
```

対応:

```bash
sudo apt install libboost-filesystem1.83.0
```

### Qt X11 Extras不足

```text
libQt5X11Extras.so.5: cannot open shared object file
```

対応:

```bash
sudo apt install libqt5x11extras5
```

### HDF5 C++ランタイム不足

```text
libhdf5_serial_cpp.so.103: cannot open shared object file
```

対応:

```bash
sudo apt install libhdf5-cpp-103-1t64
```

## ソースビルドについて

この配布物にはソースも含まれているが、通常の講習利用ではソースビルドは不要である。READMEでは、ソースを準備・ビルドする場合のコマンドとして以下が示されている。

```bash
cd /home/kamakiri/software/SALOME-9.15.0-native-UB24.04-SRC
./sat/sat prepare SALOME-9.15.0-native
./sat/sat -t compile SALOME-9.15.0-native
```

ただし、ソースビルドには多数の開発パッケージが必要になる。今回は同梱バイナリを使う方針とする。
