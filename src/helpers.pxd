# -*- coding: utf-8 -*-

cimport cython

from libc.math cimport sqrt
from libc.math cimport pow


cdef extern from "stdlib.h":
  void qsort(void *base, int nmemb, int size,
       int(*compar)(const void *, const void *))

cdef inline void int_array_init(int *a,int n,int v):
  """
  initialize integer array a of length n with integer value v
  """
  cdef int i
  for i in xrange(n):
    a[i] = v
  return

cdef inline void float_array_init(float *a,int n,float v):
  """
  initialize float array a of length n with float value v
  """
  cdef int i
  for i in xrange(n):
    a[i] = v
  return

cdef inline void add_e_to_ve(int v, int e, int *ve):
  """
  update ve mapping for vertex c and edge e
  """

  if ve[2*v] < 0:
    ve[2*v] = e
  else:
    ve[2*v+1] = e
  return

cdef inline void del_e_from_ve(int v, int e, int *ve):

  if ve[2*v] == e:
    ve[2*v] = ve[2*v+1]
    ve[2*v+1] = -1
  elif ve[2*v+1] == e:
    ve[2*v+1] = -1
  return

cdef inline int edges_are_connected(int e1, int e2, int *ev):
  """
  check if e1 and e2 are connected to the same vertex. returns id of connecting
  vertex or -1
  """
  cdef int v11 = ev[2*e1]
  cdef int v12 = ev[2*e1+1]
  cdef int v21 = ev[2*e2]
  cdef int v22 = ev[2*e2+1]

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

