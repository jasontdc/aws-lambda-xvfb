FROM amazonlinux:1

RUN  yum group install -y "Development Tools"

ADD centos.repo.txt /etc/yum.repos.d/centos.repo
RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

RUN yum install -y \
  wget \
  libX11-devel.x86_64 \
  pixman-devel.x86_64 \
  libdrm-devel.x86_64 \
  mesa-libGL-devel.x86_64 \
  openssl-devel.x86_64 \
  xorg-x11-xtrans-devel.noarch \
  libXfont-devel.x86_64 \
  libxkbfile-devel.x86_64 \
  libpciaccess-devel.x86_64 \
  xorg-x11-utils \
  libXtst-devel.x86_64 \
  libjpeg-turbo-devel.x86_64


WORKDIR /app

RUN wget https://www.x.org/archive/individual/data/xkeyboard-config/xkeyboard-config-2.19.tar.gz && \
  tar -xzf xkeyboard-config-2.19.tar.gz && \
  cd /app/xkeyboard-config-2.19 && \
  export LD_LIBRARY_PATH=/usr/local/lib; \
  export PKG_CONFIG_PATH=/usr/local/share/pkgconfig:/usr/local/lib/pkgconfig; \
  ./configure \
    --prefix=/usr \
    --with-xkb-base=/var/task/xkb && \
  make && make install


RUN wget https://www.x.org/archive/individual/xserver/xorg-server-1.15.0.tar.gz && \
  tar -xzf xorg-server-1.15.0.tar.gz && \
  cd /app/xorg-server-1.15.0 && \
  CC=gcc48 ./configure \
    --prefix=/usr/local \
    # --enable-glamor=no \
    --with-xkb-path=/var/task/xkb \
    --with-xkb-output=/tmp \
    --with-xkb-bin-directory=/var/task/bin && \
  make && make install

RUN wget https://www.x.org/releases/individual/app/xkbcomp-1.3.1.tar.gz && \
  tar -xzf xkbcomp-1.3.1.tar.gz && \
  cd /app/xkbcomp-1.3.1 && \
  ./configure \
    --prefix=/usr \
    --with-xkb-config-root=/var/task/xkb && \
    make -j8 && make install

RUN wget http://x11vnc.sourceforge.net/dev/x11vnc-0.9.14-dev.tar.gz -O x11vnc.tar.gz && \
  tar xzf x11vnc.tar.gz && \
  cd x11vnc-0.9.14 && \
  ./configure \
    --prefix=/usr/local && \
  make -j8 && make install

RUN wget http://sourceforge.net/projects/fluxbox/files/fluxbox/1.3.7/fluxbox-1.3.7.tar.xz -O fluxbox.tar.xz && \
  tar xJf fluxbox.tar.xz && \
  cd fluxbox-1.3.7 && \
  ./configure \
    --prefix=/usr/local && \
    make -j8 && make install


# Install Stellarium dependencies
RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.3/cmake-3.15.3.tar.gz && \
  tar xzf cmake-3.15.3.tar.gz && \
  cd cmake-3.15.3 && \
  ./bootstrap && \
  make -j8 && make install

# https://doc.qt.io/qt-5/linux-requirements.html#
# https://doc.qt.io/qt-5/configure-options.html#
# https://doc.qt.io/qt-5/linux-building.html#
RUN wget http://download.qt.io/archive/qt/5.13/5.13.1/single/qt-everywhere-src-5.13.1.tar.xz
RUN tar xJf qt-everywhere-src-5.13.1.tar.xz

# RUN  cd qt-everywhere-src-5.13.1 && \
#  ./configure -opensource -confirm-license&& \
#  gmake -j8 && gmake install

# Install Stellarium

# https://github.com/Stellarium/stellarium/wiki/Linux-build-dependencies
# https://github.com/Stellarium/stellarium/wiki/Compilation-on-Linux
#RUN wget https://github.com/Stellarium/stellarium/releases/download/v0.19.1/stellarium-0.19.1.tar.gz && \
#  tar xzf stellarium-0.19.1.tar.gz && \
#  cd stellarium-0.19.1 && \
#  cmake . && \
#  make -j8 && make install

WORKDIR /app
RUN mkdir -p /var/task/bin
RUN ln -s /usr/bin/xkbcomp /var/task/bin/xkbcomp

ADD bin/run-x11.sh /app/bin/
CMD /app/bin/run-x11.sh
