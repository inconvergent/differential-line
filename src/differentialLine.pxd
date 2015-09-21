# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport segments
from libc.stdlib cimport malloc, free
#from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef class DifferentialLine(segments.Segments):

  cdef double nearl

  cdef double farl

  cdef int procs

  cdef double *SX

  cdef double *SY

  cdef int *SD

  cdef int *vertices

  ## FUNCTIONS

  cdef int __optimize_avoid(self, double step)

  cdef int __optimize_contract(self, double step, double freeze_distance)

  cpdef int optimize_avoid(self, double step)

  cpdef int optimize_contract(self, double step, double freeze_distance)

