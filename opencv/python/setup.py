# File: setup.py
# Author: Carl Allendorph
#
# Description:
#   Cython-based extension build
#

import os.path
import subprocess as sp
from distutils.core import setup, Extension
import numpy as np

from Cython.Build import cythonize

C_DIR = "../.."

# For a build we want to provide a git hash for the repo so we
#  can insert that as the build version
githash = sp.check_output(["git", "rev-parse", "HEAD"]).strip()

ext_modules=[
    Extension(
        "m021v4l2",
        sources=["m021v4l2.pyx",  os.path.join(C_DIR,"m021_v4l2.c")],
        include_dirs=[C_DIR],
        libraries=["m","v4l2","udev"], # Unix-like specific
        extra_compile_args=['-D', 'BUILD_VERSION="{}"'.format(githash)]
    )
]

setup(
        name = 'M021V4L2',
        version = '0.2',
        include_dirs = [np.get_include()], #Add Include path of numpy
        ext_modules = cythonize(ext_modules)
      )
