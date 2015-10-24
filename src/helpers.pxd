# -*- coding: utf-8 -*-

cimport cython

from libc.math cimport sqrt
from libc.math cimport pow


cdef extern from "stdlib.h":
  void qsort(void *base, long nmemb, long size,
       long(*compar)(const void *, const void *))

cdef inline void long_array_init(long *a,long n,long v):
  """
  initialize longeger array a of length n with longeger value v
  """
  cdef long i
  for i in xrange(n):
    a[i] = v
  return

cdef inline void double_array_init(double *a,long n,double v):
  """
  initialize double array a of length n with double value v
  """
  cdef long i
  for i in xrange(n):
    a[i] = v
  return

cdef inline void add_e_to_ve(long v, long e, long *ve):
  """
  update ve mapping for vertex c and edge e
  """

  if ve[2*v] < 0:
    ve[2*v] = e
  else:
    ve[2*v+1] = e
  return

cdef inline void del_e_from_ve(long v, long e, long *ve):

  if ve[2*v] == e:
    ve[2*v] = ve[2*v+1]
    ve[2*v+1] = -1
  elif ve[2*v+1] == e:
    ve[2*v+1] = -1
  return

cdef inline long edges_are_connected(long e1, long e2, long *ev):
  """
  check if e1 and e2 are connected to the same vertex. returns id of connecting
  vertex or -1
  """
  cdef long v11 = ev[2*e1]
  cdef long v12 = ev[2*e1+1]
  cdef long v21 = ev[2*e2]
  cdef long v22 = ev[2*e2+1]

  if v11 == v21 and v11>-1:
    return v11
  elif v11 == v22 and v11>-1:
    return v11
  elif v12 == v21 and v12>-1:
    return v12
  elif v12 == v22 and v12>-1:
    return v12
  else:
    return -1

