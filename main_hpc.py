#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi
from numpy.random import random
from modules.growth import spawn_curl

NMAX = 10**7
SIZE = 20000
ONE = 1./SIZE

RAD = 0.1

STP = ONE*0.5
NEARL = 4*ONE
FARL = 200*ONE

PROCS = 16

MID = 0.5

LINEWIDTH = 5.*ONE

NINIT = 20

BACK = [1,1,1,1]
FRONT = [0,0,0,1]

TWOPI = pi*2.

STAT_ITT = 1000
EXPORT_ITT = 1000


def main():

  from time import time
  from itertools import count
  from numpy import zeros

  from modules.helpers import export

  from modules.helpers import print_stats
  from differentialLine import DifferentialLine

  orderd_verts = zeros((NMAX,2), 'double')

  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

  angles = sorted(random(NINIT))

  DF.init_circle_segment(MID,MID,RAD, angles)

  t_start = time()


  for i in count():

    DF.optimize_position(STP)
    spawn_curl(DF,NEARL)

    if i % STAT_ITT == 0:

      print_stats(i,time()-t_start,DF)

    if i % EXPORT_ITT == 0:

      fn = './res/export_a_{:010d}.xobj'.format(i)
      num = DF.np_get_sorted_vert_coordinates(orderd_verts)
      meta = '\nvnum {:d}\ntime {:f}\nnearl {:f}\nfarl {:f}\nstp {:f}'.format(
        num,
        time()-t_start,
        NEARL,
        FARL,
        STP
      )
      export(orderd_verts[:num,:], fn, meta=meta)


if __name__ == '__main__':

  main()

