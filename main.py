#!/usr/bin/python3
# -*- coding: utf-8 -*-

from numpy import pi
from modules.growth import spawn
# from modules.growth import spawn_curl
from numpy import zeros

NMAX = 10**6
SIZE = 2800
ONE = 1./SIZE

PROCS = 6

INIT_RAD = 25*ONE
INIT_NUM = 40


STP = ONE*0.4
NEARL = 3*ONE
FARL = 40*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,5]

TWOPI = pi*2.

STAT_ITT = 10
EXPORT_ITT = 100


np_verts = zeros((NMAX,2), 'double')
np_edges = zeros((NMAX,4), 'double')


def main():

  from time import time
  from itertools import count

  from iutils.render import Render
  from modules.helpers import print_stats
  from modules.show import show
  # from modules.show import show_closed

  from differentialLine import DifferentialLine
  from modules.helpers import get_exporter

  from numpy.random import random

  from fn import Fn

  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

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

  render = Render(SIZE, BACK, FRONT)

  render.ctx.set_source_rgba(*FRONT)
  render.ctx.set_line_width(LINEWIDTH)

  angles = sorted(random(INIT_NUM)*TWOPI)

  DF.init_circle_segment(MID,MID,INIT_RAD, angles)

  t_start = time()


  for i in count():

    DF.optimize_position(STP)
    # spawn_curl(DF,NEARL)
    spawn(DF, NEARL, 0.03)

    if i % STAT_ITT == 0:

      print_stats(i,time()-t_start,DF)

    if i % EXPORT_ITT == 0:

      name = fn.name()

      num = DF.np_get_edges_coordinates(np_edges)
      show(render,np_edges[:num,:],name+'.png')

      exporter(
        DF,
        name+'.2obj'
      )


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

