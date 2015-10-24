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

  cdef long __optimize_avoid(self, double step)

  cdef long __optimize_contract(self, double step, double freeze_distance)

  cpdef long optimize_avoid(self, double step)

  cpdef long optimize_contract(self, double step, double freeze_distance)

