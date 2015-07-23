#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi, zeros, linspace, cos, sin
from numpy.random import random, seed
from modules.growth import spawn, spawn_curl

NMAX = 10**7
SIZE = 2000
ONE = 1./SIZE

STP = ONE*0.01
NEARL = 3*ONE
FARL = 150*ONE
FREEZE_DISTANCE = ONE*5

PROCS = 4

MID = 0.5

LINEWIDTH = 5.*ONE

STEPS_ITT = 1000
INIT_NUM = 200

BACK = [1,1,1,1]
FRONT = [0,0,0,1]

TWOPI = pi*2.

ZONEWIDTH = 2.*FARL/ONE
NZ = int(SIZE/ZONEWIDTH)

print 'NZ', NZ
print 'ZONEWIDTH', ZONEWIDTH

np_coords = zeros(shape=(NMAX,4), dtype='float')

def steps(df,steps_itt):

  from math import ceil
  from modules.growth import collapse

  for i in xrange(steps_itt):

    active_num = df.get_active_vertex_count()
    print(active_num)

    if active_num<1:
      rad = df.get_greatest_distance(MID,MID) + FREEZE_DISTANCE*3
      circ = rad*4*3.14 
      nodes = ceil(circ/NEARL)
      print(rad, nodes)
      angles = sorted(random(nodes)*TWOPI)
      df.init_circle_segment(MID,MID, rad, angles)

    collapse(df, NEARL*0.9, 0.1)
    df.split_long_edges(NEARL*3)
    df.optimize_contract(STP, FREEZE_DISTANCE)


def main():

  from time import time
  from itertools import count

  from render.render import Render
  from modules.helpers import print_stats
  from modules.show import show

  from differentialLine import DifferentialLine


  DF = DifferentialLine(NMAX, NZ, NEARL, FARL, PROCS)

  render = Render(SIZE, BACK, FRONT)

  render.ctx.set_source_rgba(*FRONT)
  render.ctx.set_line_width(LINEWIDTH)

  #angles = sorted(random(INIT_NUM)*TWOPI)
  #DF.init_passive_circle_segment(MID,MID,100*ONE, angles)

  angles = sorted(random(INIT_NUM)*pi*5/8)
  xys = []
  for a in angles:
    x = 0.5 + cos(a)*0.01
    y = 0.5 + sin(a)*0.01
    xys.append((x,y))

  DF.init_passive_line_segment(xys)


  for i in count():

    t_start = time()

    steps(DF,STEPS_ITT)

    t_stop = time()

    print_stats(i*STEPS_ITT,t_stop-t_start,DF)

    fn = './res/collapse_e_{:010d}.png'.format(i*STEPS_ITT)
    num = DF.np_get_edges_coordinates(np_coords)
    show(render,np_coords[:num,:],fn,ONE)


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

