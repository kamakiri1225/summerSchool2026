#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y \
  python3-psutil \
  libcminpack1 \
  libcdt5 libcgraph6 libgvc6 libpathplan4 graphviz \
  libboost-filesystem1.83.0 libboost-atomic1.83.0 libboost-system1.83.0 \
  python3-pyqt5.qtsvg libqt5x11extras5 \
  libpcre3 libusb-1.0-0 libqwt-qt5-6 \
  libexif12 libraw1394-11 libdc1394-25 \
  libgphoto2-6t64 libgphoto2-port12t64 \
  libxml++2.6-2v5 \
  libnlopt0 libnlopt-cxx0 python3-nlopt \
  libhdf5-cpp-103-1t64 \
  libopenblas0-serial liblapacke fftw-dev \
  libtiff6 libfreeimage3 libmetis5 libgdal34t64 libtbb12 libtk8.6 \
  python3-h5py python3-netcdf4 python3-cftime \
  python3-pandas python3-toml python3-matplotlib \
  python3-docutils python3-imagesize python3-alabaster \
  python3-sphinx python3-sphinx-rtd-theme python3-sphinxcontrib.websupport python3-stemmer \
  python3-statsmodels python3-numpydoc python3-patsy \
  python3-pytest-cython python3-nose python3-scipy \
  python3-pytest python3-cycler python3-kiwisolver python3-mpi4py python3-numpy python3-sip
