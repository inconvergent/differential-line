#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function

from numpy import pi
from numpy.random import random
from modules.growth import spawn_curl
from numpy import zeros


NMAX = 10**6
SIZE = 1000
ONE = 1./SIZE

PROCS = 2

INIT_RAD = 25*ONE
INIT_NUM = 40


STP = ONE*0.2
NEARL = 5*ONE
FARL = 2.5*30*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,5]
RED = [1,0,0,0.3]

TWOPI = pi*2.

ZONEWIDTH = 2.*FARL/ONE
NZ = int(SIZE/ZONEWIDTH)

print('NZ', NZ)
print('ZONEWIDTH', ZONEWIDTH)

i = 0


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


np_coords = zeros(shape=(NMAX,4), dtype='float')
np_vert_coords = zeros(shape=(NMAX,2), dtype='float')


def main():

  import gtk

  from render.render import Animate
  from differentialLine import DifferentialLine

  from modules.show import show_closed
  from modules.show import show_detail
  from modules.show import show


  DF = DifferentialLine(NMAX, NZ, NEARL, FARL, PROCS)

  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,INIT_RAD, angles)


  def wrap(render):

    global i

    # animation stops when res is False
    res = steps(DF)

    ## if fn is a path each image will be saved to that path
    fn = None
    ##fn = './res/ani{:04d}.png'.format(i)

    ## render outline
    num = DF.np_get_edges_coordinates(np_coords)
    show(render,np_coords[:num,:],fn,r=ONE*2)

    ## render solid
    #sorted_vert_coordinates = DF.get_sorted_vert_coordinates()
    #show_closed(render,sorted_vert_coordinates,fn)

    ## render outline with marked circles
    #num = DF.np_get_edges_coordinates(np_coords)
    #show_detail(render,np_coords[:num,:],fn)

    i += 1

    return res

  render = Animate(SIZE, BACK, FRONT, wrap)

  gtk.main()


if __name__ == '__main__':

  main()

