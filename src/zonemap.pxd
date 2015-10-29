# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cdef struct s_Z:
  long i
  long size
  long count
  long *ZV

ctypedef s_Z sZ

cdef class Zonemap:

  cdef long vnum

  cdef long vsize

  cdef long nz

  cdef long total_zones

  cdef long greatest_zone_size

  ## ARRAYS

  cdef double *X

  cdef double *Y

  cdef long *VZ

  cdef sZ **Z

  ## FUNCTIONS

  cdef void __init_zones(self) nogil

  cdef long __add_vertex(self, long v1) nogil

  cdef long __del_vertex(self, long v1) nogil

  cdef long __add_v_to_zone(self, long z1, long v1) nogil

  cdef long __extend_zv_of_zone(self, sZ *z) nogil

  cdef long __remove_v_from_zone(self, long z, long v1) nogil

  cdef long __get_z(self, double x, double y) nogil

  cdef long __update_v(self, long v1) nogil

  cdef long __sphere_vertices(self, double x, double y, double rad, long *vertices) nogil

  cdef long __sphere_is_free(self, double x, double y, double rad) nogil

  cdef long __get_max_sphere_count(self) nogil

  cdef void __assign_xy_arrays(self, double *x, double *y) nogil

  cdef long __get_encode_zonemap_max_size(self) nogil

  cdef void __encode_zonemap(self, long *a) nogil

  cdef void __decode_zonemap(self, long *a) nogil

  ## INFO

  cpdef list _perftest(self, long nmax, long num_points, long num_lookup)

  cpdef long add_vertex(self, long v1)

  cpdef long del_vertex(self, long v1)

  cpdef long update_v(self, long v1)

  cpdef long sphere_is_free(self, double x, double y, double rad)

  cpdef long get_max_sphere_count(self)

  cpdef long get_vnum(self)

  cpdef list get_zone_info_dicts(self)

