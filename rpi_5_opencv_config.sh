#!/bin/bash

# -----------------------------------------------------------------------------
# Instructions for this script
# From windows you can sftp into the pi and copy this repo into /home/{$USER}/Projects
# sftp loki@xxx.xxx.xxx.xxx
# 
# wget https://raw.githubusercontent.com/davemers0160/opencv_ex/main/rpi_5_opencv_config.sh
#
# put this file in the user home directory and then run the following:
# chmod +x rpi_5_opencv_config.sh
# ./rpi_5_opencv_config.sh
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# if the script does not run initially you may need to run the following command and then retry the script
# dos2unix rpi_5_opencv_config.sh
# -----------------------------------------------------------------------------

readonly OPENCV_VERSION=4.10.0  # issues with ffmpeg version 5.1 and earlier versions of opencv require 4.10+

sudo apt-get update
sudo apt-get install -y build-essential git cmake libusb-1* libsndfile1 unzip pkg-config libncurses5-dev
sudo apt-get install -y libjpeg-dev libtiff-dev libpng-dev libturbojpeg0-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install -y libgtk2.0-dev libcanberra-gtk3-module libgtk-3-dev
sudo apt-get install -y libgstreamer1.0-dev gstreamer1.0-gtk3
sudo apt-get install -y libgstreamer-plugins-base1.0-dev gstreamer1.0-gl gstreamer1.0-plugins-ugly gstreamer1.0-tools gstreamer1.0-rtsp
sudo apt-get install -y libxvidcore-dev libx264-dev 
#sudo apt-get install -y libavresample-dev v4l2ucp
sudo apt-get install -y python3-dev python3-numpy python3-pip
sudo apt-get install -y libv4l-dev v4l-utils 
sudo apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
sudo apt-get install -y liblapack-dev gfortran libhdf5-dev
#sudo apt-get install -y libprotobuf-dev libgoogle-glog-dev libgflags-dev
#sudo apt-get install -y protobuf-compiler
sudo apt-get install -y libtbb-dev 

# libdc1394-22-dev 
# libtbbmalloc2 libtbb2 \
# libeigen3-dev \
# libglew-dev \
# libgstreamer-plugins-bad1.0-dev \
# gstreamer1.0-tools \
# qt4-default \
# libjpeg62-turbo-dev \
# liblapacke-dev \
# libpostproc-dev \
# libtesseract-dev \
# libxine2-dev \
# python3-matplotlib \
# qv4l2 \
# zlib1g-dev

# create the python virtual environment and install required packages
python -m venv ~/venv --system-site-packages --symlinks

# create a script to activate the python virtual environment
echo '#!/bin/bash' > activate_venv.sh
echo 'source ~/venv/bin/activate' >> activate_venv.sh
chmod +x ~/activate_venv.sh

# have the venv startup when the terminal starts
echo 'source activate_venv.sh' >> .bashrc

# activate the venv to install some things
source ~/venv/bin/activate
pip install numpy pyyaml soundfile

# grab opencv
cd ~
echo "Getting version $OPENCV_VERSION of OpenCV"
git clone --depth 1 --branch "$OPENCV_VERSION" https://github.com/opencv/opencv.git
git clone --depth 1 --branch "$OPENCV_VERSION" https://github.com/opencv/opencv_contrib.git

cd opencv
mkdir -p build
cd build

# run cmake to build opencv
echo "Building OpenCV... This may take some time"
cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
    -D ENABLE_NEON=ON \
    -D WITH_OPENMP=ON \
    -D WITH_OPENCL=OFF \
    -D BUILD_TIFF=ON \
    -D WITH_FFMPEG=ON \
    -D WITH_TBB=ON \
    -D BUILD_TBB=ON \
    -D WITH_GSTREAMER=ON \
    -D BUILD_TESTS=OFF \
    -D WITH_EIGEN=OFF \
    -D WITH_V4L=ON \
    -D WITH_LIBV4L=ON \
    -D WITH_VTK=OFF \
    -D WITH_QT=OFF \
    -D WITH_PROTOBUF=OFF \
    -D BUILD_opencv_dnn=OFF \
    -D BUILD_opencv_dnn_objdetect=OFF \
    -D BUILD_opencv_dnn_superres=OFF \
    -D OPENCV_DNN_PERF_CAFFE=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_opencv_python2=OFF \
    -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_opencv_world=ON ..
    
        # -D BUILD_opencv_python3=ON
        # -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 
        # -D WITH_OPENGL=ON
        # -D WITH_GTK=OFF
        
make -j8
sudo make install && sudo ldconfig

# cleanup to free space
make clean
sudo apt-get update

# grab all of the projects 
cd ~
mkdir -p Projects
cd Projects

mkdir -p data

# grab the common, python_common and the rapipyaml repos
git clone https://github.com/davemers0160/Common
git clone https://github.com/davemers0160/python_common

git clone --recursive https://github.com/davemers0160/rapidyaml

# build the rapidyaml library
cd rapidyaml
mkdir -p build
cd build
cmake -DBUILD_SHARED_LIBS=ON ..
cmake --build . --config Release -- -j4
sudo make install && sudo ldconfig

cd ~/Projects

# clone the example OpenCV repo
git clone https://github.com/davemers0160/opencv_ex


# build the tx hop example
cd opencv_ex/web_cam_stream
mkdir -p build
cd build
cmake ..
cmake --build . --config Release -- -j4


echo "Run the following command:"
echo "sudo nano /boot/firmware/cmdline.txt"
echo "- add the following to the end of the line: \" usbcore.usbfs_memory_mb=2048 \" "
echo " "
echo "run the following commands to change the swap file size.  Find the line CONF_SWAPSIZE "
echo "sudo dphys-swapfile swapoff"
echo "sudo nano /etc/dphys-swapfile.conf"
echo "sudo systemctl restart dphys-swapfile"
echo " "
