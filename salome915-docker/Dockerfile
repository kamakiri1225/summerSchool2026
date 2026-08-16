# ============================================================
# SALOME 9.15.0 / Ubuntu 24.04 / linux-amd64
#
# 目的:
#   Windows と macOS の両方で、
#   Dockerコンテナ内の SALOME 9.15 GUI を
#   ホストOS上の通常のウィンドウとして表示する。
#
# GUI表示方式:
#
#   Windows
#     Docker Desktop + WSL2 + WSLg
#
#   macOS
#     Docker Desktop + XQuartz
#
# noVNC / VNC / Xvfb は使用しない。
# SALOME自身のGUIをX11経由でホストOSへ直接表示する。
#
# ------------------------------------------------------------
# ビルド
# ------------------------------------------------------------
#
# docker build --platform linux/amd64 -t salome915 .
#
# ------------------------------------------------------------
# Windowsでの起動例
# ------------------------------------------------------------
#
# docker run --rm -it --platform linux/amd64 -e DISPLAY=:0 -v /mnt/wslg/.X11-unix:/tmp/.X11-unix -v ~/salome_work:/work salome915
#
# コンテナ内で:
#
# /opt/salome/mesa_salome
#
# ------------------------------------------------------------
# 想定フォルダ構成
# ------------------------------------------------------------
#
# salome915-docker/
# ├── Dockerfile
# └── dist/
#     └── SALOME-9.15.0-native-UB24.04-SRC.tar.gz
#
# ============================================================


# ============================================================
# 1. ベースOS
#
# SALOME 9.15公式対応の Ubuntu 24.04 LTS を使用する。
#
# Dockerイメージ自体は linux/amd64 でビルドする。
#
# Apple Silicon Mac (M1/M2/M3/M4...) でも
# Docker Desktopのamd64エミュレーションを利用して
# 同じDockerイメージを使用する。
# ============================================================

FROM ubuntu:24.04


# ============================================================
# 2. apt の対話入力を無効化
#
# Docker build中に tzdata などが
# 「地域を選択してください」等の対話入力を要求して
# ビルドが停止することを防ぐ。
# ============================================================

ENV DEBIAN_FRONTEND=noninteractive


# ============================================================
# 3. 基本ツール
#
# SALOMEアーカイブの展開や、
# コンテナ内での動作確認に使用する。
# ============================================================

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


# ============================================================
# 4. X11 / OpenGL 関連ライブラリ
#
# SALOMEはQt/OpenGLを使用するGUIアプリなので、
# Linux側にX11/OpenGL関連ライブラリが必要。
#
# Windows:
#   WSLgのXサーバーへ接続する。
#
# macOS:
#   XQuartzのXサーバーへ接続する。
#
# x11-apps:
#   xclockなどを含む。
#   SALOME起動前にX11 GUI表示が正常かテストできる。
#
# mesa-utils:
#   glxinfo等を含み、OpenGLの確認に利用できる。
# ============================================================

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1 \
        libglu1-mesa \
        libglx-mesa0 \
        libegl1 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxi6 \
        libxrandr2 \
        libxcursor1 \
        libxinerama1 \
        libxfixes3 \
        libxdamage1 \
        libxcb1 \
        libxkbcommon-x11-0 \
        libfontconfig1 \
        libfreetype6 \
        libsm6 \
        libice6 \
        x11-apps \
        mesa-utils \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 5. SALOME 9.15 ランタイム依存ライブラリ
#
# Ubuntu 24.04上でSALOME 9.15を動作させるために
# OS側へ追加するランタイム依存ライブラリ。
#
# このリストは、以前Ubuntu 24.04へSALOME 9.15を
# インストールした際に必要だったパッケージ群を基にしている。
#
# 今回Docker環境で追加確認された依存:
#
#   libmpfr6
#     → libmpfr.so.6 を提供する。
#
#     mesa_salome 起動時に
#
#       error while loading shared libraries:
#       libmpfr.so.6
#
#     が出たため追加。
#
#   libmpc3
#     → libmpc.so.3 を提供する。
#
#     libmpfr6追加後に
#
#       error while loading shared libraries:
#       libmpc.so.3
#
#     が出たため追加。
#
# 今後さらに "*.so: cannot open shared object file"
# が出た場合は、このセクションへ対応パッケージを追加する。
# ============================================================

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
        libcminpack1 \
        libmpfr6 \
        libmpc3 \
        libcdt5 \
        libcgraph6 \
        libgvc6 \
        libpathplan4 \
        graphviz \
        libboost-filesystem1.83.0 \
        libboost-atomic1.83.0 \
        libboost-system1.83.0 \
        python3-pyqt5.qtsvg \
        libqt5x11extras5 \
        libpcre3 \
        libusb-1.0-0 \
        libqwt-qt5-6 \
        libexif12 \
        libraw1394-11 \
        libdc1394-25 \
        libgphoto2-6t64 \
        libgphoto2-port12t64 \
        libxml++2.6-2v5 \
        libnlopt0 \
        libnlopt-cxx0 \
        libhdf5-cpp-103-1t64 \
        libopenblas0-serial \
        liblapacke \
        fftw-dev \
        libtiff6 \
        libfreeimage3 \
        libmetis5 \
        libgdal34t64 \
        libtbb12 \
        libtk8.6 \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 6. SALOME本体をDockerイメージへコピー
#
# ビルド前に以下のファイルを用意しておく。
#
# dist/
# └── SALOME-9.15.0-native-UB24.04-SRC.tar.gz
#
# Windows側の /mnt/... 上で直接展開せず、
# Dockerイメージ内部のLinuxファイルシステムで展開する。
#
# SALOMEアーカイブにはLinuxのシンボリックリンクや
# Linux固有のアクセス権が含まれるため、
# Docker内部で展開する方が安全。
# ============================================================

COPY dist/SALOME-9.15.0-native-UB24.04-SRC.tar.gz /tmp/salome.tar.gz


# ============================================================
# 7. SALOMEを /opt/salome へ展開
#
# --strip-components=1
#
# アーカイブ内部:
#
# SALOME-9.15.0-native-UB24.04-SRC/
# ├── salome
# ├── mesa_salome
# └── BINARIES-UB24.04/
#
# ↓
#
# /opt/salome/
# ├── salome
# ├── mesa_salome
# └── BINARIES-UB24.04/
#
#
# chmod -R a+rX /opt/salome
#
# SALOME配布物には、
#
#   drwxr-x---
#
# のように元のubuntuユーザー/グループしか
# アクセスできないディレクトリが含まれていた。
#
# Docker内では後で作成する salome ユーザーから
# SALOME本体を読み取り・実行する必要があるため、
# 全ユーザーへ必要な読み取り/ディレクトリアクセス権を追加する。
#
#   a  = all users
#   +r = 読み取り権限
#   +X = ディレクトリ、および既に実行可能なファイルへ実行権限
#
# 「chmod -R 755」と違って、
# 普通のデータファイルまで実行可能にしないため、
# a+rX の方が適切。
# ============================================================

RUN mkdir -p /opt/salome && \
    tar -xzf /tmp/salome.tar.gz \
        -C /opt/salome \
        --strip-components=1 && \
    rm -f /tmp/salome.tar.gz && \
    chmod -R a+rX /opt/salome


# ============================================================
# 8. SALOME実行用の一般ユーザーを作成
#
# SALOMEをrootユーザーのまま実行するのではなく、
# 一般ユーザー salome を作成する。
#
# /work:
#   SALOMEのモデルやMEDファイルなどを保存する作業領域。
#
# ホスト側のディレクトリを
#
#   -v ~/salome_work:/work
#
# とマウントして使用する。
# ============================================================

RUN useradd \
        --create-home \
        --shell /bin/bash \
        salome && \
    mkdir -p /work && \
    chown -R salome:salome /work /home/salome


# ============================================================
# 9. 以降は一般ユーザー salome として実行
# ============================================================

USER salome


# ============================================================
# 10. HOME / 作業ディレクトリ
# ============================================================

ENV HOME=/home/salome

WORKDIR /work


# ============================================================
# 11. Qt / OpenGL関連設定
#
# LIBGL_ALWAYS_SOFTWARE=1
#
# Docker + X11ではホストGPUとのOpenGL連携が
# 不安定になることがあるため、
# まずMesaによるソフトウェアレンダリングを使用する。
#
# 特に:
#
#   Windows + WSLg
#   macOS + XQuartz
#
# の共通Dockerイメージとして配布する場合、
# GPU依存を減らした方が環境差を吸収しやすい。
#
#
# QT_X11_NO_MITSHM=1
#
# QtがMIT-SHM（X11共有メモリ）を使わないようにする。
#
# DockerコンテナとホストXサーバーは
# 同じ共有メモリ空間を直接利用できない場合があるため、
# X11越しGUIでは無効化した方が安定しやすい。
# ============================================================

ENV LIBGL_ALWAYS_SOFTWARE=1
ENV QT_X11_NO_MITSHM=1


# ============================================================
# 12. デフォルト起動
#
# WindowsとMacではX11接続方法が異なるため、
# Dockerイメージ自体ではDISPLAYを固定しない。
#
# コンテナ起動時はbashへ入り、
# ホスト側のdocker runコマンドでDISPLAYを指定する。
#
#
# Windows:
#
# docker run --rm -it \
#   --platform linux/amd64 \
#   -e DISPLAY=:0 \
#   -v /mnt/wslg/.X11-unix:/tmp/.X11-unix \
#   -v ~/salome_work:/work \
#   salome915
#
#
# コンテナ内:
#
# /opt/salome/mesa_salome
#
#
# Mac:
#
# Docker Desktop + XQuartzを使用し、
# DISPLAYをhost.docker.internal側へ向ける。
#
# ============================================================

CMD ["/bin/bash"]