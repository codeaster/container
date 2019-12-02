#!/bin/bash

VERSION=2019.0-1
cd /work
rm -rf asrun
mkdir asrun
wget --no-check-certificate --quiet \
    https://bitbucket.org/code_aster/codeaster-frontend/get/${VERSION}.tar.gz \
    -O asrun.tar.gz
tar xf asrun.tar.gz -C asrun --strip-components 1
cd asrun
mv /scif/apps/asrun/lib/external_configuration.py external_configuration.py
python3 setup.py install --prefix=/scif/apps/asrun
sed -i "s/mpi_get_procid_cmd : echo \$PMI_RANK/mpi_get_procid_cmd : echo \$OMPI_COMM_WORLD_RANK/" /scif/apps/asrun/etc/codeaster/asrun
printf "\nvers : unstable:/scif/apps/aster/share/aster\n" >> /scif/apps/asrun/etc/codeaster/aster
ln -s /scif/apps/asrun/bin/as_run /usr/local/bin/
