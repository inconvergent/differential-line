# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython
from libc.stdlib cimport malloc, free

from libc.math cimport cos
from libc.math cimport sin
from libc.math cimport sqrt
from libc.math cimport fabs

from helpers cimport long_array_init
from helpers cimport double_array_init
from helpers cimport add_e_to_ve
from helpers cimport del_e_from_ve

import numpy as np
cimport numpy as np
cimport cython

from zonemap cimport Zonemap


cdef class Segments:
  """
  linked vertex segments optimized for differential growth-like operations
  like spltting edges by inserting new vertices, and collapsing edges.

  all vertices must exist within the unit square.
  """

  def __init__(self, long nmax, double zonewidth):
    """
    initialize triangular mesh.

    - nmax is the maximal number of vertices/edges. storage is reserved upon
      instantiation
    """

    self.nmax = nmax

    self.vnum = 0

    self.vact = 0

    self.enum = 0

    self.snum = 0

    self.zonewidth = zonewidth

    self.nz = long(1.0 /zonewidth)

    if self.nz<3:
      self.nz = 1
      self.zonewidth = 1.0

    self.zonemap = Zonemap(self.nz)
    self.zonemap.__assign_xy_arrays(self.X, self.Y)

    print('nmax: {:d}'.format(nmax))
    print('number of zones: {:d}'.format(self.nz))
    print('zonewidth: {:f}'.format(zonewidth))

  def __cinit__(self,long nmax, long nz, *arg, **args):

    self.X = <double *>malloc(nmax*sizeof(double))
    double_array_init(self.X,nmax,0.)

    self.Y = <double *>malloc(nmax*sizeof(double))
    double_array_init(self.Y,nmax,0.)

    self.VA = <long *>malloc(nmax*sizeof(long))
    long_array_init(self.VA,nmax,-1)

    self.VS = <long *>malloc(nmax*sizeof(long))
    long_array_init(self.VS,nmax,-1)

    self.EV = <long *>malloc(2*nmax*sizeof(long))
    long_array_init(self.EV,2*nmax,-1)

    self.VE = <long *>malloc(2*nmax*sizeof(long))
    long_array_init(self.VE,2*nmax,-1)

  def __dealloc__(self):

    free(self.X)

    free(self.Y)

    free(self.VA)

    free(self.VS)

    free(self.EV)

    free(self.VE)

    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __valid_new_vertex(self, double x, double y):

    if x<0. or x>1.:
      return -1

    if y<0. or y>1.:
      return -1

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __add_vertex(self,double x,double y, long s):
    """
    adds a vertex x,y. returns id of new vertex
    """

    if self.__valid_new_vertex(x,y)<0:
      raise ValueError('Vertex outside unit square.')

    cdef long vnum = self.vnum

    self.X[vnum] = x
    self.Y[vnum] = y
    self.VA[vnum] = 1
    self.VS[vnum] = s

    self.zonemap.__add_vertex(vnum)

    self.vnum += 1
    return vnum

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __add_passive_vertex(self,double x,double y, long s):
    """
    adds a vertex x,y. returns id of new vertex
    """

    # TODO: this is almost the same as the function above.

    if self.__valid_new_vertex(x,y)<0:
      raise ValueError('Vertex outside unit square.')

    cdef long vnum = self.vnum

    self.X[vnum] = x
    self.Y[vnum] = y
    self.VA[vnum] = 0
    self.VS[vnum] = s

    self.zonemap.__add_vertex(vnum)

    self.vnum += 1
    return vnum

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __valid_new_edge(self, long v1, long v2):

    if v1<0 or v1>self.vnum-1 or self.VA[v1]<0:
      return -1

    if v2<0 or v2>self.vnum-1 or self.VA[v2]<0:
      return -1

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __add_edge(self, long v1, long v2) except -1:
    """
    add edge between vertices v1 and v2. returns id of new edge
    """

    cdef long enum = self.enum
    cdef str err

    if self.__valid_new_edge(v1,v2)<0:
      err = 'invalid vertex in __add_edge v1,v2, '+str(v1)+','+str(v2)
      raise ValueError(err)

    self.EV[2*enum] = v1
    self.EV[2*enum+1] = v2

    add_e_to_ve(v1, enum, self.VE)
    add_e_to_ve(v2, enum, self.VE)

    self.enum += 1
    return enum

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __edge_exists(self, long e1):

    if self.EV[2*e1]>-1 and self.EV[2*e1+1]>-1:
      return 1
    else:
      return -1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __vertex_exists(self, long v1):

    if self.VA[v1]>-1:
      return 1
    else:
      return -1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __vertex_status(self, long v1):

    return self.VA[v1]

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __vertex_segment(self, long v1):

    return self.VS[v1]

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __del_vertex(self, long v1) except -1:
    """
    delete vertex v1.
    """

    self.VA[v1] = -1

    self.zonemap.__del_vertex(v1)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __set_passive_vertex(self, long v1) except -1:
    """
    delete vertex v1.
    """

    self.VA[v1] = 0

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __del_edge(self, long e1) except -1:
    """
    delete edge e1.
    """

    if e1<0 or e1>self.enum-1:
      raise ValueError('invalid edge in __del_edge e1,'+str(e1))

    cdef long v1 = self.EV[2*e1]
    cdef long v2 = self.EV[2*e1+1]

    self.EV[2*e1] = -1
    self.EV[2*e1+1] = -1

    if v1>-1:
      del_e_from_ve(v1, e1, self.VE)
    if v2>-1:
      del_e_from_ve(v2, e1, self.VE)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cdef long __get_edge_normal(self, long s1, double *nn):

    cdef long v1 = self.EV[2*s1]
    cdef long v2 = self.EV[2*s1+1]

    cdef double x1 = self.X[v1]
    cdef double y1 = self.Y[v1]
    cdef double x2 = self.X[v2]
    cdef double y2 = self.Y[v2]

    cdef double nx = -(y2-y1)
    cdef double ny = x2-x1
    cdef double dn = sqrt(nx*nx+ny*ny)

    if dn<=0.:
      raise ValueError('edge normal is <0 in __get_edge_normal')

    nn[0] = nx/dn
    nn[1] = ny/dn

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef long __safe_vertex_positions(self, double limit) nogil:
    """
    check that all vertices are within limit of unit square boundary
    """

    cdef long vnum = self.vnum
    cdef long i

    for i in xrange(vnum):

      if self.X[i]<limit or self.X[i]>1.-limit:

        return -1

      if self.Y[i]<limit or self.Y[i]>1.-limit:

        return -1

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef list get_edges_coordinates(self):
    """
    get list of lists with coordinates x1,y1,x2,y2 of all edges

    TODO: Deprecated?
    """

    cdef long v1
    cdef long v2
    cdef long e
    cdef list res = []
    cdef long enum = self.enum

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        v1 = self.EV[2*e]
        v2 = self.EV[2*e+1]
        res.append([self.X[v1], self.Y[v1],
                    self.X[v2], self.Y[v2]])

    return res

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long np_get_edges_coordinates(self, np.ndarray[double, mode="c",ndim=2] a):
    """
    get all coordinates x1,y1,x2,y2 of all edges
    a = [[x1,y1,x2,y2], ...]
    """

    cdef long enum = self.enum
    cdef long v1
    cdef long v2
    cdef long e
    cdef long n = 0

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        v1 = self.EV[2*e]
        v2 = self.EV[2*e+1]
        a[n,0] = self.X[v1]
        a[n,1] = self.Y[v1]
        a[n,2] = self.X[v2]
        a[n,3] = self.Y[v2]

        n+=1

    return n

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long np_get_edges(self, np.ndarray[long, mode="c",ndim=2] a):
    """
    """

    cdef long e
    cdef long n = 0

    for e in xrange(self.enum):

      if self.EV[2*e]>-1:

        a[n,0] = self.EV[2*e]
        a[n,1] = self.EV[2*e+1]

        n+=1

    return n

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long np_get_vert_coordinates(self, np.ndarray[double, mode="c",ndim=2] a):
    """
    get all coordinates x1,y1 of all alive vertices
    a = [[x1,y1], ...]
    """

    cdef long vnum = self.vnum
    cdef long v
    cdef long n = 0

    for v in xrange(vnum):

      if self.VA[v]>-1:

        a[n,0] = self.X[v]
        a[n,1] = self.Y[v]
        n+=1

    return n

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef double get_greatest_distance(self, double x, double y):
    """
    get greatest distance from x,y of all active or passive vertices
    """

    cdef long vnum = self.vnum
    cdef long v
    cdef double dx
    cdef double dy
    cdef double d
    cdef double dmax = 0.0

    for v in xrange(vnum):

      if self.VA[v]>-1:

        dx = x - self.X[v]
        dy = y - self.Y[v]
        d = sqrt(dx*dx+dy*dy)
        if d>dmax:
          dmax = d

    return dmax

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long np_get_sorted_verts(self, np.ndarray[long, mode="c",ndim=1] a):

    cdef long v1
    cdef long v2
    cdef long e
    cdef long v
    cdef long k
    cdef dict ev_dict = {}
    cdef dict ve_dict = {}
    cdef dict e_visited = {}
    cdef list v_ordered = []
    cdef long enum = self.enum

    cdef long e_start = -1

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        e_start = e

        v1 = self.EV[2*e]
        v2 = self.EV[2*e+1]
        ev_dict[e] = [v1,v2]

        if v1 in ve_dict:
          ve_dict[v1].append(e)
        else:
          ve_dict[v1] = [e]

        if v2 in ve_dict:
          ve_dict[v2].append(e)
        else:
          ve_dict[v2] = [e]

    if e_start>-1:

      e_visited[e_start] = True

      vcurr = ev_dict[e_start][1]
      vend = ev_dict[e_start][0]

      while vend!=vcurr:

        if ve_dict[vcurr][0] in e_visited:
          e = ve_dict[vcurr][1]
        else:
          e = ve_dict[vcurr][0]

        e_visited[e] = True

        v1,v2 = ev_dict[e]

        if v1 == vcurr:
          vcurr = v2
        else:
          vcurr = v1

        v_ordered.append(vcurr)

    for k, v in enumerate(v_ordered):
      a[k] = v

    return len(v_ordered)

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long np_get_sorted_vert_coordinates(self, np.ndarray[double, mode="c",ndim=2] a):
    """
    get list of lists with coordinates x1,y1,x2,y2 of all edges

    list is sorted, and this only works if we have one single closed
    segment.

    this is not optimized at all.

    """

    cdef long v1
    cdef long v2
    cdef long e
    cdef long v
    cdef long k
    cdef dict ev_dict = {}
    cdef dict ve_dict = {}
    cdef dict e_visited = {}
    cdef list v_ordered = []
    cdef long enum = self.enum

    cdef long e_start = -1

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        e_start = e

        v1 = self.EV[2*e]
        v2 = self.EV[2*e+1]
        ev_dict[e] = [v1,v2]

        if v1 in ve_dict:
          ve_dict[v1].append(e)
        else:
          ve_dict[v1] = [e]

        if v2 in ve_dict:
          ve_dict[v2].append(e)
        else:
          ve_dict[v2] = [e]

    if e_start>-1:

      e_visited[e_start] = True

      vcurr = ev_dict[e_start][1]
      vend = ev_dict[e_start][0]

      while vend!=vcurr:

        if ve_dict[vcurr][0] in e_visited:
          e = ve_dict[vcurr][1]
        else:
          e = ve_dict[vcurr][0]

        e_visited[e] = True

        v1,v2 = ev_dict[e]

        if v1 == vcurr:
          vcurr = v2
        else:
          vcurr = v1

        v_ordered.append(vcurr)

    for k, v in enumerate(v_ordered):
      a[k,0] = self.X[v]
      a[k,1] = self.Y[v]

    return len(v_ordered)

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef list get_edges(self):
    """
    get list of edges
    """

    cdef long e
    cdef list res = []
    cdef long enum = self.enum

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        res.append(e)

    return res

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef list get_edges_vertices(self):
    """
    get list of lists of edge vertices
    """

    cdef long e
    cdef list res = []
    cdef long enum = self.enum

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        res.append([self.EV[2*e],self.EV[2*e+1]])

    return res

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef double get_edge_length(self, long e1):

    cdef double nx = <double>(self.X[self.EV[2*e1]] - self.X[self.EV[2*e1+1]])
    cdef double ny = <double>(self.Y[self.EV[2*e1]] - self.Y[self.EV[2*e1+1]])
    cdef double length = sqrt(nx*nx+ny*ny)

    return length

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef list get_edge_vertices(self, long e1):

    return [self.EV[2*e1], self.EV[2*e1+1]]

  cpdef init_line_segment(self, list xys, long lock_edges=1):

    cdef list vertices = []
    cdef long snum = self.snum
    cdef double xx
    cdef double yy
    cdef long i

    if lock_edges>0:
      xx,yy = xys[0]
      vertices.append(self.__add_passive_vertex(xx,yy,snum))

      for xx,yy in xys[1:-1]:
        vertices.append(self.__add_vertex(xx,yy,snum))

      xx,yy = xys[-1]
      vertices.append(self.__add_passive_vertex(xx,yy,snum))

    else:
      for xx,yy in xys:
        vertices.append(self.__add_vertex(xx,yy,snum))

    for i in xrange(len(vertices)-1):
      self.__add_edge(vertices[i],vertices[i+1])

    self.snum = snum+1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef init_passive_line_segment(self, list xys):

    cdef list vertices = []
    cdef long snum = self.snum
    cdef double xx
    cdef double yy
    cdef long i

    for xx,yy in xys:
      vertices.append(self.__add_passive_vertex(xx,yy,snum))

    for i in xrange(len(vertices)-1):
      self.__add_edge(vertices[i],vertices[i+1])

    self.snum = snum+1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef init_circle_segment(self, double x, double y, double r, list angles):

    cdef list vertices = []
    cdef double xx
    cdef double yy
    cdef double the
    cdef long i
    cdef long snum = self.snum

    cdef long num_angles = len(angles)

    for i in xrange(num_angles):
      the = angles[i]

      xx = x + cos(the)*r
      yy = y + sin(the)*r

      vertices.append(self.__add_vertex(xx,yy,snum))

    for i in xrange(len(vertices)-1):
      self.__add_edge(vertices[i],vertices[i+1])

    self.__add_edge(vertices[0],vertices[num_angles-1])
    self.snum = snum+1

  cpdef init_passive_circle_segment(self, double x, double y, double r, list angles):

    cdef list vertices = []
    cdef double xx
    cdef double yy
    cdef double the
    cdef long i
    cdef long snum = self.snum

    for i in xrange(len(angles)):
      the = angles[i]

      xx = x + cos(the)*r
      yy = y + sin(the)*r

      vertices.append(self.__add_passive_vertex(xx,yy,snum))

    for i in xrange(len(vertices)-1):
      seg = self.__add_edge(vertices[i],vertices[i+1])

    self.__add_edge(vertices[0],vertices[-1])
    self.snum = snum+1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef long collapse_edge(self, long e1, double maximum_length=-1.) except -1:

    if self.__edge_exists(e1)<0:
      raise ValueError('e1 does not exist')

    if e1<0:
      raise ValueError('invalid edge in split_edge e1,'+str(e1))

    cdef long v1 = self.EV[2*e1]
    cdef long v2 = self.EV[2*e1+1]

    if self.VA[v1] < 1 or self.VA[v2] < 1:
      raise ValueError('edge is connected to passive vertex.')

    cdef long e2
    cdef long v3

    if self.VE[2*v1] == e1:
      e2 = self.VE[2*v1+1]
    else:
      e2 = self.VE[2*v1]

    if self.EV[2*e2] == v1:
      v3 = self.EV[2*e2+1]
    else:
      v3 = self.EV[2*e2]

    cdef double dx
    cdef double dy

    if maximum_length>0.:
      dx = self.X[v1] - self.X[v2]
      dy = self.Y[v1] - self.Y[v2]

      if dx*dx+dy*dy>maximum_length*maximum_length:
        raise ValueError('edge too long, e1,'+str(e1))

    self.X[v2] = (self.X[v1] + self.X[v2])*0.5
    self.Y[v2] = (self.Y[v1] + self.Y[v2])*0.5

    self.__del_edge(e1)
    self.__del_edge(e2)

    self.__del_vertex(v1)
    self.__add_edge(v3,v2)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef long split_edge(self, long e1, double minimum_length=-1.) except -1:

    if self.__edge_exists(e1)<0:
      raise ValueError('e1 does not exist')

    if e1<0:
      raise ValueError('invalid edge in split_edge e1,'+str(e1))

    cdef long v1 = self.EV[2*e1]
    cdef long v2 = self.EV[2*e1+1]

    cdef double dx
    cdef double dy
    cdef long s = self.VS[v1]

    if s<0:
      raise ValueError('Invalid segment id.')

    #if self.VA[v1] < 1 and self.VA[v2] < 1:
      #raise ValueError('edge is connected to passive vertex.')

    if minimum_length>0.:
      dx = self.X[v1] - self.X[v2]
      dy = self.Y[v1] - self.Y[v2]

      if dx*dx+dy*dy<minimum_length*minimum_length:
        raise ValueError('edge too short, e1,'+str(e1))

    cdef double midx = (self.X[v1] + self.X[v2])*0.5
    cdef double midy = (self.Y[v1] + self.Y[v2])*0.5

    cdef long v3 = self.__add_vertex(midx,midy,s)
    self.__del_edge(e1)

    self.__add_edge(v1,v3)
    self.__add_edge(v2,v3)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef split_long_edges(self, double limit):
    """
    split all edges longer than limit
    """

    cdef long enum = self.enum
    cdef long v1
    cdef long v2
    cdef double dx
    cdef double dy
    cdef double d
    cdef long e

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        v1 = self.EV[2*e]
        v2 = self.EV[2*e+1]

        if self.VA[v1]<1 and self.VA[v2]<1:
          # edge is passive/dead
          continue

        dx = self.X[v1] - self.X[v2]
        dy = self.Y[v1] - self.Y[v2]
        d = sqrt(dx*dx+dy*dy)

        if d>limit:
          self.split_edge(e)

    return

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef double get_edge_curvature(self, long e1) except -1.0:

    """
    Gives an estimate of edge, e1, using the cross product of e1 and both the
    connected edges of e1. This is not really the curvature in the mathematical
    sense.
    """

    if self.__edge_exists(e1)<0:
      raise ValueError('e1 does not exist')

    if e1<0:
      raise ValueError('invalid edge in split_edge e1,'+str(e1))

    cdef long va = self.EV[2*e1]
    cdef long vb = self.EV[2*e1+1]

    if va<0 or vb<0:
      raise ValueError('non-vertex.')

    cdef long e2
    cdef long e3

    if self.VE[2*va] == self.VE[2*vb]:
      e2 = self.VE[2*va+1]
      e3 = self.VE[2*vb+1]
    elif self.VE[2*va] == self.VE[2*vb+1]:
      e2 = self.VE[2*va+1]
      e3 = self.VE[2*vb]
    elif self.VE[2*va+1] == self.VE[2*vb]:
      e2 = self.VE[2*va]
      e3 = self.VE[2*vb+1]
    elif self.VE[2*va+1] == self.VE[2*vb+1]:
      e2 = self.VE[2*va]
      e3 = self.VE[2*vb]
    else:
      raise ValueError('edges not connected')

    cdef double ax
    cdef double bx
    cdef double ay
    cdef double by
    cdef long v1
    cdef long v2
    cdef long v3 = self.EV[2*e1]
    cdef long v4 = self.EV[2*e1+1]

    cdef double t = 0.0

    if e2>-1:
      v1 = self.EV[2*e2]
      v2 = self.EV[2*e2+1]

      ax = self.X[v1] - self.X[v2]
      bx = self.X[v3] - self.X[v4]
      ay = self.Y[v1] - self.Y[v2]
      by = self.Y[v3] - self.Y[v4]

      t += fabs(ax*by - ay*bx)*0.5

    if e3>-1:
      v1 = self.EV[2*e3]
      v2 = self.EV[2*e3+1]

      ax = self.X[v1] - self.X[v2]
      bx = self.X[v3] - self.X[v4]
      ay = self.Y[v1] - self.Y[v2]
      by = self.Y[v3] - self.Y[v4]

      t += fabs(ax*by - ay*bx)*0.5

    if t<=0:
      raise ValueError('no curvature.')

    return t

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long get_active_vertex_count(self):

    cdef long c = 0

    for v in xrange(self.vnum):
      if self.VA[v]>0:
        c += 1

    return c

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long safe_vertex_positions(self, double limit):

    return self.__safe_vertex_positions(limit)

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long get_snum(self):

    return self.snum

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long get_vnum(self):

    return self.vnum

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef long get_enum(self):

    return self.enum

