
# Introduction 

Instructions for building a working yet experimental version of embedPy for 32 bit raspberry pi.
These instructions assume a newly installed raspberry pi running the buster OS

## Install prerequisites

    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install rlwrap git build-essential

## Generate an ssh key for github

    ls -al ~/.ssh
    ssh-keygen -t rsa -b 4096 -C "pi@embedpypi.clarkez.co.uk"

If it doesn't already exist Create the file '~/.ssh/config' as 


    touch ~/.ssh/config
    
    Host *
      IgnoreUnknown AddKeysToAgent,UseKeychain
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_rsa


Update the key

    ssh-add -K ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub

Paste to github


## Install Q for RPi Linux (Raspbian Buster)

download linux for arm (linuxarm.zip)


    cd ~ && unzip ~/Downloads/linuxarm.zip
    cd q && ln -s l32arm/ l32


update '.bashrc'. Add: -

    export QHOME="/home/pi/q"
    export PATH="$QHOME/l32arm:$PATH"
    alias q="rlwrap q"


Test run Q

    pi@embedpypi:~ $ q
    KDB+ 3.5 2017.10.11 Copyright (C) 1993-2017 Kx Systems
    l32/ 4()core 925MB pi embedpypi 127.0.1.1 NONEXPIRE  

    Welcome to kdb+ 32bit edition
    For support please see http://groups.google.com/d/forum/personal-kdbplus
    Tutorials can be found at http://code.kx.com/q
    To exit, type \\
    To remove this startup msg, edit q.q



## Install miniconda onto the raspberry pi

Install Miniconda 3 AS USER pi

> Get the File

    wget http://repo.continuum.io/miniconda/c
    /bin/bash Miniconda3-latest-Linux-armv7l.sh 


Accept the license and allow default install under '/home/pi/miniconda'
Allow miniconda to update bash

    tail -2 /home/pi/.bashrc 
    # added by Miniconda3 3.16.0 installer
    export PATH="/home/pi/miniconda3/bin:$PATH"

_

    /home/pi/miniconda3/etc/profile.d/conda.sh
    conda activate


Test:

    sudo reboot -r now
    conda
    python --version

If Conda update miss permission of the directory:

'sudo chown -R pi miniconda3'

## Install a version of python >= 3.5 for arm

Suggested anaconda channel for this is rpi which contains arm appropriate versions of python packages, as such install would be

    conda install -c rpi python=3.6

## Create an environment to do the development in

'conda create -n testenv'

Move into the newly created environment

'source activate testenv'   // This may need to be conda activate


## EmbedPy setup instructions

    git clone git@github.com:KxSystems/embedPy.git

Run 'make && make install && make clean' 
These commands can be run separately

If you see the following error: -

    ERROR
    makefile:11: *** Recursive variable 'CFLAGS' references itself (eventually).  Stop.


Then you can apply the following fix (found in https://github.com/KxSystems/embedPy/pull/88 ): -

'pi@embedpypi:~/work/embedPy $ git diff'

    diff --git a/makefile b/makefile
    index f735f74..c21effa 100644
    --- a/makefile
    +++ b/makefile
    @@ -8,10 +8,10 @@ ifeq ($(UNAME_S),Linux)
       OSFLAG  = l
       LDFLAGS = -fPIC -shared
       ifeq ($(UNAME_M),armv7l)
    -    CFLAGS  += $(filter-out -Wwrite-strings,$(CFLAGS))
    +    CFLAGS  := $(filter-out -Wwrite-strings,$(CFLAGS))
       else
       ifeq ($(UNAME_M),armv6l)
    -    CFLAGS  += $(filter-out -Wwrite-strings,$(CFLAGS))
    +    CFLAGS  := $(filter-out -Wwrite-strings,$(CFLAGS))
       endif
       endif
     else ifeq ($(UNAME_S),Darwin)

Run 'make && make install && make clean' These commands can be run separately

> You currently need to manually copy p.q to $QHOME folder

## Test embedPy install


    pi@pi3:~/work/embedPy $ q
    KDB+ 3.5 2017.10.11 Copyright (C) 1993-2017 Kx Systems
    l32/ 4()core 926MB pi pi3 10.19.151.11 NONEXPIRE
   
    q)\l p.q
    q).p.set[`x;3]
    q)3~.p.py2q .p.pyget`x
    1b

## Installing python packages
The arm build is limited in scope in regards to the packages which are available to be used the reference point should be those that are available within the rpi channel.
The minimal package that should be installed in `numpy`

    conda install -c rpi numpy

Other packages to be installed are at the users’ discretion

## Issues using vanilla python lib

    pi@embedpypi:~/work/embedPy $ q test.q 
    KDB+ 3.5 2017.10.11 Copyright (C) 1993-2017 Kx Systems
    l32/ 4()core 925MB pi embedpypi 127.0.1.1 NONEXPIRE  

    Welcome to kdb+ 32bit edition
    For support please see http://groups.google.com/d/forum/personal-kdbplus
    Tutorials can be found at http://code.kx.com/q
    To exit, type \\
    To remove this startup msg, edit q.q
    'libpython
      [4]  /home/pi/work/embedPy/p.q:12: 
     `L`M`H set'@[system"python3 ",;c;{system"python ",c}];if[count M;if[k~key k:`$":",M;L::M]];
     .p:(`:./p 2:(`init;2))[L;H]]
        ^
      [0]  (<load>)
    
      )'stop
      [5]  (.Q.dr)

     .Q ))\\

.

    pi@embedpypi:~/work/embedPy $ sudo find / -name libpython*.so*
    /usr/lib/python3.7/config-3.7m-arm-linux-gnueabihf/libpython3.7.so
    /usr/lib/python3.7/config-3.7m-arm-linux-gnueabihf/libpython3.7m.so
    /usr/lib/arm-linux-gnueabihf/libpython3.7m.so.1
    /usr/lib/arm-linux-gnueabihf/libpython3.7m.so.1.0


