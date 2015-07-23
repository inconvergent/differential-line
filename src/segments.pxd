# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport numpy as np

from zonemap cimport Zonemap

cdef class Segments:

  cdef int nmax

  cdef int vnum

  cdef int vact

  cdef int enum

  cdef int snum

  cdef int nz

  cdef float zonewidth

  ## ARRAYS

  cdef float *X # vertex x

  cdef float *Y # vertex y

  cdef int *VA # vertex is active: 1, passive: 0, dead: -1

  cdef int *VS # vertex -> segment

  cdef int *EV # edge -> vertex

  cdef int *VE # vertex -> edge TODO: rewrite?

  ## ZONEMAPS

  cdef Zonemap zonemap

  ## FUNCTIONS

  cdef int __valid_new_vertex(self, float x, float y)

  cdef int __add_vertex(self,float x,float y, int s)

  cdef int __add_passive_vertex(self,float x,float y, int s)

  cdef int __valid_new_edge(self, int v1, int v2)

  cdef int __add_edge(self, int v1, int v2) except -1

  cdef int __edge_exists(self, int e1)

  cdef int __vertex_exists(self, int v1)

  cdef int __vertex_status(self, int v1)

  cdef int __vertex_segment(self, int v1)

  cdef int __del_vertex(self, int v1) except -1

  cdef int __set_passive_vertex(self, int v1) except -1

  cdef int __del_edge(self, int e1) except -1

  cdef int __get_edge_normal(self, int s1, float *nn)

  cdef int __safe_vertex_positions(self, float limit) nogil

  cpdef list get_edges_coordinates(self)

  cpdef int np_get_edges_coordinates(self, np.ndarray[double, mode="c",ndim=2] a)

  cpdef int np_get_vert_coordinates(self, np.ndarray[double, mode="c",ndim=2] a)

  cpdef float get_greatest_distance(self, float x, float y)

  cpdef list get_sorted_vert_coordinates(self)

  cpdef list get_edges(self)

  cpdef list get_edges_vertices(self)

  cpdef float get_edge_length(self, int e1)

  cpdef list get_edge_vertices(self, int e1)

  cpdef init_line_segment(self, list xys, int lock_edges=*)

  cpdef init_passive_line_segment(self, list xys)

  cpdef init_circle_segment(self, float x, float y, float r, list angles)

  cpdef init_passive_circle_segment(self, float x, float y, float r, list angles)

  cpdef int split_edge(self, int e1, float minimum_length=*) except -1

  cpdef split_long_edges(self, float limit)

  cpdef int collapse_edge(self, int e1, float maximum_length=*) except -1

  cpdef float get_edge_curvature(self, int e1) except -1.0

  cpdef int get_active_vertex_count(self)

  cpdef int safe_vertex_positions(self, float limit)

  cpdef int get_snum(self)

  cpdef int get_vnum(self)

  cpdef int get_enum(self)

