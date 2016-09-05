#!/usr/bin/python3
# -*- coding: utf-8 -*-



from numpy import pi
from numpy.random import random
from modules.growth import spawn_curl
from modules.growth import spawn
from numpy import zeros

NMAX = 10**6
SIZE = 800
ONE = 1./SIZE

PROCS = 2

INIT_RAD = 25*ONE
INIT_NUM = 40


STP = ONE*0.4
NEARL = 6*ONE
FARL = 60*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,5]
RED = [1,0,0,0.3]

TWOPI = pi*2.


i = 0


def steps(df):

  from time import time
  from modules.helpers import print_stats

  global i

  t1 = time()
  df.optimize_position(STP)
  spawn_curl(df, NEARL)
  #spawn(df, NEARL, 0.05)

  if df.safe_vertex_positions(3*STP)<0:

    print('vertices reached the boundary. stopping.')
    return False

  t2 = time()
  print_stats(i, t2-t1, df)

  return True


np_coords = zeros(shape=(NMAX,4), dtype='float')
np_vert_coords = zeros(shape=(NMAX,2), dtype='float')


def main():

  from iutils.render import Animate
  from differentialLine import DifferentialLine

  from modules.show import show_closed
  from modules.show import show_detail
  from modules.show import show


  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,INIT_RAD, angles)


  def wrap(render):

    global i

    # animation stops when res is False
    res = steps(DF)

    ## if fn is a path each image will be saved to that path
    fn = None

    ## render outline with marked circles
    num = DF.np_get_edges_coordinates(np_coords)
    show_detail(render,np_coords[:num,:],fn)

    i += 1

    return res

  render = Animate(SIZE, BACK, FRONT, wrap)
  render.start()


if __name__ == '__main__':

  main()

