# Containers for code_aster

This repository provides some recipes to build containers for
[code_aster](https://www.code-aster.org/).

> **It should be considered as a work in progress.**
>
> For example, additional work is needed to execute a containerized version of
  code_aster from an existing
  [salome_meca](https://www.code-aster.org/spip.php?article302)
  installation.


The repository contains first recipes to build a sequential and a parallel
version for the development branch (`default`).
The version is named `unstable`.

* for [docker](https://docs.docker.com/).

* for [singularity](https://www.sylabs.io/docs/) (*soon*).



## Build images

See available targets:

``` bash
make
```

Then choose your target between `seq` and `mpi`, or `build` to build all:

``` bash
make build
```

Environment files added in the `env.d` directory are sourced before calling
`docker`/`singularity` builder. It may be useful for example to configure the
environment to pass a proxy.


## Testing

### Running a shell using the image:

``` bash
docker run --rm -it code_aster_seq:default
```

### Running a testcase using testcase files embedded in the image:

``` bash
docker run --rm code_aster_seq:default as_run --nodebug_stderr --test zzzz100f
```

### Running a testcase using files out of the image:

In this example the data files are extracted from the *image*.
In the real life, these files are for example created from salome_meca.

``` bash
# create a temporary container to access the testcase files
docker run --name astercp code_aster_seq:default

# copy files
mkdir workdir
docker cp astercp:/scif/apps/aster/share/aster/tests/sslv155a.comm workdir/
docker cp astercp:/scif/apps/aster/share/aster/tests/sslv155a.mmed workdir/

# clean the temporary container
docker rm astercp

# create the export file
docker run --rm  code_aster_seq:default as_run --get_export sslv155a --nodebug_stderr | \
    sed -e 's#/scif/apps/aster/share/aster/tests#.#g' \
    > workdir/export
```

If the `export` file is manually created, the version can be addressed just
by name (`P version unstable`).

Now, run a code_aster container using local files:

``` bash
docker run --rm --volume $(pwd)/workdir:/aster code_aster_seq:default \
    as_run --nodebug_stderr /aster/export
```

### Validation

*Some prerequisites are not yet available within the container
(miss3d, ecrevisse, etc.). So, all the tests that are using these tools
are currently in failure.*

The `--test` argument allows to execute only 4 testcases.
Remove it to check all the testcases (about 3800).

``` bash
docker run -t code_aster_seq:default run_testcases --test unstable

# to copy the result files
docker cp -a <CONTAINER>:/home/aster/resutest <DESTINATION>
```
