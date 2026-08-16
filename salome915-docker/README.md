# SALOME 9.15.0をDocker + ブラウザ(noVNC)で使えるようにする手順

## 目的

サマースクールの受講者がWindows/Macどちらでも、追加のXサーバー設定（VcXsrv, XQuartzなど）なしに、Docker DesktopとWebブラウザだけでSALOME 9.15.0のGUIを使えるようにする。

全体の流れ:

```text
あなたのWindows PC
    ↓
Docker Desktop
    ↓
linux/amd64 Ubuntu 24.04
    ↓
SALOME 9.15 (mesa_salome + Xvfb + x11vnc + noVNC)
    ↓
ブラウザでGUI表示できるDockerイメージ完成
    ↓
Docker Hubへ公開
    ↓
Windows / Mac の受講者が docker pull して使う
```

コンテナ内部の構成:

```text
Xvfb (仮想ディスプレイ)
  → x11vnc (VNCで配信)
    → websockify + noVNC (VNCをWebSocket化し、ブラウザ向けにHTML/JSを配信)
      → ブラウザで http://localhost:6080/vnc.html を開くとSALOMEの画面が見える
SALOME本体は mesa_salome (ソフトウェアレンダリング版) で起動する。
```

SALOME公式README（`$ROOT/README`）に「OpenGLをX11フォワーディング越しに使うとセグフォルトする」と明記されており、その回避策が`mesa_salome`。コンテナ越しの表示も同じ状況のため、最初からMESA版で起動する構成にしてある。

## 事前に用意したファイル

- `salome915-docker/Dockerfile`
- `salome915-docker/entrypoint.sh`
- `salome915-docker/dist/SALOME-9.15.0-native-UB24.04-SRC.tar.gz`（実機で動作確認済みのSALOME 9.15.0 Ubuntu 24.04バイナリをtar.gz化したもの。約3.8GB。サイズが大きいためgit管理はしていない）

`dist/` にtar.gzが無いとビルドできないため、Windows/WSL環境で作成したファイルをコピーしてから進める。

## 1. Windows PCにDocker Desktopをインストール

https://docs.docker.com/desktop/setup/install/windows-install/ から、**「Docker Desktop for Windows - x86_64」**（通常のexeインストーラー）をダウンロードしてインストールする。

- Microsoft Store版は、Dドライブへのインストール先変更（`software/salome_docker_windows_d_drive_setup.md`参照）ができないため使わない。
- 「Arm (Early Access)」は、通常のIntel/AMD PCでは不要。

インストール後、WSL2 backendを使う設定にする（初回起動時のセットアップで案内される）。

Fドライブの空き容量が少ない場合は、`software/salome_docker_windows_d_drive_setup.md` の手順でDocker本体とデータをDドライブへ移してから進める。

## 2. イメージをビルドする

PowerShellまたはWSL側で:

```bash
cd /path/to/20260830_summerSchool2026/salome915-docker
docker build --platform linux/amd64 -t salome9.15 .
```

3.8GBのtar.gz展開とapt installがあるため、初回ビルドは数分〜十数分かかる。

## 3. 動作確認（ローカル）

```bash
mkdir -p ~/salome_work

docker run -d --rm \
  --platform linux/amd64 \
  -p 6080:6080 \
  -v ~/salome_work:/work \
  --name salome9.15 \
  salome9.15
```

ブラウザで以下を開く:

```text
http://localhost:6080/vnc.html?autoconnect=true&resize=remote
```

数十秒ほどでSALOMEのGUIが表示されることを確認する。`-v ~/salome_work:/work` でホスト側とコンテナ内`/work`を共有しているので、Studyファイル等はここに保存すると講義後も残る。

終了する場合:

```bash
docker stop salome9.15
```

## 4. Docker Hubへ公開する

Docker Hubのアカウントを持っていない場合は https://hub.docker.com/ で作成する。

```bash
docker login

docker tag salome9.15 <dockerhubユーザー名>/salome9.15:latest
docker push <dockerhubユーザー名>/salome9.15:latest
```

イメージサイズは展開後で10GB前後になる想定。アップロードはネットワーク回線によってはかなり時間がかかるため、講義当日より前に余裕を持って行う。

公開範囲について: SALOME自体はLGPLの無償ソフトウェアで、公式サイトからも誰でもダウンロード可能なため、Docker Hubで公開すること自体に問題はない。ただし一度Publicで公開すると誰でもpullできる状態になる点は認識しておく。学内限定にしたい場合はDocker Hubのprivateリポジトリ（無料枠あり）を使う。

## 5. 受講者側の使い方（Windows / Mac共通）

### Windowsの受講者

1. Docker Desktop for Windowsをインストール（手順1と同じ）。
2. 以下を実行:
   ```powershell
   docker run -d --rm -p 6080:6080 -v $HOME\salome_work:/work --name salome9.15 <dockerhubユーザー名>/salome9.15:latest
   ```
3. ブラウザで `http://localhost:6080/vnc.html?autoconnect=true&resize=remote` を開く。

### Macの受講者

1. Docker Desktop for Mac（Apple Silicon版 or Intel版）をインストール。
2. 以下を実行:
   ```bash
   docker run -d --rm --platform linux/amd64 -p 6080:6080 -v ~/salome_work:/work --name salome9.15 <dockerhubユーザー名>/salome9.15:latest
   ```
3. ブラウザで `http://localhost:6080/vnc.html?autoconnect=true&resize=remote` を開く。

Apple Siliconの場合の注意:

- SALOMEのLinuxバイナリはx86_64専用（Arm版は配布されていない）ため、`--platform linux/amd64` を付けてRosetta 2エミュレーションで動かす。
- Docker Desktopの設定 (Settings > General) で「Use Rosetta for x86_64/amd64 emulation on Apple Silicon」を有効にしておくと性能が改善する。
- ソフトウェアレンダリング(mesa_salome) + エミュレーションが重なるため、3Dビューアの操作（回転・ズーム等）はWindowsのネイティブ環境より体感で遅くなる。事前に一度動作確認をしておくことを推奨する。

## 6. トラブルシューティング

### ブラウザを開いても真っ白/繋がらない

コンテナのログを確認する。

```bash
docker logs salome9.15
```

`Xvfb`、`x11vnc`、`websockify` がそれぞれ起動しているログが出ているか確認する。

### ポート6080が使用中

他のアプリが6080を使っている場合、ホスト側のポートを変える。

```bash
docker run -d --rm -p 16080:6080 -v ~/salome_work:/work --name salome9.15 <dockerhubユーザー名>/salome9.15:latest
```

その場合は `http://localhost:16080/vnc.html?autoconnect=true&resize=remote` を開く。

### SALOMEが起動しない・落ちる

```bash
docker exec -it salome9.15 bash
cat /home/salome/*.log 2>/dev/null
```

などでコンテナ内のログを確認する。`install_bin.sh` や `sat/sat config SALOME-9.15.0-native --check_system` はコンテナ内でも使える。

### 動作が重い

- ソフトウェアレンダリング(mesa_salome)を使っているため、GPUを使う場合に比べて3D表示は本質的に遅い。
- Apple Siliconの場合はさらにエミュレーションが重なる。大きいメッシュのプレビューなど負荷の高い操作は避け、シンプルなモデルで練習してから演習に臨む想定にする。

## 注意

- このDockerイメージは、実機（Windows/WSL）で動作確認済みのSALOME 9.15.0 Ubuntu 24.04バイナリをそのまま使っている。ただしコンテナ化・noVNC経由での動作は講義本番前に必ず一度通し確認を行うこと。
- Windowsへのネイティブインストール（`software/salome_9.15.0_setup.md`参照）の方が表示は安定するため、Docker版は「受講者が各自の環境にネイティブインストールできない場合の代替手段」として案内する想定。
