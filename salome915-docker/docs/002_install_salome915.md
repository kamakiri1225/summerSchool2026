# 002. SALOME 9.15をDockerイメージにインストールする

## 目的

Windows上のDocker Desktopを使って、Ubuntu 24.04 / `linux/amd64` のコンテナに SALOME 9.15 を組み込み、`salome915` という名前のDockerイメージを作成する。

最終的には、同じDockerイメージをWindowsとMacの両方で利用できるようにする。

GUIはブラウザではなく、SALOME本来のGUIウィンドウを直接表示する方式とする（起動方法は [003_launch_salome.md](003_launch_salome.md) を参照）。

```text
Windows / Mac
    ↓
Docker Desktop
    ↓
linux/amd64
    ↓
Ubuntu 24.04
    ↓
SALOME 9.15
    ↓
X11でGUI表示
```

WindowsではWSLg、MacではXQuartzを使う。

このドキュメントでは [000_docker_setup.md](000_docker_setup.md) でDockerの土台ができている前提で、SALOME本体をイメージへ組み込むところまでを扱う。

---

# 1. 前提

Windows側にはDocker Desktopをインストール済み。

WSL Ubuntuから以下が実行できることを確認する。

```bash
docker --version
```

さらに、

```bash
docker version
```

を実行し、ClientとServerの両方が表示されることを確認する。

今回の確認環境では、

```text
Client OS/Arch: linux/amd64
Server OS/Arch: linux/amd64
```

となっている。

---

# 2. Ubuntu 24.04 amd64 の動作確認

WSL側で、

```bash
docker run --rm -it --platform linux/amd64 ubuntu:24.04 bash
```

を実行する。

成功すると、

```text
root@xxxxxxxxxxxx:/#
```

のようになる。

コンテナ内で、

```bash
uname -m
```

を実行し、

```text
x86_64
```

になることを確認する。

続いて、

```bash
cat /etc/os-release
```

を実行し、Ubuntu 24.04であることを確認する。

確認後、

```bash
exit
```

で一時コンテナから抜ける。

重要:

`docker build` はこの一時コンテナ内では実行せず、WSL側の `salome915-docker` フォルダで実行する。

---

# 3. 作業フォルダ

今回の作業フォルダ:

```text
/mnt/f/work/002_CAE/openfoam/summerSchool/20260830_summerSchool2026/salome915-docker
```

移動:

```bash
cd /mnt/f/work/002_CAE/openfoam/summerSchool/20260830_summerSchool2026/salome915-docker
```

確認:

```bash
pwd
ls
```

最終的なフォルダ構成は次のようにする。

```text
salome915-docker/
├── Dockerfile
└── dist/
    └── SALOME-9.15.0-native-UB24.04-SRC.tar.gz
```

---

# 4. SALOME 9.15 本体を用意する

Ubuntu 24.04向けのSALOME 9.15配布ファイルを用意する。

使用するファイル:

```text
SALOME-9.15.0-native-UB24.04-SRC.tar.gz
```

このファイルはサイズが大きい（約3.8GB）ため、Gitリポジトリには含めていない。

SALOME公式サイトから各自ダウンロードする。

```text
https://www.salome-platform.org/?page_id=2430
```

「Downloads」ページでバージョン 9.15.0、OS Ubuntu 24.04（native/UB24.04-SRC）を選択してダウンロードする（ダウンロードにはフォームへの入力が必要）。

ダウンロードした `SALOME-9.15.0-native-UB24.04-SRC.tar.gz` を、

```text
salome915-docker/dist/
```

に置く。

```text
salome915-docker/
├── Dockerfile
└── dist/
    └── SALOME-9.15.0-native-UB24.04-SRC.tar.gz   ← ここに配置（Git管理外）
```

確認:

```bash
ls -lh dist
```

---

# 5. Dockerfile

`salome915-docker` フォルダに `Dockerfile` を作成する。

```dockerfile
# ============================================================
# SALOME 9.15.0 Docker image
#
# Base OS:
#   Ubuntu 24.04
#
# Architecture:
#   linux/amd64
#
# GUI:
#   Browser/noVNCは使わない。
#   SALOME本来のGUIをX11経由で直接表示する。
#
# Windows:
#   WSLg
#
# macOS:
#   XQuartz
# ============================================================

FROM ubuntu:24.04

# apt installの途中で対話入力を求められないようにする。
ENV DEBIAN_FRONTEND=noninteractive


# ------------------------------------------------------------
# 基本ツール
# ------------------------------------------------------------

RUN apt-get update &&     apt-get install -y --no-install-recommends         ca-certificates         wget         curl         tar         gzip         bzip2         xz-utils         procps         file     && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# X11 / OpenGL 関連
#
# SALOMEはQt/OpenGLを使うGUIアプリなので、
# X11とOpenGL関連ライブラリを入れる。
#
# x11-apps:
#   xclock等を使ってGUI転送のテストを行うために使用。
#
# mesa-utils:
#   OpenGL関連の動作確認に使用。
# ------------------------------------------------------------

RUN apt-get update &&     apt-get install -y --no-install-recommends         libgl1         libglu1-mesa         libglx-mesa0         libegl1         libx11-6         libxext6         libxrender1         libxi6         libxrandr2         libxcursor1         libxinerama1         libxfixes3         libxdamage1         libxcb1         libxkbcommon-x11-0         libfontconfig1         libfreetype6         libsm6         libice6         x11-apps         mesa-utils     && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# SALOMEランタイム依存ライブラリ
# ------------------------------------------------------------

RUN apt-get update &&     apt-get install -y --no-install-recommends         python3         python3-psutil         python3-numpy         python3-scipy         python3-matplotlib         python3-pandas         python3-h5py         python3-netcdf4         python3-cftime         python3-toml         python3-sip         python3-mpi4py         libcminpack1         libcdt5         libcgraph6         libgvc6         libpathplan4         graphviz         libboost-filesystem1.83.0         libboost-atomic1.83.0         libboost-system1.83.0         python3-pyqt5.qtsvg         libqt5x11extras5         libpcre3         libusb-1.0-0         libqwt-qt5-6         libexif12         libraw1394-11         libdc1394-25         libgphoto2-6t64         libgphoto2-port12t64         libxml++2.6-2v5         libnlopt0         libnlopt-cxx0         python3-nlopt         libhdf5-cpp-103-1t64         libopenblas0-serial         liblapacke         fftw-dev         libtiff6         libfreeimage3         libmetis5         libgdal34t64         libtbb12         libtk8.6     && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# SALOME本体をコンテナへコピー
# ------------------------------------------------------------

COPY dist/SALOME-9.15.0-native-UB24.04-SRC.tar.gz /tmp/salome.tar.gz


# ------------------------------------------------------------
# /opt/salome に展開
#
# --strip-components=1:
# tar.gz内の最上位フォルダを1段除いて展開する。
# ------------------------------------------------------------

RUN mkdir -p /opt/salome &&     tar -xzf /tmp/salome.tar.gz         -C /opt/salome         --strip-components=1 &&     rm -f /tmp/salome.tar.gz


# ------------------------------------------------------------
# SALOME実行用一般ユーザー
# ------------------------------------------------------------

RUN useradd         --create-home         --shell /bin/bash         salome &&     mkdir -p /work &&     chown -R salome:salome /work /home/salome


USER salome

ENV HOME=/home/salome

WORKDIR /work


# ------------------------------------------------------------
# Docker + X11でOpenGLを安定させるため、
# まずソフトウェアレンダリングを使う。
# ------------------------------------------------------------

ENV LIBGL_ALWAYS_SOFTWARE=1
ENV QT_X11_NO_MITSHM=1


# ------------------------------------------------------------
# WindowsとMacでDISPLAY設定が異なるため、
# イメージ起動時はbashに入る。
#
# GUI接続確認後にSALOMEを起動する。
# ------------------------------------------------------------

CMD ["/bin/bash"]
```

---

# 6. Dockerイメージをビルド

`Dockerfile` のあるフォルダで実行する。

```bash
docker build --platform linux/amd64 -t salome915 .
```

コマンドの意味：

```text
docker build
→ Dockerfileからイメージを作成する

--platform linux/amd64
→ Intel/AMD 64bit Linux 向けにビルドする、と明示的に指定する。
  Windows PCは元々amd64なので通常は省略しても同じ結果になるが、
  「Macで動かすときも同じamd64イメージにする」という意図を明記するため、
  最初から付けておく。

-t salome915
→ 出来上がったイメージに salome915 という名前(タグ)を付ける。
  以後は docker run 等でこの名前を使ってイメージを指定できる。

.（末尾のピリオド）
→ ビルドコンテキスト（Dockerfileや、COPYでイメージに入れるファイルを探す基準フォルダ）を
  「今いるフォルダ」にする、という指定。今回は salome915-docker/ で実行するので、
  Dockerfile自身や dist/ 以下のファイルがこの基準から見つかる。
```

この処理では、

```text
Ubuntu 24.04取得
↓
依存ライブラリのインストール
↓
SALOME 9.15のtar.gzをコピー
↓
/opt/salomeへ展開
↓
Dockerイメージ salome915 完成
```

という処理が行われる。

SALOME本体が大きいため、初回ビルドには時間がかかる。

---

# 7. ビルド結果を確認

ビルド完了後、

```bash
docker images
```

を実行する。

以下のように、

```text
REPOSITORY    TAG
salome915     latest
```

が表示されればイメージ作成成功。

---

# 8. 現在地

現在、以下まで完了している。

- [x] WindowsへDocker Desktopをインストール
- [x] WSL Integrationを有効化
- [x] WSLからDocker CLIを利用可能
- [x] Docker Engineへの接続確認
- [x] `linux/amd64` で動作していることを確認
- [x] Ubuntu 24.04コンテナ起動確認
- [x] SALOME 9.15用Dockerfileを作成
- [ ] `docker build --platform linux/amd64 -t salome915 .` 完了
- [ ] `docker images` でイメージ確認

イメージが完成したら、[003_launch_salome.md](003_launch_salome.md) でSALOMEのGUIを起動する。
