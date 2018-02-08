# File: m021_v4l2.pxd
# Author: Carl Allendorph
#
# Description:
#   This file contains the definition of the interface to the
# m021_t object defined in c. This definition will allow us to
# wrap this object and make calls to it.
#
# @note - this file must be named differently from the *.pyx file
#    @see docs for cython

from libc.stdint cimport uint8_t, int8_t

cdef extern from "m021_v4l2.h":
  ctypedef struct m021_t:
    pass
  ctypedef uint8_t* FRAME_TYPE

  # Methods
  int m021_init(int id, m021_t *m021, int width, int height)
  int m021_grab_yuyv(m021_t * m021, FRAME_TYPE frame)
  int m021_grab_bgr(
      m021_t * m021, FRAME_TYPE frame,
      int8_t bcorrect, int8_t gcorrect, int8_t rcorrect
  )
  void m021_free(m021_t * m021)
