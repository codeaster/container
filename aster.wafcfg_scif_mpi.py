import scif_std

def configure(self):
    opts = self.options
    opts.parallel = True

    scif_std.configure(self)

    self.env.prepend_value('LIBPATH', [
        '/scif/apps/mumps-mpi/lib',
        '/scif/apps/parmetis/lib',
        '/scif/apps/petsc/lib',
        '/scif/apps/scotch-mpi/lib',
    ])

    self.env.prepend_value('INCLUDES', [
        '/scif/apps/mumps-mpi/include',
        '/scif/apps/parmetis/include',
        '/scif/apps/petsc/include',
        '/scif/apps/scotch-mpi/include',
    ])

    # to fail if not found
    opts.enable_petsc = True
