#!/bin/bash

VERSION=f1ab20d94ea4
BASE=/work/codeaster
# source environment from parent image
[ -f /.singularity.d/env/90-environment.sh ] && . /.singularity.d/env/90-environment.sh

# URLdevtools=https://bitbucket.org/code_aster/codeaster-devtools
# URLsrc=https://bitbucket.org/code_aster/codeaster-src
URLdevtools=http://aster-repo.der.edf.fr/scm/hg/codeaster/devtools
URLsrc=http://aster-repo.der.edf.fr/scm/hg/codeaster/src
# URLdevtools=http://localhost:8001/
# URLsrc=http://localhost:8000/

mkdir -p ${BASE}
repo=devtools
printf "creating repository '${repo}'...\n"
cd ${BASE}
hg clone --rev null ${URLdevtools} ${repo} > /dev/null
cd ${BASE}/${repo}
hg pull --rev default && hg update default

repo=src
printf "creating repository '${repo}'...\n"
cd ${BASE}
hg clone --rev null ${URLsrc} ${repo} > /dev/null
cd ${BASE}/${repo}
hg pull --rev ${VERSION} && hg update ${VERSION}


cd ${BASE}/src
./waf configure \
    --prefix=/scif/apps/aster \
    --use-config-dir=/scif/apps/aster/lib --use-config=scif_std
./waf install

# clean config.txt
grep -v /work /scif/apps/aster/share/aster/config.txt > config.tmp
echo 'SRCTEST        | src     | -     | $ASTER_VERSION_DIR/tests' >> config.tmp
cp config.tmp /scif/apps/aster/share/aster/config.txt

# keep only some testcases
rm /scif/apps/aster/share/aster/tests
mkdir /scif/apps/aster/share/aster/tests
for name in forma01a hsnv100a pynl01a sdll100a sslv155a ssnv128a zzzz100f
do
    cp ${BASE}/src/astest/${name}* /scif/apps/aster/share/aster/tests/
done

# cleanup
rm -rf /work
