# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport segments
from libc.stdlib cimport malloc, free
#from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef class DifferentialLine(segments.Segments):

  cdef double nearl

  cdef double farl

  cdef long procs

  cdef double *SX

  cdef double *SY

  cdef long *SD

  cdef long *vertices

  ## FUNCTIONS

  cdef long __reject(
    self,
    long v,
    long *vertices,
    long num,
    double step,
    double *sx,
    double *sy
  ) nogil

  cpdef long optimize_position(self, double step)

