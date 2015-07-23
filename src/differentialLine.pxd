# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport segments 
from libc.stdlib cimport malloc, free
#from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef class DifferentialLine(segments.Segments):

  cdef float nearl

  cdef float farl

  cdef int procs

  cdef float *SX

  cdef float *SY

  cdef int *SD

  cdef int *vertices

  ## FUNCTIONS

  cdef int __optimize_avoid(self, float step)
  
  cdef int __optimize_contract(self, float step, float freeze_distance)

  cpdef int optimize_avoid(self, float step)

  cpdef int optimize_contract(self, float step, float freeze_distance)

