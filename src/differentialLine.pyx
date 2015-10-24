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
  cdef long __optimize_avoid(self, double step):
    """
    all vertices will move away from all neighboring (closer than farl)
    vertices
    """

    cdef long procs = self.procs
    cdef double farl = self.farl
    cdef double nearl = self.nearl

    cdef long vnum = self.vnum

    cdef unsigned long v
    cdef unsigned long k

    cdef long neigh
    cdef long neighbor_num

    cdef double x
    cdef double y
    cdef double dx
    cdef double dy
    cdef double nrm

    cdef double resx
    cdef double resy

    cdef long *vertices
    cdef long asize = self.zonemap.__get_max_sphere_count()*sizeof(long)

    cdef long e1
    cdef long e2

    cdef long v1
    cdef long v2

    with nogil, parallel(num_threads=procs):

      vertices = <long *>malloc(asize)

      for v in prange(vnum, schedule='guided'):

        if self.VA[v]<1:
          continue

        e1 = self.VE[2*v]
        e2 = self.VE[2*v+1]

        # connected vertices to v, v1 and v2

        if self.EV[2*e1] == v:
          v1 = self.EV[2*e1+1]
        else:
          v1 = self.EV[2*e1]

        if self.EV[2*e2] == v:
          v2 = self.EV[2*e2+1]
        else:
          v2 = self.EV[2*e2]

        x = self.X[v]
        y = self.Y[v]

        neighbor_num = self.zonemap.__sphere_vertices(x, y, farl, vertices)

        resx = 0.
        resy = 0.

        for k in range(neighbor_num):

          neigh = vertices[k]
          dx = x-self.X[neigh]
          dy = y-self.Y[neigh]
          nrm = sqrt(dx*dx+dy*dy)

          if neigh == v1 or neigh == v2:
            # linked

            if nrm<nearl or nrm<=0.:
              continue

            resx += -dx/nrm*step
            resy += -dy/nrm*step

          else:
            # not linked

            if nrm>farl or nrm<=0.:
              continue

            resx += dx*(farl/nrm-1)*step
            resy += dy*(farl/nrm-1)*step

        self.SX[v] += resx
        self.SY[v] += resy

      free(vertices)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cdef long __optimize_contract(self, double step, double freeze_distance):
    """
    all vertices will move away from all neighboring (closer than farl)
    vertices
    """

    cdef long procs = self.procs
    cdef double farl = self.farl
    cdef double nearl = self.nearl

    cdef long vnum = self.vnum

    cdef unsigned long v
    cdef unsigned long k

    cdef long neigh
    cdef long neighbor_num

    cdef double x
    cdef double y
    cdef double dx
    cdef double dy
    cdef double nrm

    cdef double resx
    cdef double resy

    cdef long *vertices
    cdef long asize = self.zonemap.__get_max_sphere_count()*sizeof(long)

    cdef long e1
    cdef long e2

    cdef long v1
    cdef long v2
    cdef long s1
    cdef long s2

    with nogil, parallel(num_threads=procs):

      for v in prange(vnum, schedule='guided'):

        if self.VA[v]<1:
          continue

        s1 = self.VS[v]

        e1 = self.VE[2*v]
        e2 = self.VE[2*v+1]

        # connected vertices to v, v1 and v2

        if self.EV[2*e1] == v:
          v1 = self.EV[2*e1+1]
        else:
          v1 = self.EV[2*e1]

        if self.EV[2*e2] == v:
          v2 = self.EV[2*e2+1]
        else:
          v2 = self.EV[2*e2]

        x = self.X[v]
        y = self.Y[v]

        vertices = <long *>malloc(asize)
        neighbor_num = self.zonemap.__sphere_vertices(x, y, farl, vertices)

        resx = 0.
        resy = 0.

        for k in range(neighbor_num):

          neigh = vertices[k]

          s2 = self.VS[neigh]
          dx = x-self.X[neigh]
          dy = y-self.Y[neigh]
          nrm = sqrt(dx*dx+dy*dy)

          if nrm<=0.:
            continue

          if s2 == s1:
            # same segment

            if neigh == v1 or neigh == v2:
              # directly linked

              if nrm<nearl:
                # repel
                pass
                #resx += dx/nrm*step
                #resy += dy/nrm*step

              else:
                # attract
                resx += -dx/nrm*step
                resy += -dy/nrm*step

            else:
              # not directly linked. do nothing

              pass

              #if nrm<farl:
                ## reject
                #resx += dx*(farl/nrm-1)*step
                #resy += dy*(farl/nrm-1)*step

          else:
            # not same segment

            if nrm<freeze_distance:
              # set passive
              self.SD[v] = 1
              continue

            if nrm<farl:
              # attract
              resx += -dx*(farl/nrm-1)*step
              resy += -dy*(farl/nrm-1)*step

        self.SX[v] += resx
        self.SY[v] += resy

        free(vertices)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef long optimize_avoid(self, double step):

    double_array_init(self.SX,self.vnum,0.)
    double_array_init(self.SY,self.vnum,0.)

    self.__optimize_avoid(step)

    for v in range(self.vnum):

      if self.VA[v]<0:
        continue

      self.X[v] += self.SX[v]
      self.Y[v] += self.SY[v]

      self.zonemap.__update_v(v)

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef long optimize_contract(self, double step, double freeze_distance):

    double_array_init(self.SX,self.vnum,0.)
    double_array_init(self.SY,self.vnum,0.)

    long_array_init(self.SD,self.vnum,-1)

    self.__optimize_contract(step, freeze_distance)

    cdef double x
    cdef double y

    for v in range(self.vnum):

      if self.VA[v]<0:
        continue

      if self.SD[v]>0:
        self.__set_passive_vertex(v)
        continue

      self.X[v] += self.SX[v]
      self.Y[v] += self.SY[v]

      self.zonemap.__update_v(v)

