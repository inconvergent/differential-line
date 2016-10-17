#!/usr/bin/python3
# -*- coding: utf-8 -*-

from numpy import pi
from numpy import cos
from numpy import sin
from numpy import linspace
from numpy import zeros
from numpy import ones
from numpy.random import random
from modules.growth import spawn
from modules.growth import spawn_curl

NMAX = 10**7
SIZE = 5000
ONE = 1./SIZE

STP = ONE*0.02
NEARL = 15*ONE
FARL = 0.235

PROCS = 4

MID = 0.5

LINEWIDTH = 5.*ONE

INIT_NUM = 4

BACK = [1,1,1,1]
FRONT = [0,0,0,0.005]
DARK = [0,0,0,0.01]

TWOPI = pi*2.

GRAINS = 50


def main():

  from time import time
  from itertools import count

  from sand import Sand
  from differentialLine import DifferentialLine
  from modules.helpers import print_stats

  from fn import Fn
  fn = Fn(prefix='./res/', postfix='.png')

  sand = Sand(SIZE)
  sand.set_bg(BACK)
  sand.set_rgba(FRONT)

  np_coords = zeros((NMAX,4), 'float')
  np_vert_coords = zeros((NMAX,2), 'float')


  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

  # angles = sorted(random(INIT_NUM)*TWOPI)
  # DF.init_circle_segment(MID,MID,0.2, angles)

  ## arc
  # angles = sorted(random(INIT_NUM)*pi*1.5)
  # xys = []
  # for a in angles:
  #   x = 0.5 + cos(a)*0.2
  #   y = 0.5 + sin(a)*0.2
  #   xys.append((x,y))
  # DF.init_line_segment(xys, lock_edges=1)

  ## vertical line
  # yy = linspace(0.25, 0.75, num=INIT_NUM, endpoint=True)
  # xx = MID+0.005*(0.5-random(INIT_NUM))
  # xys = []
  # for x,y in zip(xx,yy):
  #   xys.append((x,y))
  # DF.init_line_segment(xys, lock_edges=1)

  ## diagonal line
  yy = sorted(MID + 0.2*(1-2*random(INIT_NUM)))
  xx = sorted(MID + 0.2*(1-2*random(INIT_NUM)))
  xys = []
  for x,y in zip(xx,yy):
    xys.append((x,y))
  DF.init_line_segment(xys, lock_edges=1)


  for i in count():

    t_start = time()

    DF.optimize_position(STP)
    spawn_curl(DF,NEARL,0.016)

    num = DF.np_get_edges_coordinates(np_coords)
    sand.paint_strokes(
        np_coords[:num,0:2].astype('double'),
        np_coords[:num,2:].astype('double'),
        GRAINS*ones(num, 'int')
        )

    if random()<0.1:
      sand.paint_strokes(
          np_coords[:num,0:2].astype('double'),
          np_coords[:num,2:].astype('double'),
          2*GRAINS*ones(num, 'int')
          )

    sand.set_rgba(DARK)
    vert_num = DF.np_get_vert_coordinates(np_vert_coords)
    sand.paint_dots(np_vert_coords[:vert_num,:])

    if i%800==0:
      name = fn.name()
      print(name)
      sand.write_to_png(name)
      t_stop = time()
      print_stats(i,t_stop-t_start,DF)




if __name__ == '__main__':

    main()

