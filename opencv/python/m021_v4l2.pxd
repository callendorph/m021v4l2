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

from libc.stdint cimport uint8_t, int8_t, uint16_t, uint32_t

cdef extern from "m021_v4l2.h":
  ctypedef struct m021_t:
    pass
  ctypedef uint8_t* FRAME_TYPE

  ctypedef enum M021_TRIGGER_MODE_t:
    M021_TRIGGER_MODE_AUTO_gc,
    M021_TRIGGER_MODE_RISING_gc,
    M021_TRIGGER_MODE_FALLING_gc

  # Methods
  int m021_init(int id, m021_t *m021, int width, int height)
  int m021_grab_yuyv(m021_t * m021, FRAME_TYPE frame)
  int m021_grab_bgr(
      m021_t * m021, FRAME_TYPE frame,
      int8_t bcorrect, int8_t gcorrect, int8_t rcorrect
  )
  int m021_set_trigger_mode(m021_t *vd, M021_TRIGGER_MODE_t mode);
  int m021_get_trigger_mode(m021_t *vd, M021_TRIGGER_MODE_t *mode);
  int m021_set_trigger_delay(m021_t *vd, uint32_t delay_ms);
  int m021_get_trigger_delay(m021_t *vd, uint32_t *delay_ms);
  int m021_get_uuid_hwfw_rev(
      m021_t *vd,
      char *uuid, uint32_t uuid_len,
      uint16_t *hw, uint16_t *fw
  );

  int m021_set_register(m021_t *vd, uint16_t addr, uint16_t val);
  int m021_get_register(m021_t *vd, uint16_t addr, uint16_t *val);

  int m021_set_exposure(m021_t *vd, uint16_t val);
  int m021_get_exposure(m021_t *vd, uint16_t *val);

  void m021_free(m021_t * m021)
  const char *m021_version()
