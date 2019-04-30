def configure(self):
    opts = self.options
    opts.parallel = True
    # self.env.append_value('CXXFLAGS', ['-D_GLIBCXX_USE_CXX11_ABI=0'])
    self.env['ADDMEM'] = 600

    self.env['TFELHOME'] = '/scif/apps/tfel'
    self.env['TFELVERS'] = '3.1.1'
    self.env['CATALO_CMD'] = "DUMMY="

    self.env.append_value('LIBPATH', [
        '/scif/apps/hdf5/lib',
        '/scif/apps/med/lib',
        '/scif/apps/metis/lib',
        '/scif/apps/mumps/lib',
        '/scif/apps/parmetis/lib',
        '/scif/apps/petsc/lib',
        '/scif/apps/scotch/lib',
        '/scif/apps/tfel/lib',
    ])

    self.env.append_value('INCLUDES', [
        '/scif/apps/hdf5/include',
        '/scif/apps/med/include',
        '/scif/apps/metis/include',
        '/scif/apps/mumps/include',
        '/scif/apps/parmetis/include',
        '/scif/apps/petsc/include',
        '/scif/apps/scotch/include',
        '/scif/apps/tfel/include',
    ])

    # to fail if not found
    opts.enable_hdf5 = True
    opts.enable_med = True
    opts.enable_metis = True
    opts.enable_mumps = True
    opts.enable_scotch = True
    opts.enable_mfront = True
    opts.enable_petsc = True

