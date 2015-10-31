#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi
from numpy.random import random, seed
from modules.growth import spawn, spawn_curl

NMAX = 10**7
SIZE = 10000
ONE = 1./SIZE

RAD = 0.1

STP = ONE*0.5
NEARL = 4*ONE
FARL = 200*ONE

PROCS = 6

MID = 0.5

LINEWIDTH = 5.*ONE

NINIT = 20

BACK = [1,1,1,1]
FRONT = [0,0,0,1]

TWOPI = pi*2.

STAT_ITT = 500
EXPORT_ITT = 500


def main():

  from time import time
  from itertools import count

  from render.render import Render
  from modules.helpers import print_stats
  from modules.show import show
  from modules.show import show_closed

  from differentialLine import DifferentialLine


  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

  render = Render(SIZE, BACK, FRONT)

  render.ctx.set_source_rgba(*FRONT)
  render.ctx.set_line_width(LINEWIDTH)

  angles = sorted(random(NINIT)*TWOPI)

  DF.init_circle_segment(MID,MID,RAD, angles)

  t_start = time()


  for i in count():

    DF.optimize_position(STP)
    spawn_curl(DF,NEARL)

    if i % STAT_ITT == 0:

      print_stats(i,time()-t_start,DF)

    if i % EXPORT_ITT == 0:

      fn = './res/oryx_bb_{:010d}.png'.format(i)
      edges_coordinates = DF.get_edges_coordinates()
      show(render,edges_coordinates,fn)

      fn = './res/oryx_bb_closed_{:010d}.png'.format(i)
      sorted_vert_coordinates = DF.get_sorted_vert_coordinates()
      show_closed(render,sorted_vert_coordinates,fn)


if __name__ == '__main__':

  if False:

    import pyximport
    pyximport.install()
    import pstats, cProfile

    fn = './profile/profile'
    cProfile.runctx("main()", globals(), locals(), fn)
    p = pstats.Stats(fn)
    p.strip_dirs().sort_stats('cumulative').print_stats()

  else:

    main()

