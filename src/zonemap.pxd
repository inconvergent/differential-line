# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cdef struct s_Z:
  int i
  int size
  int count
  int *ZV 

ctypedef s_Z sZ

cdef class Zonemap:

  cdef int vnum

  cdef int vsize

  cdef int nz

  cdef int total_zones

  cdef int greatest_zone_size

  ## ARRAYS

  cdef float *X

  cdef float *Y

  cdef int *VZ

  cdef sZ **Z

  ## FUNCTIONS

  cdef void __init_zones(self) nogil

  cdef int __add_vertex(self, int v1) nogil

  cdef int __del_vertex(self, int v1) nogil

  cdef int __add_v_to_zone(self, int z1, int v1) nogil

  cdef int __extend_zv_of_zone(self, sZ *z) nogil

  cdef int __remove_v_from_zone(self, int z, int v1) nogil

  cdef int __get_z(self, float x, float y) nogil

  cdef int __update_v(self, int v1) nogil

  cdef int __sphere_vertices(self, float x, float y, float rad, int *vertices) nogil

  cdef int __sphere_is_free(self, float x, float y, float rad) nogil

  cdef int __get_greatest_zone_size(self) nogil

  cdef void __assign_xy_arrays(self, float *x, float *y) nogil

  ## INFO

  cpdef int add_vertex(self, int v1)

  cpdef int del_vertex(self, int v1)

  cpdef int update_v(self, int v1)

  cpdef int sphere_is_free(self, float x, float y, float rad)

  cpdef int get_greatest_zone_size(self)

  cpdef int get_vnum(self)

  cpdef list get_zone_info_dicts(self)

