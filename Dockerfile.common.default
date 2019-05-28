FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# Use same filesystem organisation as for Singularity Apps
# https://www.sylabs.io/guides/3.2/user-guide/definition_files.html#apps

# Base system + prerequisites
# Show all the dependencies of each prerequisite even if some packages are
# repeated
RUN mkdir /data && \
    apt-get update && \
    apt-get upgrade -y --with-new-pkgs -o Dpkg::Options::="--force-confold" && \
    apt-get install -y \
        # base system
        cmake \
        g++ \
        gcc \
        gfortran \
        locales \
        make \
        mercurial \
        wget \
        # added for...
        # hdf5
        zlib1g-dev \
        # med \
        python3-dev \
        # scotch
        bison \
        flex \
        zlib1g-dev \
        # mumps
        libopenblas-dev \
        python3-dev \
        python3-numpy \
        # tfel
        libboost-numpy-dev \
        libboost-python-dev \
        # parmetis
        libopenmpi-dev \
        libblacs-mpi-dev \
        libscalapack-openmpi-dev \
        # asrun
        gdb \
        tk \
        xterm \
        # external tools called by aster \
        gmsh \
        grace \
        && \
    locale-gen en_GB.UTF-8 en_US.UTF-8 fr_FR.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX

ENV LANG=en_US.UTF-8 LC_MESSAGES=POSIX

# create aster user
RUN mkdir /work && \
    useradd -b /work -m -s /bin/bash aster
USER aster

# continue as root
USER root

# hdf5
RUN cd /data && rm -rf hdf5 && \
    mkdir hdf5 && \
    wget --no-check-certificate --quiet \
        https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.3/src/hdf5-1.10.3.tar.gz \
        -O hdf.tar.gz && \
    tar xf hdf.tar.gz -C hdf5 --strip-components 1 && \
    cd hdf5 && \
    ./configure --prefix=/scif/apps/hdf5 && \
    make -j 4 && \
    make install

# med
RUN cd /data && rm -rf med && \
    mkdir med && \
    wget --no-check-certificate --quiet \
        http://files.salome-platform.org/Salome/other/med-4.0.0.tar.gz \
        -O med.tar.gz && \
    tar xf med.tar.gz -C med --strip-components 1 && \
    cd med && \
    alias python=python3 && \
    F77=gfortran CXXFLAGS='-std=gnu++98' PYTHON=/usr/bin/python3 \
        ./configure --disable-mesgerr --with-hdf5=/scif/apps/hdf5 --prefix=/scif/apps/med && \
    make -j 4 && \
    make install

# metis
RUN cd /data && rm -rf metis && \
    hg clone --noupdate https://bitbucket.org/code_aster/metis metis && \
    cd metis && \
    hg update code_aster && \
    make config prefix=/scif/apps/metis && \
    make -j 4 && \
    make install

# parmetis
RUN cd /data && rm -rf parmetis && \
    hg clone --noupdate https://bitbucket.org/code_aster/parmetis && \
    cd parmetis && \
    hg update parmetis_aster && \
    make config CFLAGS="-fPIC -DINTSIZE64" prefix=/scif/apps/parmetis && \
    make -j 4 && \
    make install

# tfel
RUN cd /data && rm -rf tfel && \
    mkdir tfel && \
    VERSION=3.2.1 && \
    wget --no-check-certificate --quiet \
        https://github.com/thelfer/tfel/archive/TFEL-${VERSION}.tar.gz \
        -O tfel.tar.gz && \
    tar xf tfel.tar.gz -C tfel --strip-components 1 && \
    cd tfel && \
    mkdir build && \
    cd build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DTFEL_SVN_REVISION=${VERSION} -DTFEL_APPEND_VERSION=${VERSION} \
        -DCMAKE_Fortran_COMPILER=/usr/bin/gfortran \
        -Dlocal-castem-header=ON -Denable-fortran=OFF \
        -DPython_ADDITIONAL_VERSIONS=3.6 -Denable-python=ON \
        -Denable-broken-boost-python-module-visibility-handling=ON \
        -Denable-python-bindings=ON \
        -Denable-cyrano=ON -Denable-aster=ON \
        -Ddisable-reference-doc=ON -Ddisable-website=ON \
        -Denable-portable-build=ON \
        -DPYTHON_EXECUTABLE:FILEPATH=/usr/bin/python3 \
        -DPYTHON_LIBRARY:FILEPATH=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu/libpython3.6.so \
        -DPYTHON_INCLUDE_DIR:PATH=/usr/include/python3.6 \
        -DPython_ADDITIONAL_VERSIONS=3.6 \
        -DCMAKE_INSTALL_PREFIX=/scif/apps/tfel && \
    make -j 4 && \
    make install && \
    ln -s /scif/apps/tfel/bin/mfront-${VERSION} /usr/local/bin/

# homard
RUN cd /data && rm -rf homard && \
    mkdir homard && \
    wget --no-check-certificate --quiet \
        https://bitbucket.org/code_aster/homard/get/homard_aster.tar.gz \
        -O homard.tar.gz && \
    tar xf homard.tar.gz -C homard --strip-components 1 && \
    cd homard && \
    python3 setup_homard.py --prefix=/scif/apps/homard && \
    ln -s /scif/apps/homard /usr/local/bin/

# asrun (graphical packages should be removed for servers)
ADD asrun.external_configuration.py /data/

RUN cd /data && rm -rf asrun && \
    mkdir asrun && \
    wget --no-check-certificate --quiet \
        https://bitbucket.org/code_aster/codeaster-frontend/get/default.tar.gz \
        -O asrun.tar.gz && \
    tar xf asrun.tar.gz -C asrun --strip-components 1 && \
    cd asrun && \
    cp /data/asrun.external_configuration.py external_configuration.py && \
    python3 setup.py install --prefix=/scif/apps/asrun && \
    sed -i "s/mpi_get_procid_cmd : echo \$PMI_RANK/mpi_get_procid_cmd : echo \$OMPI_COMM_WORLD_RANK/" /scif/apps/asrun/etc/codeaster/asrun && \
    printf "\nvers : unstable:/scif/apps/aster/share/aster\n" >> /scif/apps/asrun/etc/codeaster/aster && \
    ln -s /scif/apps/asrun/bin/as_run /usr/local/bin/

# scotch sequential
RUN cd /data && rm -rf scotch-seq && \
    hg clone --noupdate https://bitbucket.org/code_aster/scotch scotch-seq && \
    cd scotch-seq && \
    hg update scotch_aster && \
    cd src && \
    sed -i -e 's/CFLAGS\s*=/CFLAGS = -Wl,--no-as-needed/g' \
        -e 's/CCD\s*=.*$/CCD = cc/g' Makefile.inc && \
    make scotch && \
    make esmumps && \
    mkdir -p /scif/apps/scotch-seq && \
    make install prefix=/scif/apps/scotch-seq

# scotch parallel
RUN cd /data && rm -rf scotch-mpi && \
    hg clone --noupdate https://bitbucket.org/code_aster/scotch scotch-mpi && \
    cd scotch-mpi && \
    hg update scotch_aster && \
    cd src && \
    sed -i -e 's/CFLAGS\s*=/CFLAGS = -Wl,--no-as-needed/g' \
        -e 's/CCD\s*=.*$/CCD = mpicc/g' Makefile.inc && \
    make scotch && \
    make ptscotch && \
    make esmumps && \
    mkdir -p /scif/apps/scotch-mpi && \
    make install prefix=/scif/apps/scotch-mpi

# mumps sequential
RUN cd /data && rm -rf mumps-seq && \
    hg clone --noupdate https://bitbucket.org/code_aster/mumps mumps-seq && \
    cd mumps-seq && \
    hg update for_aster && \
    LIBPATH="/scif/apps/scotch-seq/lib /scif/apps/metis/lib /scif/apps/parmetis/lib" \
        INCLUDES="/scif/apps/scotch-seq/include /scif/apps/metis/include /scif/apps/parmetis/include" \
        python3 ./waf configure --enable-openmp --enable-metis --enable-scotch \
            --install-tests --prefix=/scif/apps/mumps-seq && \
    python3 ./waf build --jobs=1 && \
    python3 ./waf install --jobs=1

# mumps parallel
RUN cd /data && rm -rf mumps-mpi && \
    hg clone --noupdate https://bitbucket.org/code_aster/mumps mumps-mpi && \
    cd mumps-mpi && \
    hg update for_aster && \
    LIBPATH="/scif/apps/scotch-mpi/lib /scif/apps/metis/lib /scif/apps/parmetis/lib" \
        INCLUDES="/scif/apps/scotch-mpi/include /scif/apps/metis/include /scif/apps/parmetis/include" \
        python3 ./waf configure --enable-mpi --enable-openmp --enable-metis --enable-parmetis --enable-scotch \
            --install-tests --prefix=/scif/apps/mumps-mpi && \
    python3 ./waf build --jobs=1 && \
    python3 ./waf install --jobs=1

# petsc
RUN cd /data && rm -rf petsc && \
    hg clone --noupdate https://bitbucket.org/code_aster/petsc && \
    cd petsc && \
    hg update petsc_aster && \
    cd petsc-src && \
    ./configure \
        --with-debugging=0 \
        --with-mpi=1 \
        --with-ssl=0 \
        --with-x=0 \
        --with-mumps-lib="-L/scif/apps/mumps-mpi/lib -lzmumps -ldmumps -lmumps_common -lpord -L/scif/apps/scotch-mpi/lib -lesmumps -lptscotch -lptscotcherr -lptscotcherrexit -lscotch -lscotcherr -lscotcherrexit -L/scif/apps/parmetis/lib -lparmetis -L/scif/apps/metis/lib -lmetis" \
        --with-mumps-include=/scif/apps/mumps-mpi/include \
        --with-blas-lapack-lib="-lopenblas -llapack -lblacsCinit-openmpi -lblacsF77init-openmpi -lblacs-openmpi" \
        --with-scalapack-lib="-lscalapack-openmpi" \
        --PETSC_ARCH=arch-linux2-codeaster \
        --download-ml=/data/petsc/3rd/petsc-pkg-ml-e5040d11aa07.tar.gz \
        --download-hypre=/data/petsc/3rd/hypre-2.14.0.tar.gz \
        --download-superlu=/data/petsc/3rd/superlu-a0819410c9eb779f9b296cdd95fbdfd96986ae10.tar.gz \
        --with-openmp=0 \
        LIBS=-lgomp \
        --prefix=/scif/apps/petsc && \
    make -j 4 PETSC_DIR=/data/petsc/petsc-src PETSC_ARCH=arch-linux2-codeaster all && \
    make -j 4 PETSC_DIR=/data/petsc/petsc-src PETSC_ARCH=arch-linux2-codeaster install

# clean source directory
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* && \
    rm -rf /data

# aster
# disable automatic devtools environment sourcing
ENV DEVTOOLS_COMPUTER_ID=scif
ADD aster.wafcfg_scif_std.py /work/aster/scif_std.py
ADD aster.wafcfg_scif_mpi.py /work/aster/scif_mpi.py

ENV LD_LIBRARY_PATH=/scif/apps/tfel/lib
ENV PYTHONPATH=/scif/apps/asrun/lib/python3.6/site-packages:/scif/apps/tfel/lib/python3.6/site-packages

USER aster
WORKDIR /work/aster

RUN hg clone --noupdate --rev null https://bitbucket.org/code_aster/codeaster-devtools devtools && \
    hg clone --noupdate --rev null https://bitbucket.org/code_aster/codeaster-src src
