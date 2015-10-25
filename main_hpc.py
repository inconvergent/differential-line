#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi
from numpy.random import random
from modules.growth import spawn_curl

TWOPI = pi*2.


## defaults
NMAX = 10**7
PREFIX = './res/export'
SIZE = 10000
STP = 0.5
NEARL = 4.0
FARL = 200.0
PROCS = 6
STAT_ITT = 1000
EXPORT_ITT = 1000
NINIT = 20
RAD = 0.05


def main():

  from time import time
  from itertools import count
  from numpy import zeros

  from modules.helpers import export
  from modules.helpers import env_or_default

  from modules.helpers import print_stats
  from differentialLine import DifferentialLine


  nmax = env_or_default('NMAX', NMAX)

  procs = env_or_default('PROCS', PROCS)
  prefix = env_or_default('PREFIX', PREFIX)
  size = env_or_default('SIZE', SIZE)
  ninit = env_or_default('NINIT', NINIT)

  one = 1.0/size

  stp = env_or_default('STP', STP)*one
  rad = env_or_default('RAD', RAD)
  nearl = env_or_default('NEARL', NEARL)*one
  farl = env_or_default('FARL', FARL)*one

  orderd_verts = zeros((nmax,2), 'double')

  DF = DifferentialLine(nmax, farl, nearl, farl, procs)

  angles = sorted(random(ninit)*TWOPI)

  DF.init_circle_segment(0.5, 0.5, rad, angles)

  t_start = time()


  for i in count():

    DF.optimize_position(stp)
    spawn_curl(DF,nearl)

    if i % STAT_ITT == 0:

      print_stats(i,time()-t_start,DF)

    if i % EXPORT_ITT == 0:

      fn = '{:s}_{:010d}.xobj'.format(prefix,i)
      num = DF.np_get_sorted_vert_coordinates(orderd_verts)
      meta = '\n# procs {:d}\n# vnum {:d}\n# time {:f}\n# nearl {:f}\n# farl {:f}\n# stp {:f}'.format(
        procs,
        num,
        time()-t_start,
        nearl,
        farl,
        stp
      )
      export(orderd_verts[:num,:], SIZE, fn, meta=meta)


if __name__ == '__main__':

  main()

