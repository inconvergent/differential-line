# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython
cimport segments

from cython.parallel import parallel, prange

from libc.math cimport sqrt

from helpers cimport double_array_init
from helpers cimport long_array_init
from helpers cimport edges_are_connected

cdef class DifferentialLine(segments.Segments):

  def __init__(self, long nmax, double zonewidth, double nearl, double farl, long procs):

    segments.Segments.__init__(self, nmax, zonewidth)

    """
    - nearl is the closest comfortable distance between two vertices.

    - farl is the distance beyond which disconnected vertices will ignore
    each other
    """

    self.nearl = nearl

    self.farl = farl

    self.procs = procs

    print('nearl: {:f}'.format(nearl))
    print('farl: {:f}'.format(farl))

    return

  def __cinit__(self, long nmax, *arg, **args):

    self.SX = <double *>malloc(nmax*sizeof(double))

    self.SY = <double *>malloc(nmax*sizeof(double))

    self.SD = <long *>malloc(nmax*sizeof(long))

    self.vertices = <long *>malloc(nmax*sizeof(long))

    return

  def __dealloc__(self):

    free(self.SX)

    free(self.SY)

    free(self.SD)

    free(self.vertices)

    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cdef long __reject(
    self,
    long v,
    long *vertices,
    long num,
    double step,
    double *sx,
    double *sy
  ) nogil:

    """
    all vertices will move away from all neighboring (closer than farl)
    vertices
    """

    cdef double dx
    cdef double dy
    cdef double nrm

    if self.VA[v]<1:
      return -1

    cdef long e1 = self.VE[2*v]
    cdef long e2 = self.VE[2*v+1]

    cdef long v1
    cdef long v2

    # connected vertices to v, v1 and v2

    if self.EV[2*e1] == v:
      v1 = self.EV[2*e1+1]
    else:
      v1 = self.EV[2*e1]

    if self.EV[2*e2] == v:
      v2 = self.EV[2*e2+1]
    else:
      v2 = self.EV[2*e2]

    cdef double resx = 0.
    cdef double resy = 0.

    cdef long neigh
    cdef long k

    for k in range(num):

      neigh = vertices[k]
      dx = self.X[v]-self.X[neigh]
      dy = self.Y[v]-self.Y[neigh]
      nrm = sqrt(dx*dx+dy*dy)

      if neigh == v1 or neigh == v2:
        # linked

        if nrm<self.nearl or nrm<=0.:
          continue

        resx += -dx/nrm*step
        resy += -dy/nrm*step

      else:
        # not linked

        if nrm>self.farl or nrm<=0.:
          continue

        resx += dx*(self.farl/nrm-1)*step
        resy += dy*(self.farl/nrm-1)*step

    sx[v] += resx
    sy[v] += resy

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef long optimize_position(self, double step):

    cdef long asize = self.zonemap.__get_max_sphere_count()*sizeof(long)
    cdef long *vertices
    cdef long v
    cdef long num

    with nogil, parallel(num_threads=self.procs):

      vertices = <long *>malloc(asize)

      for v in prange(self.vnum, schedule='guided'):

        self.SX[v] = 0.0
        self.SY[v] = 0.0

        num = self.zonemap.__sphere_vertices(
          self.X[v],
          self.Y[v],
          self.farl,
          vertices
        )
        self.__reject(
          v,
          vertices,
          num,
          step,
          self.SX,
          self.SY
        )

      free(vertices)

      for v in prange(self.vnum, schedule='guided'):

        if self.VA[v]<0:
          continue

        self.X[v] += self.SX[v]
        self.Y[v] += self.SY[v]

    with nogil:
      for v in range(self.vnum):

        if self.VA[v]<0:
          continue

        self.zonemap.__update_v(v)

