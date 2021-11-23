#!/bin/bash -e

set -x

sudo apt-get update --allow-releaseinfo-change --fix-missing

#Install Dependancies
sudo apt-get -y install virtualenv python3-pip python3-dev git build-essential libasound2-dev libjack-jackd2-dev liblilv-dev libjpeg-dev zlib1g-dev cmake debhelper dh-autoreconf dh-python gperf intltool ladspa-sdk libarmadillo-dev libasound2-dev libavahi-gobject-dev libavcodec-dev libavutil-dev libbluetooth-dev libboost-dev libeigen3-dev libfftw3-dev libglib2.0-dev libglibmm-2.4-dev libgtk2.0-dev libgtkmm-2.4-dev libjack-jackd2-dev libjack-jackd2-dev liblilv-dev liblrdf0-dev libsamplerate0-dev libsigc++-2.0-dev libsndfile1-dev libsndfile1-dev libzita-convolver-dev libzita-resampler-dev lv2-dev p7zip-full python3-all python3-setuptools libreadline-dev zita-alsa-pcmi-utils hostapd dnsmasq iptables python3-smbus python3-dev

#Install Python Dependancies
sudo pip3 install pyserial==3.0 pystache==0.5.4 aggdraw==1.3.11 scandir backports.shutil-get-terminal-size
sudo pip3 install git+git://github.com/dlitz/pycrypto@master#egg=pycrypto
sudo pip3 install tornado==4.3
sudo pip3 install Pillow==8.4.0

#Install Mod Software
mv /home/pi/mod /home/pi/install
mkdir /home/pi/.lv2
mkdir /home/pi/mod
mkdir /home/pi/data
mkdir /home/pi/data/.pedalboards
mkdir /home/pi/data/user-files
cd /home/pi/data/user-files
mkdir "Speaker Cabinets IRs"
mkdir "Reverb IRs"
mkdir "Audio Loops"
mkdir "Audio Recordings"
mkdir "Audio Samples"
mkdir "Audio Tracks"
mkdir "MIDI Clips"
mkdir "MIDI Songs"
mkdir "Hydrogen Drumkits"
mkdir "SF2 Instruments"
mkdir "SFZ Instruments"

#Jack2
sudo apt install -y jackd2

#Browsepy
pushd $(mktemp -d) && git clone https://github.com/moddevices/browsepy.git
pushd browsepy
sudo pip3 install ./

#Mod-host
pushd $(mktemp -d) && git clone https://github.com/moddevices/mod-host.git
pushd mod-host
make -j 4
sudo make install

#Mod-ui
pushd $(mktemp -d) && git clone --branch hotfix-1.11 https://github.com/moddevices/mod-ui.git
pushd mod-ui
chmod +x setup.py
pip3 install -r requirements.txt
cd utils
make
cd ..
sudo ./setup.py install

#TouchOSC2midi
pushd $(mktemp -d) && https://github.com/BlokasLabs/touchosc2midi.git
pushd touchosc2midi
sudo pip3 install ./

#Amidithru
pushd $(mktemp -d) && https://github.com/BlokasLabs/amidithru.git
pushd amidithru
sudo make install

#amidiauto
pushd $(mktemp -d) && https://github.com/BlokasLabs/amidiauto.git
pushd amidiauto
sudo make install

#mod-midi-merger
pushd $(mktemp -d) && https://github.com/moddevices/mod-midi-merger.git
pushd mod-midi-merger
mkdir build && cd build
cmake ..
sudo make install

#AudioInjector Stuff
cd /home/pi/install
deb_file=audio.injector.scripts_0.1-1_all.deb
wget https://github.com/Audio-Injector/stereo-and-zero/raw/master/${deb_file}
sudo dpkg -i ${deb_file}
rm -f ${deb_file}
sudo sed -i 's/sudo rpi-update/#sudo rpi-update/' /usr/bin/audioInjector-setup.sh
/usr/bin/audioInjector-setup.sh

# # Change amixer settings
cd /home/pi/install
sudo cp asound.state.RCA.thru.test /usr/share/doc/audioInjector/asound.state.RCA.thru.test
#alsactl --file /usr/share/doc/audioInjector/asound.state.RCA.thru.test restore

#Create Services
sudo cp *.service /usr/lib/systemd/system/
sudo ln -sf /usr/lib/systemd/system/browsepy.service /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/jack.service /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/mod-host.service /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/mod-ui.service /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/amidiauto.service /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/amidithru.service /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/touchosc2midi.service /etc/systemd/system/multi-user.target.wants
sudo ln -sf /usr/lib/systemd/system/mod-touchosc2midi.service /etc/systemd/system/multi-user.target.wants
