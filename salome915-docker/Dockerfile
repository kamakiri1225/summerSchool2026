# ============================================================
# SALOME 9.15.0 Docker Image
#
# Base OS:
#   Ubuntu 24.04 LTS
#
# Architecture:
#   linux/amd64
#
# Purpose:
#   SALOME 9.15.0 native Ubuntu 24.04版を
#   Dockerコンテナ上で実行する。
#
# GUI:
#   ブラウザ / noVNC / VNC は使用しない。
#
#   Windows:
#       Docker Desktop
#       + WSL2
#       + WSLg
#
#   macOS:
#       Docker Desktop
#       + XQuartz
#
# SALOME:
#   SALOME-9.15.0-native-UB24.04-SRC.tar.gz
#
# Windows build:
#
#   docker build --platform linux/amd64 -t salome915 .
#
# Windows run:
#
#   docker run --rm -it --platform linux/amd64 -e DISPLAY=:0 -v /mnt/wslg/.X11-unix:/tmp/.X11-unix -v ~/salome_work:/work salome915
#
# SALOME launch:
#
#   /opt/salome/mesa_salome
#
# ============================================================


FROM ubuntu:24.04


# ------------------------------------------------------------
# apt を対話なしで実行
# ------------------------------------------------------------

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
# X11 / OpenGL / Mesa
#
# Windows:
#   WSLg
#
# macOS:
#   XQuartz
#
# SALOME GUIをDockerコンテナからホスト側へ表示するために必要。
#
# LIBGL_ALWAYS_SOFTWARE=1 を後で設定し、
# GPU依存を減らしてMesaソフトウェアレンダリングを使用する。
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
#
# SALOME本体およびSALOME付属モジュールが使用する
# Python関連ライブラリ。
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
#
# SALOME Geometry / Mesh / SMESH 等で使用。
#
# Dockerで実際に不足が発生したもの:
#
#   libboost_serialization.so.1.83.0
#     -> libboost-serialization1.83.0
#
#   libboost_thread.so.1.83.0
#     -> libboost-thread1.83.0
#
# WSL Ubuntu 24.04上でSALOME 9.15 Meshが
# 正常動作している環境も参考にしている。
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
# 数値計算 / Geometry / Mesh / CAE 関連ライブラリ
#
# SALOME 9.15をUbuntu 24.04上で動かしている
# 実績環境と、これまでのDocker動作確認を元にしている。
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
#
# SALOME内部の一部処理・並列処理関連で必要になる。
# ------------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openmpi-bin \
        openmpi-common \
        libopenmpi3t64 \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# その他の一般ランタイムライブラリ
#
# Ubuntu最小イメージでは入っていない場合があるため
# SALOME配布版が参照する可能性のあるものを明示的に導入。
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
# SALOME 9.15.0
#
# Dockerfileと同じディレクトリに
#
#   dist/
#     SALOME-9.15.0-native-UB24.04-SRC.tar.gz
#
# を置く。
# ------------------------------------------------------------

COPY dist/SALOME-9.15.0-native-UB24.04-SRC.tar.gz /tmp/salome.tar.gz


# ------------------------------------------------------------
# SALOMEを /opt/salome に展開
#
# --strip-components=1:
#   tar.gz内部の最上位ディレクトリを除去して
#   /opt/salome直下にSALOMEを配置。
#
# chmod -R a+rX:
#   SALOMEアーカイブには一部
#
#       drwxr-x---
#
#   のディレクトリが存在する。
#
# Docker内では別ユーザー "salome" で実行するため、
# 全ユーザーに読み取り権限と
# ディレクトリへの移動権限を付与する。
#
# chmod -R 755 は通常ファイルまで実行可能になるため使わない。
# ------------------------------------------------------------

RUN mkdir -p /opt/salome && \
    tar -xzf /tmp/salome.tar.gz \
        -C /opt/salome \
        --strip-components=1 && \
    rm -f /tmp/salome.tar.gz && \
    chmod -R a+rX /opt/salome


# ------------------------------------------------------------
# SALOME実行専用ユーザー
#
# rootでSALOMEを実行しない。
# ------------------------------------------------------------

RUN useradd \
        --create-home \
        --shell /bin/bash \
        salome && \
    mkdir -p /work && \
    chown -R salome:salome /work /home/salome


# ------------------------------------------------------------
# SALOMEユーザーへ切り替え
# ------------------------------------------------------------

USER salome


# ------------------------------------------------------------
# HOME
# ------------------------------------------------------------

ENV HOME=/home/salome


# ------------------------------------------------------------
# 作業ディレクトリ
#
# ホスト側フォルダを /work にマウントして利用する。
# ------------------------------------------------------------

WORKDIR /work


# ------------------------------------------------------------
# OpenGL
#
# GPU / WSLg / XQuartz環境差による問題を避けるため、
# Mesaソフトウェアレンダリングを使用する。
# ------------------------------------------------------------

ENV LIBGL_ALWAYS_SOFTWARE=1


# ------------------------------------------------------------
# Qt + X11
#
# Docker越しのX11でMIT-SHM共有メモリ機構が
# 問題になることがあるため無効化。
# ------------------------------------------------------------

ENV QT_X11_NO_MITSHM=1


# ------------------------------------------------------------
# デフォルト
#
# いきなりSALOMEを起動せずbashにする。
#
# デバッグやライブラリ確認が容易になる。
#
# コンテナ起動後:
#
#   /opt/salome/mesa_salome
#
# でSALOMEを起動する。
# ------------------------------------------------------------

CMD ["/bin/bash"]