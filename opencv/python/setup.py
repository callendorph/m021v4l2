# File: setup.py
# Author: Carl Allendorph
#
# Description:
#   Cython-based extension build
#

import os.path
from distutils.core import setup, Extension
import numpy as np
from Cython.Build import cythonize

C_DIR = "../.."

ext_modules=[
    Extension(
        "m021v4l2",
        sources=["m021v4l2.pyx",  os.path.join(C_DIR,"m021_v4l2.c")],
        include_dirs=[C_DIR],
        libraries=["m","v4l2","udev"] # Unix-like specific
    )
]

setup(
        name = 'M021V4L2',
        version = '0.2',
        include_dirs = [np.get_include()], #Add Include path of numpy
        ext_modules = cythonize(ext_modules)
      )
