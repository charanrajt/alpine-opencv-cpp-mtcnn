FROM alpine:3.5
LABEL maintainer "charanrajt@gmail.com"
ENV OPENCV_VERSION 3.4.5
ENV ENG_SCI /usr/local/eng_sci
ENV OPENCV_INSTALL_DIR /usr/local/eng_sci/opencv



#2 Add Edge and bleeding repos
# add the edge repositories
RUN echo "@edge-testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
echo "@edge-community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

#3 update apk, install dependencies
RUN apk update \
&& apk upgrade \
&& apk add --no-cache \
build-base \
clang \
clang-dev \
cmake \
git \
pkgconf \
wget \
libtbb@edge-testing \
libtbb-dev@edge-testing \
libjpeg \
libjpeg-turbo-dev \
libpng \
libpng-dev \
tiff \
tiff-dev \
libjasper \
jasper-dev \
linux-headers


RUN cd /tmp \
&& wget -O opencv-$OPENCV_VERSION.tar.gz https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz \
&& tar -xzf opencv-$OPENCV_VERSION.tar.gz \
&& wget -O opencv_contrib-$OPENCV_VERSION.tar.gz https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.tar.gz \
&& tar -xzf opencv_contrib-$OPENCV_VERSION.tar.gz \
&& cd /tmp/opencv-$OPENCV_VERSION \
&& mkdir build \
&& mkdir $ENG_SCI \
&& mkdir $OPENCV_INSTALL_DIR \
&& cd build \
&& CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake \
-D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=$OPENCV_INSTALL_DIR \
-D WITH_FFMPEG=NO \
-D WITH_IPP=NO \
-D WITH_OPENEXR=NO \
-D WITH_TBB=YES \
-D WITH_1394=NO \
-D BUILD_PERF_TESTS=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-$OPENCV_VERSION/modules \
-D BUILD_TESTS=OFF .. \
&& make -j2 \
&& make install \
&& cd \
&& rm -rf /tmp/* \
&& git clone https://github.com/charanrajt/opencv-mtcnn.git \
&& cd opencv-mtcnn \
&& mkdir build \
&& cd build \
&& cmake .. \
&& cmake --build . \
&& cp lib/libopencv_mtcnn.a $OPENCV_INSTALL_DIR/lib64/ \
&& cp -r ../lib/include/mtcnn/ $OPENCV_INSTALL_DIR/include/ \ 
&& cd .. \
&& rm -rf opencv-mtcnn/
