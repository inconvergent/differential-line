#!/usr/bin/python3
# -*- coding: utf-8 -*-



from numpy import pi
from numpy.random import random
from modules.growth import spawn_curl
from modules.growth import spawn
from numpy import zeros

NMAX = 10**6
SIZE = 1000
ONE = 1./SIZE

PROCS = 6

INIT_RAD = 25*ONE
INIT_NUM = 40


STP = ONE*0.4
NEARL = 2*ONE
FARL = 40*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,5]

TWOPI = pi*2.


i = 0


def steps(df):

  from time import time
  from modules.helpers import print_stats


  global i

  t1 = time()
  df.optimize_position(STP)
  # spawn_curl(df, NEARL)
  spawn(df, NEARL, 0.001)

  if df.safe_vertex_positions(3*STP)<0:

    print('vertices reached the boundary. stopping.')
    return False

  t2 = time()
  print_stats(i, t2-t1, df)

  return True


np_edges = zeros(shape=(NMAX,4), dtype='float')
np_verts = zeros(shape=(NMAX,2), dtype='float')


def main():

  from iutils.render import Animate
  from differentialLine import DifferentialLine
  from modules.helpers import get_exporter

  # from modules.show import show_closed
  # from modules.show import show_detail
  from modules.show import show


  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,INIT_RAD, angles)

  from fn import Fn
  fn = Fn(prefix='./res/')

  exporter = get_exporter(
    NMAX,
    {
      'nearl': NEARL,
      'farl': FARL,
      'stp': STP,
      'size': SIZE,
      'procs': PROCS
    }
  )

  def wrap(render):

    global i

    # animation stops when res is False
    res = steps(DF)

    ## if fn is a path each image will be saved to that path

    ## render outline
    num = DF.np_get_edges_coordinates(np_edges)
    if not i % 100:
      show(render,np_edges[:num,:], None, r=1.3*ONE)
      # render.write_to_png(fn.name())
      exporter(
        DF,
        fn.name()+'.2obj'
      )

    ## render solid
    # num = DF.get_sorted_vert_coordinates(np_verts)
    #show_closed(render,np_verts[:num,:],fn)

    i += 1

    return res

  render = Animate(SIZE, BACK, FRONT, wrap)
  render.start()



if __name__ == '__main__':

  main()

