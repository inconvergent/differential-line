# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport numpy as np

from zonemap cimport Zonemap

cdef class Segments:

  cdef long nmax

  cdef long vnum

  cdef long vact

  cdef long enum

  cdef long snum

  cdef long nz

  cdef double zonewidth

  ## ARRAYS

  cdef double *X # vertex x

  cdef double *Y # vertex y

  cdef long *VA # vertex is active: 1, passive: 0, dead: -1

  cdef long *VS # vertex -> segment

  cdef long *EV # edge -> vertex

  cdef long *VE # vertex -> edge TODO: rewrite?

  ## ZONEMAPS

  cdef Zonemap zonemap

  ## FUNCTIONS

  cdef long __valid_new_vertex(self, double x, double y)

  cdef long __add_vertex(self,double x,double y, long s)

  cdef long __add_passive_vertex(self,double x,double y, long s)

  cdef long __valid_new_edge(self, long v1, long v2)

  cdef long __add_edge(self, long v1, long v2) except -1

  cdef long __edge_exists(self, long e1)

  cdef long __vertex_exists(self, long v1)

  cdef long __vertex_status(self, long v1)

  cdef long __vertex_segment(self, long v1)

  cdef long __del_vertex(self, long v1) except -1

  cdef long __set_passive_vertex(self, long v1) except -1

  cdef long __del_edge(self, long e1) except -1

  cdef long __get_edge_normal(self, long s1, double *nn)

  cdef long __safe_vertex_positions(self, double limit) nogil

  cpdef list get_edges_coordinates(self)

  cpdef long np_get_edges_coordinates(self, np.ndarray[double, mode="c",ndim=2] a)

  cpdef long np_get_edges(self, np.ndarray[long, mode="c",ndim=2] a)

  cpdef long np_get_vert_coordinates(self, np.ndarray[double, mode="c",ndim=2] a)

  cpdef double get_greatest_distance(self, double x, double y)

  cpdef long  np_get_sorted_verts(self, np.ndarray[long, mode="c",ndim=1] a)

  cpdef long  np_get_sorted_vert_coordinates(self, np.ndarray[double, mode="c",ndim=2] a)

  cpdef list get_edges(self)

  cpdef list get_edges_vertices(self)

  cpdef double get_edge_length(self, long e1)

  cpdef list get_edge_vertices(self, long e1)

  cpdef init_line_segment(self, list xys, long lock_edges=*)

  cpdef init_passive_line_segment(self, list xys)

  cpdef init_circle_segment(self, double x, double y, double r, list angles)

  cpdef init_passive_circle_segment(self, double x, double y, double r, list angles)

  cpdef long split_edge(self, long e1, double minimum_length=*) except -1

  cpdef split_long_edges(self, double limit)

  cpdef long collapse_edge(self, long e1, double maximum_length=*) except -1

  cpdef double get_edge_curvature(self, long e1) except -1.0

  cpdef long get_active_vertex_count(self)

  cpdef long safe_vertex_positions(self, double limit)

  cpdef long get_snum(self)

  cpdef long get_vnum(self)

  cpdef long get_enum(self)

