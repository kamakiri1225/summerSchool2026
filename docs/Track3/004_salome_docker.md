# 004 Mac向け: DockerでSALOME 9.15を使う

SALOMEのWindows版はzipを展開するだけで使えるが、**Mac向けのSALOME配布は無い**。そこでMacの受講者は、Dockerを使ってLinux版のSALOME 9.15を動かす。

講義用に、Ubuntu 24.04にSALOME 9.15を組み込んだDockerイメージを **Docker Hub** で公開している。受講者はこのイメージを取得（pull）するだけで、SALOMEのインストール作業なしで使える。

- Docker Hub: Dockerイメージの公開・共有サービス（アプリのアプリストアのようなもの）。`docker pull イメージ名` でイメージを取得できる。
- 講義用イメージ: `kamakiri734/salome915:2026-08-30`

```text
Mac
 ↓
Docker Desktop をインストール
 ↓
XQuartz をインストール（GUI表示用）
 ↓
Docker Hub からイメージを pull
 ↓
docker run でコンテナ起動
 ↓
SALOME 9.15 のGUIがMacに表示される
```

---

## 1. Docker Desktop をインストールする

以下からDocker Desktop for Macをダウンロードしてインストールする。

```text
https://www.docker.com/products/docker-desktop/
```

- 自分のMacが **Apple Silicon**（M1/M2/M3等）か **Intel** かに合わせたインストーラを選ぶ。
- インストール後、Docker Desktopを起動したままにしておく（左下に `Engine running` と表示されていればOK）。

---

## 2. XQuartz をインストールする

SALOMEのGUIをMacの画面に表示するために、X11サーバのXQuartzを使う。

```text
https://www.xquartz.org/
```

からダウンロードしてインストールする。インストール後、一度ログアウト/再ログイン（またはMac再起動）が必要な場合がある。

### XQuartzの設定

XQuartzを起動し、メニューから、

```text
XQuartz → 設定（Preferences） → セキュリティ（Security）
```

を開き、

```text
Allow connections from network clients
```

にチェックを入れる。設定後、XQuartzを再起動する。

### X11接続を許可する

Macのターミナルで実行する。

```bash
xhost +localhost
```

---

## 3. Docker Hub からイメージを取得する

Macのターミナルで実行する。

```bash
docker pull --platform linux/amd64 kamakiri734/salome915:2026-08-30
```

- SALOMEのLinux版はx86_64（amd64）専用のため、`--platform linux/amd64` を明示する。Apple Silicon Macではエミュレーションで動作する。
- イメージには SALOME 9.15 本体と必要なライブラリがすべて入っているため、数GBのダウンロードになる。**講義当日ではなく事前に**取得しておくこと。

---

## 4. コンテナを起動する

作業フォルダを用意する（SALOMEで保存したファイルはここに残る）。

```bash
mkdir -p ~/salome_work
```

コンテナを起動する。

```bash
docker run --rm -it --platform linux/amd64 -e DISPLAY=host.docker.internal:0 -v ~/salome_work:/work kamakiri734/salome915:2026-08-30
```

- `-e DISPLAY=host.docker.internal:0`: コンテナの中のSALOMEに、Macホスト上のXQuartzへ画面を表示させる指定。
- `-v ~/salome_work:/work`: Mac側の `~/salome_work` をコンテナ内の `/work` として共有する。

成功すると、

```text
salome@xxxxxxxx:/work$
```

のようなプロンプトになる。

---

## 5. GUI表示を確認してSALOMEを起動する

まず動作確認として、コンテナ内で、

```bash
xclock
```

を実行する。Macのデスクトップに時計のウィンドウが表示されればGUI表示は成功。`xclock` を終了して、

```bash
/opt/salome/mesa_salome
```

を実行すると、SALOME 9.15のGUIがMacに表示される。

---

## うまくいかないとき

- `docker: image not found` 等が出る → `docker pull` からやり直す。タグ（`2026-08-30`）の打ち間違いがないか確認する。
- GUIが表示されない → XQuartzの `Allow connections from network clients` 設定と、`xhost +localhost` を再確認する。
- 動作が重い → ソフトウェアレンダリング＋Apple Siliconのエミュレーションのため、3D表示はネイティブより遅くなる。事前にシンプルな操作で一度動作確認しておくとよい。

---

Windowsの受講者向けの手順（WSLg利用）を含む詳細は、リポジトリの `salome915-docker/README.md` を参照。
