#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi, cos, sin, linspace, zeros
from numpy.random import random, seed
from modules.growth import spawn, spawn_curl

NMAX = 10**7
SIZE = 5000
ONE = 1./SIZE

PREFIX = './res/export'
EXPORT_ITT = 10

STP = ONE*0.02
NEARL = 15*ONE
FARL = 0.235

PROCS = 6

MID = 0.5

LINEWIDTH = 5.*ONE

INIT_NUM = 12

BACK = [1,1,1,1]
FRONT = [0,0,0,0.08]

TWOPI = pi*2.


def main():

  from time import time
  from itertools import count

  from differentialLine import DifferentialLine

  from modules.helpers import print_stats
  from modules.helpers import get_exporter

  from modules.show import sandstroke
  from modules.show import show
  from modules.show import dots


  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)
  exporter = get_exporter(NMAX)

  orderd_verts = zeros((NMAX,2), 'double')


  ## arc

  # angles = sorted(random(INIT_NUM)*pi*1.5)
  # xys = []
  # for a in angles:
    # x = 0.5 + cos(a)*0.2
    # y = 0.5 + sin(a)*0.2
    # xys.append((x,y))

  # DF.init_line_segment(xys, lock_edges=1)

  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,0.2, angles)


  for i in count():

    t_start = time()

    DF.optimize_position(STP)
    spawn_curl(DF,NEARL,0.016)

    if i % EXPORT_ITT == 0:

      exporter(
        DF, 
        {
          'nearl': NEARL,
          'farl': FARL,
          'stp': STP,
          'size': SIZE,
          'procs': PROCS,
          'prefix': PREFIX
        },
        i,
      )


    t_stop = time()

    print_stats(i,t_stop-t_start,DF)

if __name__ == '__main__':

    main()

