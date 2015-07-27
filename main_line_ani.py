#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function

from numpy import pi, cos, sin
from numpy.random import random
from numpy import zeros, linspace

from modules.growth import spawn_curl


NMAX = 10**6
SIZE = 1000
ONE = 1./SIZE

PROCS = 2

INIT_NUM = 6

STP = ONE*0.1
NEARL = 4*ONE
FARL = 120*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,0.1]

TWOPI = pi*2.

ZONEWIDTH = 2.*FARL/ONE
NZ = int(SIZE/ZONEWIDTH)

print('NZ', NZ)
print('ZONEWIDTH', ZONEWIDTH)

i = 0
np_coords = zeros(shape=(NMAX,4), dtype='float')
np_vert_coords = zeros(shape=(NMAX,2), dtype='float')


def steps(df):

  from time import time
  from modules.helpers import print_stats

  global i

  t1 = time()

  df.optimize_avoid(STP)
  spawn_curl(df, NEARL)

  if df.safe_vertex_positions(3*STP)<0:

    print('vertices reached the boundary. stopping.')
    return False

  t2 = time()
  print_stats(i, t2-t1, df)

  return True


def main():

  import gtk

  from render.render import Animate
  from differentialLine import DifferentialLine

  from modules.show import sandstroke
  from modules.show import dots
  from modules.show import show

  DF = DifferentialLine(NMAX, NZ, NEARL, FARL, PROCS)

  ## arc
  #angles = sorted(random(INIT_NUM)*pi*1.5)
  #xys = []
  #for a in angles:
    #x = 0.5 + cos(a)*0.06
    #y = 0.5 + sin(a)*0.06
    #xys.append((x,y))
  #DF.init_line_segment(xys, lock_edges=1)

  ## vertical line
  #xx = sorted(0.45+0.1*random(INIT_NUM))
  #yy = MID+0.005*(0.5-random(INIT_NUM))
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))
  #DF.init_line_segment(xys, lock_edges=1)

  ## diagonal line
  #yy = sorted(0.2+0.6*random(INIT_NUM))
  #xx = 0.2+linspace(0,0.6,num=INIT_NUM)
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))
  #DF.init_line_segment(xys, lock_edges=1)


  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,FARL*0.2, angles)


  def wrap(steps_itt, render):

    global i
    global np_coords
    global np_vert_coords

    ## if fn is a path each image will be saved to that path
    fn = None
    ##fn = './res/ani{:04d}.png'.format(i)

    res = steps(DF)

    #coord_num = DF.np_get_edges_coordinates(np_coords)
    #sandstroke(render,np_coords[:coord_num,:],10,fn)

    render.set_front(FRONT)
    vert_num = DF.np_get_vert_coordinates(np_vert_coords)
    dots(render,np_vert_coords[:vert_num,:],fn)

    if i%10==0:
      coord_num = DF.np_get_edges_coordinates(np_coords)
      sandstroke(render,np_coords[:coord_num,:],8,None)

    i += 1

    return res

  render = Animate(SIZE, BACK, FRONT, None, wrap)

  gtk.main()


if __name__ == '__main__':

  main()

