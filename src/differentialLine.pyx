# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython
cimport segments

from cython.parallel import parallel, prange

from libc.math cimport sqrt

from helpers cimport float_array_init
from helpers cimport int_array_init
from helpers cimport edges_are_connected

cdef class DifferentialLine(segments.Segments):

  def __init__(self, int nmax, float zonewidth, float nearl, float farl, int procs):

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

  def __cinit__(self, int nmax, *arg, **args):

    self.SX = <float *>malloc(nmax*sizeof(float))

    self.SY = <float *>malloc(nmax*sizeof(float))

    self.SD = <int *>malloc(nmax*sizeof(int))

    self.vertices = <int *>malloc(nmax*sizeof(int))

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
  cdef int __optimize_avoid(self, float step):
    """
    all vertices will move away from all neighboring (closer than farl)
    vertices
    """

    cdef int procs = self.procs
    cdef float farl = self.farl
    cdef float nearl = self.nearl

    cdef int vnum = self.vnum

    cdef unsigned int v
    cdef unsigned int k

    cdef int neigh
    cdef int neighbor_num

    cdef float x
    cdef float y
    cdef float dx
    cdef float dy
    cdef float nrm

    cdef float resx
    cdef float resy

    cdef int *vertices
    cdef int asize = self.zonemap.__get_greatest_zone_size()*9*sizeof(int)

    cdef int e1
    cdef int e2

    cdef int v1
    cdef int v2

    with nogil, parallel(num_threads=procs):

      vertices = <int *>malloc(asize)

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
  cdef int __optimize_contract(self, float step, float freeze_distance):
    """
    all vertices will move away from all neighboring (closer than farl)
    vertices
    """

    cdef int procs = self.procs
    cdef float farl = self.farl
    cdef float nearl = self.nearl

    cdef int vnum = self.vnum

    cdef unsigned int v
    cdef unsigned int k

    cdef int neigh
    cdef int neighbor_num

    cdef float x
    cdef float y
    cdef float dx
    cdef float dy
    cdef float nrm

    cdef float resx
    cdef float resy

    cdef int *vertices
    cdef int asize = self.zonemap.__get_greatest_zone_size()*9*sizeof(int)

    cdef int e1
    cdef int e2

    cdef int v1
    cdef int v2
    cdef int s1
    cdef int s2

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

        vertices = <int *>malloc(asize)
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
  cpdef int optimize_avoid(self, float step):

    float_array_init(self.SX,self.vnum,0.)
    float_array_init(self.SY,self.vnum,0.)

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
  cpdef int optimize_contract(self, float step, float freeze_distance):

    float_array_init(self.SX,self.vnum,0.)
    float_array_init(self.SY,self.vnum,0.)

    int_array_init(self.SD,self.vnum,-1)

    self.__optimize_contract(step, freeze_distance)

    cdef float x
    cdef float y

    for v in range(self.vnum):

      if self.VA[v]<0:
        continue

      if self.SD[v]>0:
        self.__set_passive_vertex(v)
        continue

      self.X[v] += self.SX[v]
      self.Y[v] += self.SY[v]

      self.zonemap.__update_v(v)

