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

from libc.stdint cimport uint16_t, uint32_t, int32_t, uint8_t
from posix.time cimport clock_gettime, CLOCK_REALTIME, timespec

DTYPE = np.uint8
ctypedef np.uint8_t DTYPE_t

cimport m021_v4l2 # camera defs in m021_v4l2.pxd

__version__ = "0.2.0"

cdef char *_get_build_version():
    cdef bytes bver = m021_v4l2.m021_version()
    return(bver)

__build__ = _get_build_version()

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

        cdef int ret = m021_v4l2.m021_grab_bgr(&self._obj, pframe, self.bcorr, self.gcorr, self.rcorr)
        if ( ret != 0 ):
            raise Exception("Invalid Image: {}".format(ret))
        ts = _get_ts()

        return(frame, ts)

    def set_trigger_mode(self, mode):
        cdef int ret = m021_v4l2.m021_set_trigger_mode(&self._obj, mode)
        if ( ret != 0 ):
            raise Exception("Failed to Set Trigger mode: {}".format(ret))

    def get_trigger_mode(self):
        cdef m021_v4l2.M021_TRIGGER_MODE_t mode
        cdef int ret = m021_v4l2.m021_get_trigger_mode(&self._obj, &mode)
        if ( ret != 0 ):
            raise Exception("Failed to Set Trigger mode: {}".format(ret))
        return(mode)

    def set_trigger_delay(self, delay):
        cdef int ret = m021_v4l2.m021_set_trigger_delay(&self._obj, delay)
        if ( ret != 0 ):
            raise Exception("Failed to Set Trigger Delay: {}".format(ret))

    def get_trigger_delay(self):
        cdef uint32_t delay
        cdef int ret = m021_v4l2.m021_get_trigger_delay(&self._obj, &delay)
        if ( ret != 0 ):
            raise Exception("Failed to Get Trigger Delay: {}".format(ret))
        return(delay)

    def get_uuid_hwfw_rev(self):
        cdef char uuid[64]
        cdef uint16_t hwRev;
        cdef uint16_t fwRev;
        cdef int ret = m021_v4l2.m021_get_uuid_hwfw_rev(
            &self._obj, uuid, 64, &hwRev, &fwRev
            )
        if ( ret != 0 ):
            raise Exception("Failed to Get UUID/HW/FWRev: {}".format(ret))

        cdef bytes pyUuid = uuid
        return({
            "uuid" : pyUuid,
            "hw_rev" : hwRev,
            "fw_rev" : fwRev
        })

    def set_register(self, addr, val):
        """ Set register values on the image array - don't use these
        unless you know what you are doing.
        """
        cdef int ret = m021_v4l2.m021_set_register(&self._obj, addr, val)
        if ( ret != 0 ):
            raise Exception("Failed to Set Register: {}".format(ret))

    def get_register(self, addr):
        cdef uint16_t val
        cdef int ret = m021_v4l2.m021_get_register(&self._obj, addr, &val)
        if ( ret != 0 ):
            raise Exception("Failed to Get Register: {}".format(ret))
        return(val)

    def set_exposure(self, exp):
        cdef int ret = m021_v4l2.m021_set_exposure(&self._obj,exp)
        if ( ret != 0 ):
            raise Exception("Failed to Set Exposure: {}".format(ret))

    def get_exposure(self):
        cdef uint16_t exp
        cdef int ret = m021_v4l2.m021_get_exposure(&self._obj, &exp)
        if ( ret != 0 ):
            raise Exception("Failed to Get Exposure: {}".format(ret))
        return(exp)
