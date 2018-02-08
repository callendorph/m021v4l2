# File: m021v4l2.pyx
# Author: Carl Allendorph
#
# Description:
#   This file contains a cython implementation for capturing frames
# from the M021C leopard imaging camera. The concept here is to
# both improve the capture performance and simply dramatically the
# python wrapper for accessing this code.

import numpy as np
cimport numpy as np

from posix.time cimport clock_gettime, CLOCK_REALTIME, timespec

DTYPE = np.uint8
ctypedef np.uint8_t DTYPE_t

cimport m021_v4l2 # camera defs in m021_v4l2.pxd


cdef double _get_ts():
    """ Use posix.time to get the current timestamp of an image.
    @return timestamp in seconds from the epoch - includes fractional
       second to nanosec depending on host specs
    """
    cdef timespec ts
    clock_gettime(CLOCK_REALTIME, &ts)
    cdef double tsTime = <double>ts.tv_sec
    cdef double fracTime = <double>ts.tv_nsec
    tsTime += (fracTime / 1e9)
    return(tsTime)


cdef class m021v4l:
    """ M021C camera Python Wrapper for v4l2.
    @note - this class is NOT thread-safe!
    """
    cdef m021_v4l2.m021_t _obj
    cdef int devNum
    cdef int width
    cdef int height
    cdef int bcorr
    cdef int gcorr
    cdef int rcorr

    def __cinit__(self, int devNum, int width, int height, int bcorrect, int gcorrect, int rcorrect):
        self.devNum = devNum
        self.width = width
        self.height = height
        self.bcorr = bcorrect
        self.gcorr = gcorrect
        self.rcorr = rcorrect

        m021_v4l2.m021_init(devNum, &self._obj, self.width, self.height)

    def __dealloc__(self):
        m021_v4l2.m021_free(&(self._obj))

    def read(self):
        """ Read an image from the Camera
        @return (img, ts) where img is a new BGR image of the appropriate
           size and ts is a timestamp (like time.time() )
        """
        cdef np.ndarray[DTYPE_t, ndim=3, mode="c"] frame = np.zeros(
            [self.height, self.width, 3], dtype=DTYPE
        )
        cdef DTYPE_t* pframe = &(frame[0,0,0])

        ret = m021_v4l2.m021_grab_bgr(&self._obj, pframe, self.bcorr, self.gcorr, self.rcorr)
        if ( ret != 0 ):
            raise Exception("Invalid Image: {}".format(ret))
        ts = _get_ts()

        return(frame, ts)
