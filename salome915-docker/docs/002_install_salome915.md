# SALOME 9.15.0 を Docker にインストールして起動する手順

## 1. 構成

Windows + Docker Desktop + WSL2 + WSLg 上で、Ubuntu 24.04 の Docker コンテナに SALOME 9.15.0 を入れて動かす。

構成は以下。

```text
Windows
  │
  ├─ Docker Desktop
  │    └─ WSL2 backend
  │
  └─ Ubuntu (WSL2)
       │
       └─ Docker
            │
            └─ Ubuntu 24.04 container
                 │
                 └─ SALOME 9.15.0
                      │
                      └─ WSLg 経由で GUI 表示
```

Docker イメージは以下。

```text
Ubuntu 24.04
linux/amd64
SALOME 9.15.0
```

---

## 2. Docker Desktop の準備

Docker Desktop をインストールする。

Docker Desktop の設定で以下を有効にする。

```text
Use WSL 2 based engine
```

さらに、

```text
Settings
→ Resources
→ WSL Integration
```

から、使用する Ubuntu を有効にする。

---

## 3. WSL から Docker が使えることを確認

Ubuntu を起動して実行。

```bash
docker version
```

Client と Server の両方が表示されれば OK。

Ubuntu 24.04 の amd64 コンテナも確認する。

```bash
docker run --rm -it --platform linux/amd64 ubuntu:24.04 bash
```

コンテナ内で、

```bash
uname -m
```

以下なら OK。

```text
x86_64
```

終了。

```bash
exit
```

---

## 4. SALOME 9.15.0 を用意

使用するファイル。

```text
SALOME-9.15.0-native-UB24.04-SRC.tar.gz
```

作業ディレクトリへ移動。

```bash
cd /mnt/f/work/002_CAE/openfoam/summerSchool/20260830_summerSchool2026
```

Docker 用ディレクトリを作成。

```bash
mkdir -p salome915-docker/dist
```

最終的な構成。

```text
salome915-docker/
├── Dockerfile
├── .dockerignore
└── dist/
    └── SALOME-9.15.0-native-UB24.04-SRC.tar.gz
```

SALOME の tar.gz を `dist` に配置する。

---

## 5. Dockerfile を作成

```bash
cd /mnt/f/work/002_CAE/openfoam/summerSchool/20260830_summerSchool2026/salome915-docker
```

```bash
vi Dockerfile
```

以下を保存する。

```dockerfile
# ============================================================
# SALOME 9.15.0
# Ubuntu 24.04 / linux-amd64
#
# Windows:
#   Docker Desktop + WSL2 + WSLg
#
# GUI:
#   X11 / WSLg
#
# SALOME:
#   SALOME-9.15.0-native-UB24.04-SRC.tar.gz
# ============================================================

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive


# ------------------------------------------------------------
# 基本ツール
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        curl \
        tar \
        gzip \
        bzip2 \
        xz-utils \
        procps \
        file \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# X11 / OpenGL
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1 \
        libglu1-mesa \
        libglx-mesa0 \
        libegl1 \
        libopengl0 \
        libglvnd0 \
        libdrm2 \
        libx11-6 \
        libx11-xcb1 \
        libxext6 \
        libxrender1 \
        libxi6 \
        libxrandr2 \
        libxcursor1 \
        libxinerama1 \
        libxfixes3 \
        libxdamage1 \
        libxss1 \
        libxft2 \
        libxmu6 \
        libxpm4 \
        libxt6 \
        libxcb1 \
        libxcb-glx0 \
        libxcb-xfixes0 \
        libxcb-xkb1 \
        libxkbcommon0 \
        libxkbcommon-x11-0 \
        libfontconfig1 \
        libfreetype6 \
        libsm6 \
        libice6 \
        x11-apps \
        mesa-utils \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# Python
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-psutil \
        python3-numpy \
        python3-scipy \
        python3-matplotlib \
        python3-pandas \
        python3-h5py \
        python3-netcdf4 \
        python3-cftime \
        python3-toml \
        python3-sip \
        python3-mpi4py \
        python3-nlopt \
        python3-pyqt5 \
        python3-pyqt5.qtsvg \
        python3-pyqt5.sip \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# Boost
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libboost-atomic1.83.0 \
        libboost-filesystem1.83.0 \
        libboost-system1.83.0 \
        libboost-serialization1.83.0 \
        libboost-thread1.83.0 \
        libboost-program-options1.83.0 \
        libboost-chrono1.83.0t64 \
        libboost-date-time1.83.0 \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# SALOME / Geometry / Mesh / 数値計算関連
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libcminpack1 \
        libmpfr6 \
        libmpc3 \
        libcdt5 \
        libcgraph6 \
        libgvc6 \
        libpathplan4 \
        graphviz \
        libpcre3 \
        libusb-1.0-0 \
        libqwt-qt5-6 \
        libqt5x11extras5 \
        libexif12 \
        libraw1394-11 \
        libdc1394-25 \
        libgphoto2-6t64 \
        libgphoto2-port12t64 \
        libxml++2.6-2v5 \
        libnlopt0 \
        libnlopt-cxx0 \
        libhdf5-103-1t64 \
        libhdf5-cpp-103-1t64 \
        libhdf5-hl-100t64 \
        libopenblas0-serial \
        liblapack3 \
        liblapacke \
        libfftw3-double3 \
        libfftw3-dev \
        libtiff6 \
        libfreeimage3 \
        libmetis5 \
        libgdal34t64 \
        libtbb12 \
        libtk8.6 \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# MPI
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openmpi-bin \
        openmpi-common \
        libopenmpi3t64 \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# その他ランタイム
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libbsd0 \
        libbz2-1.0 \
        libc6 \
        libexpat1 \
        libgomp1 \
        libjbig0 \
        libltdl7 \
        liblzma5 \
        libnuma1 \
        libquadmath0 \
        libstdc++6 \
        libudev1 \
        libuuid1 \
        libsqlite3-0 \
        libncurses6 \
        libffi8 \
        libtinfo6 \
        libzstd1 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# SALOME 本体をコピー
# ------------------------------------------------------------

COPY dist/SALOME-9.15.0-native-UB24.04-SRC.tar.gz /tmp/salome.tar.gz


# ------------------------------------------------------------
# /opt/salome に展開
# ------------------------------------------------------------

RUN mkdir -p /opt/salome && \
    tar -xzf /tmp/salome.tar.gz \
        -C /opt/salome \
        --strip-components=1 && \
    rm -f /tmp/salome.tar.gz && \
    chmod -R a+rX /opt/salome


# ------------------------------------------------------------
# SALOME 実行ユーザー
# ------------------------------------------------------------

RUN useradd \
        --create-home \
        --shell /bin/bash \
        salome && \
    mkdir -p /work && \
    chown -R salome:salome /work /home/salome


USER salome

ENV HOME=/home/salome

WORKDIR /work


# ------------------------------------------------------------
# Mesa ソフトウェアレンダリング
# ------------------------------------------------------------

ENV LIBGL_ALWAYS_SOFTWARE=1


# ------------------------------------------------------------
# Docker + X11 の共有メモリ問題を回避
# ------------------------------------------------------------

ENV QT_X11_NO_MITSHM=1


# ------------------------------------------------------------
# 起動時は bash
# ------------------------------------------------------------

CMD ["/bin/bash"]
```

---

## 6. .dockerignore を作成

```bash
vi .dockerignore
```

以下を保存。

```dockerignore
*
!Dockerfile
!dist/
!dist/SALOME-9.15.0-native-UB24.04-SRC.tar.gz
```

---

## 7. ファイル確認

```bash
ls -lh
```

```bash
ls -lh dist/
```

以下が存在することを確認。

```text
Dockerfile
.dockerignore
dist/SALOME-9.15.0-native-UB24.04-SRC.tar.gz
```

---

## 8. Docker イメージをビルド

Dockerfile があるディレクトリで実行。

```bash
docker build --platform linux/amd64 -t salome915 .
```

これによって以下が実行される。

```text
Ubuntu 24.04
↓
必要ライブラリをインストール
↓
SALOME 9.15.0 を展開
↓
権限設定
↓
salome ユーザー作成
↓
salome915 イメージ完成
```

---

## 9. Docker イメージを確認

```bash
docker images
```

例。

```text
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
salome915    latest    xxxxxxxxxxxx   ...
```

---

## 10. Mesh 用 Boost ライブラリを確認

```bash
docker run --rm --platform linux/amd64 salome915 dpkg -l | grep -E 'libboost-(serialization|thread|program-options|chrono|date-time)'
```

以下が表示されることを確認する。

```text
libboost-serialization1.83.0
libboost-thread1.83.0
libboost-program-options1.83.0
libboost-chrono1.83.0t64
libboost-date-time1.83.0
```

特に重要なのは以下。

```text
libboost-serialization1.83.0
libboost-thread1.83.0
```

---

## 11. コンテナの起動とSALOMEの起動

コンテナの起動方法（`docker run` の各オプションの意味）、SALOME本体(`mesa_salome`)の起動、Windows/Macそれぞれでの動作確認は [003_launch_salome.md](003_launch_salome.md) にまとめた。ここではイメージのビルドまでを扱う。

---

## 12. Dockerfile を変更した場合

Dockerfile を変更しただけでは Docker イメージには反映されない。必ず再ビルドする。

```bash
docker build --platform linux/amd64 -t salome915 .
```

再ビルド後は、[003_launch_salome.md](003_launch_salome.md) の手順でコンテナを起動し直す。

```text
Dockerfile 修正
↓
docker build
↓
salome915 イメージ更新
↓
003_launch_salome.md の手順で docker run
```

---

## 13. 注意：コンテナ内で apt install した場合

例えばコンテナ内で、

```bash
apt-get install -y libboost-thread1.83.0
```

としても、

```bash
docker run --rm ...
```

で起動している場合、コンテナ終了時に変更内容は削除される。

```text
salome915 イメージ
↓
docker run
↓
コンテナ作成
↓
apt install
↓
一時的には動く
↓
exit
↓
--rm によりコンテナ削除
↓
追加したライブラリも消える
```

最終的に必要なパッケージは Dockerfile に書く。

---

# 全体の流れ

```text
SALOME 9.15.0 tar.gz を用意
        ↓
salome915-docker/dist/ に配置
        ↓
Dockerfile 作成
        ↓
.dockerignore 作成
        ↓
docker build --platform linux/amd64 -t salome915 .
        ↓
salome915 イメージ完成
        ↓
Boost ライブラリ確認
        ↓
completed（この先の docker run / SALOME起動 / Mac起動 / 配布は
           003_launch_salome.md, 004_distribute_salome.md を参照）
```

イメージが完成したら、[003_launch_salome.md](003_launch_salome.md) でSALOMEのGUIを起動する。