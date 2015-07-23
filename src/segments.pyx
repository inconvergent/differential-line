# -*- coding: utf-8 -*-
# cython: profile=True

from __future__ import division

cimport cython
from libc.stdlib cimport malloc, free

from libc.math cimport cos
from libc.math cimport sin
from libc.math cimport sqrt
from libc.math cimport fabs 

from helpers cimport int_array_init
from helpers cimport float_array_init
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

  def __init__(self, int nmax, nz):
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

    self.zonemap = Zonemap(nz)
    self.zonemap.__assign_xy_arrays(self.X, self.Y)

  def __cinit__(self,int nmax, int nz, *arg, **args):

    self.X = <float *>malloc(nmax*sizeof(float))
    float_array_init(self.X,nmax,0.)

    self.Y = <float *>malloc(nmax*sizeof(float))
    float_array_init(self.Y,nmax,0.)

    self.VA = <int *>malloc(nmax*sizeof(int))
    int_array_init(self.VA,nmax,-1)

    self.VS = <int *>malloc(nmax*sizeof(int))
    int_array_init(self.VS,nmax,-1)

    self.EV = <int *>malloc(2*nmax*sizeof(int))
    int_array_init(self.EV,2*nmax,-1)

    self.VE = <int *>malloc(2*nmax*sizeof(int))
    int_array_init(self.VE,2*nmax,-1)

  def __dealloc__(self):

    free(self.X)

    free(self.Y)

    free(self.VA)

    free(self.VS)

    free(self.EV)

    free(self.VE)

    return

  cdef int __valid_new_vertex(self, float x, float y):

    if x<0. or x>1.:
      return -1

    if y<0. or y>1.:
      return -1

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __add_vertex(self,float x,float y, int s):
    """
    adds a vertex x,y. returns id of new vertex
    """

    if self.__valid_new_vertex(x,y)<0:
      raise ValueError('Vertex outside unit square.')

    cdef int vnum = self.vnum

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
  cdef int __add_passive_vertex(self,float x,float y, int s):
    """
    adds a vertex x,y. returns id of new vertex
    """

    # TODO: this is almost the same as the function above.

    if self.__valid_new_vertex(x,y)<0:
      raise ValueError('Vertex outside unit square.')

    cdef int vnum = self.vnum

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
  cdef int __valid_new_edge(self, int v1, int v2):

    if v1<0 or v1>self.vnum-1 or self.VA[v1]<0:
      return -1

    if v2<0 or v2>self.vnum-1 or self.VA[v2]<0:
      return -1

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __add_edge(self, int v1, int v2) except -1:
    """
    add edge between vertices v1 and v2. returns id of new edge
    """

    cdef int enum = self.enum
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
  cdef int __edge_exists(self, int e1):

    if self.EV[2*e1]>-1 and self.EV[2*e1+1]>-1:
      return 1
    else:
      return -1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __vertex_exists(self, int v1):

    if self.VA[v1]>-1:
      return 1
    else:
      return -1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __vertex_status(self, int v1):

    return self.VA[v1]

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __vertex_segment(self, int v1):

    return self.VS[v1]

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __del_vertex(self, int v1) except -1:
    """
    delete vertex v1.
    """

    self.VA[v1] = -1

    self.zonemap.__del_vertex(v1)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __set_passive_vertex(self, int v1) except -1:
    """
    delete vertex v1.
    """

    self.VA[v1] = 0

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cdef int __del_edge(self, int e1) except -1:
    """
    delete edge e1.
    """

    if e1<0 or e1>self.enum-1:
      raise ValueError('invalid edge in __del_edge e1,'+str(e1))

    cdef int v1 = self.EV[2*e1]
    cdef int v2 = self.EV[2*e1+1]

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
  cdef int __get_edge_normal(self, int s1, float *nn):

    cdef int v1 = self.EV[2*s1]
    cdef int v2 = self.EV[2*s1+1]

    cdef float x1 = self.X[v1]
    cdef float y1 = self.Y[v1]
    cdef float x2 = self.X[v2]
    cdef float y2 = self.Y[v2]

    cdef float nx = -(y2-y1)
    cdef float ny = x2-x1
    cdef float dn = sqrt(nx*nx+ny*ny)

    if dn<=0.:
      raise ValueError('edge normal is <0 in __get_edge_normal')

    nn[0] = nx/dn
    nn[1] = ny/dn

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef list get_edges_coordinates(self):
    """
    get list of lists with coordinates x1,y1,x2,y2 of all edges
    
    TODO: Deprecated?
    """

    cdef int v1
    cdef int v2
    cdef int e
    cdef list res = []
    cdef int enum = self.enum

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
  cpdef int np_get_edges_coordinates(self, np.ndarray[double, mode="c",ndim=2] a):
    """
    get all coordinates x1,y1,x2,y2 of all edges
    a = [[x1,y1,x2,y2], ...]
    """

    cdef int enum = self.enum
    cdef int v1
    cdef int v2
    cdef int e
    cdef int n = 0

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
  cpdef int np_get_vert_coordinates(self, np.ndarray[double, mode="c",ndim=2] a):
    """
    get all coordinates x1,y1 of all alive vertices
    a = [[x1,y1], ...]
    """

    cdef int vnum = self.vnum
    cdef int v
    cdef int n = 0

    for v in xrange(vnum):

      if self.VA[v]>-1:

        a[n,0] = self.X[v]
        a[n,1] = self.Y[v]
        n+=1

    return n

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef float get_greatest_distance(self, float x, float y):
    """
    get greatest distance from x,y of all active or passive vertices
    """

    cdef int vnum = self.vnum
    cdef int v
    cdef float dx
    cdef float dy
    cdef float d
    cdef float dmax = 0.0

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
  cpdef list get_sorted_vert_coordinates(self):
    """
    get list of lists with coordinates x1,y1,x2,y2 of all edges

    list is sorted, and this only works if we have one single closed
    segment.

    this is not optimized at all.

    """

    cdef int v1
    cdef int v2
    cdef int e
    cdef list res = []
    cdef dict ev_dict = {}
    cdef dict ve_dict = {}
    cdef dict e_visited = {}
    cdef list v_ordered = []
    cdef int enum = self.enum
    
    cdef int e_start = -1

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

    for v in v_ordered:
        res.append([self.X[v], self.Y[v]])

    return res

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef list get_edges(self):
    """
    get list of edges
    """

    cdef int e
    cdef list res = []
    cdef int enum = self.enum

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

    cdef int e
    cdef list res = []
    cdef int enum = self.enum

    for e in xrange(enum):

      if self.EV[2*e]>-1:

        res.append([self.EV[2*e],self.EV[2*e+1]])

    return res

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  @cython.cdivision(True)
  cpdef float get_edge_length(self, int e1):

    cdef float nx = <float>(self.X[self.EV[2*e1]] - self.X[self.EV[2*e1+1]])
    cdef float ny = <float>(self.Y[self.EV[2*e1]] - self.Y[self.EV[2*e1+1]])
    cdef float length = sqrt(nx*nx+ny*ny)

    return length

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef list get_edge_vertices(self, int e1):

    return [self.EV[2*e1], self.EV[2*e1+1]]

  cpdef init_line_segment(self, list xys, int lock_edges=1):

    cdef list vertices = []
    cdef int snum = self.snum
    cdef float xx
    cdef float yy
    cdef int i

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

  cpdef init_passive_line_segment(self, list xys):

    cdef list vertices = []
    cdef int snum = self.snum
    cdef float xx
    cdef float yy
    cdef int i

    for xx,yy in xys:
      vertices.append(self.__add_passive_vertex(xx,yy,snum))

    for i in xrange(len(vertices)-1):
      self.__add_edge(vertices[i],vertices[i+1])

    self.snum = snum+1

  cpdef init_circle_segment(self, float x, float y, float r, list angles):

    cdef list vertices = []
    cdef float xx
    cdef float yy
    cdef float the
    cdef int i
    cdef int snum = self.snum

    for i in xrange(len(angles)):
      the = angles[i]

      xx = x + cos(the)*r
      yy = y + sin(the)*r

      vertices.append(self.__add_vertex(xx,yy,snum))

    for i in xrange(len(vertices)-1):
      self.__add_edge(vertices[i],vertices[i+1])

    self.__add_edge(vertices[0],vertices[-1])
    self.snum = snum+1

  cpdef init_passive_circle_segment(self, float x, float y, float r, list angles):

    cdef list vertices = []
    cdef float xx
    cdef float yy
    cdef float the
    cdef int i
    cdef int snum = self.snum

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
  cpdef int collapse_edge(self, int e1, float maximum_length=-1.) except -1:

    if self.__edge_exists(e1)<0:
      raise ValueError('e1 does not exist')

    if e1<0:
      raise ValueError('invalid edge in split_edge e1,'+str(e1))
    
    cdef int v1 = self.EV[2*e1]
    cdef int v2 = self.EV[2*e1+1]

    if self.VA[v1] < 1 or self.VA[v2] < 1:
      raise ValueError('edge is connected to passive vertex.')

    cdef int e2
    cdef int v3

    if self.VE[2*v1] == e1:
      e2 = self.VE[2*v1+1]
    else:
      e2 = self.VE[2*v1]

    if self.EV[2*e2] == v1:
      v3 = self.EV[2*e2+1]
    else:
      v3 = self.EV[2*e2]

    cdef float dx
    cdef float dy

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
  cpdef int split_edge(self, int e1, float minimum_length=-1.) except -1:

    if self.__edge_exists(e1)<0:
      raise ValueError('e1 does not exist')

    if e1<0:
      raise ValueError('invalid edge in split_edge e1,'+str(e1))

    cdef int v1 = self.EV[2*e1]
    cdef int v2 = self.EV[2*e1+1]

    cdef float dx
    cdef float dy
    cdef int s = self.VS[v1]

    if s<0:
      raise ValueError('Invalid segment id.')

    #if self.VA[v1] < 1 and self.VA[v2] < 1:
      #raise ValueError('edge is connected to passive vertex.')

    if minimum_length>0.:
      dx = self.X[v1] - self.X[v2]
      dy = self.Y[v1] - self.Y[v2]

      if dx*dx+dy*dy<minimum_length*minimum_length:
        raise ValueError('edge too short, e1,'+str(e1))

    cdef float midx = (self.X[v1] + self.X[v2])*0.5
    cdef float midy = (self.Y[v1] + self.Y[v2])*0.5

    cdef int v3 = self.__add_vertex(midx,midy,s)
    self.__del_edge(e1)

    self.__add_edge(v1,v3)
    self.__add_edge(v2,v3)

    return 1

  @cython.wraparound(False)
  @cython.boundscheck(False)
  @cython.nonecheck(False)
  cpdef split_long_edges(self, float limit):
    """
    split all edges longer than limit
    """

    cdef int enum = self.enum
    cdef int v1
    cdef int v2
    cdef float dx
    cdef float dy
    cdef float d
    cdef int e

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
  cpdef float get_edge_curvature(self, int e1) except -1.0:

    """
    Gives an estimate of edge, e1, using the cross product of e1 and both the
    connected edges of e1. This is not really the curvature in the mathematical
    sense.
    """

    if self.__edge_exists(e1)<0:
      raise ValueError('e1 does not exist')

    if e1<0:
      raise ValueError('invalid edge in split_edge e1,'+str(e1))

    cdef int va = self.EV[2*e1]
    cdef int vb = self.EV[2*e1+1]

    if va<0 or vb<0:
      raise ValueError('non-vertex.')

    cdef int e2 
    cdef int e3

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

    cdef float ax
    cdef float bx
    cdef float ay
    cdef float by
    cdef int v1
    cdef int v2
    cdef int v3 = self.EV[2*e1]
    cdef int v4 = self.EV[2*e1+1]

    cdef float t = 0.0

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

  cpdef int get_active_vertex_count(self):

    cdef int c = 0

    for v in xrange(self.vnum):
      if self.VA[v]>0:
        c += 1

    return c

  cpdef int get_snum(self):

    return self.snum

  cpdef int get_vnum(self):

    return self.vnum

  cpdef int get_enum(self):

    return self.enum

