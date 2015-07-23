#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi, zeros, linspace, cos, sin
from numpy.random import random, seed

NMAX = 10**7
SIZE = 500
ONE = 1./SIZE

PROCS = 4

INIT_NUM = 200

STP = ONE*0.01
NEARL = 3*ONE
FARL = 150*ONE
FREEZE_DISTANCE = ONE*5

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,0.5]
RED = [1,0,0,0.3]

TWOPI = pi*2.

ZONEWIDTH = 2.*FARL/ONE
NZ = int(SIZE/ZONEWIDTH)

print 'NZ', NZ
print 'ZONEWIDTH', ZONEWIDTH

i = 0 
np_coords = zeros(shape=(NMAX,4), dtype='float')


def main():

  import gtk
  from time import time

  from render.render import Animate
  from modules.helpers import print_stats
  from differentialLine import DifferentialLine

  from math import ceil

  from modules.show import show_closed
  from modules.show import show_detail
  from modules.show import show
  from modules.show import sandstroke 

  from modules.growth import collapse

  DF = DifferentialLine(NMAX, NZ, NEARL, FARL, PROCS)

  #angles = sorted(random(INIT_NUM)*TWOPI)
  #DF.init_passive_circle_segment(MID,MID,0.1, angles)

  angles = sorted(random(INIT_NUM)*pi*5/8)
  xys = []
  for a in angles:
    x = 0.5 + cos(a)*0.05
    y = 0.5 + sin(a)*0.1
    xys.append((x,y))

  DF.init_passive_line_segment(xys)

  # TODO:
  #   add better proximity func


  def steps(df):

    global i

    active_num = df.get_active_vertex_count()
    print(active_num)

    if active_num<3:
      rad = df.get_greatest_distance(MID,MID) + FREEZE_DISTANCE*3
      circ = rad*4*3.14 
      nodes = ceil(circ/NEARL)
      print(rad, nodes)
      angles = sorted(random(nodes)*TWOPI)
      df.init_circle_segment(MID,MID, rad, angles)

    collapse(df, NEARL, 0.1)
    df.split_long_edges(NEARL*2.5)
    df.optimize_contract(STP, FREEZE_DISTANCE)


  def wrap(steps_itt, render):

    global i
    global np_coords

    t1 = time()

    steps(DF)#

    if i%3 == 0:
      fn = './res/ani{:04d}.png'.format(i)
    else:
      fn = None

    num = DF.np_get_edges_coordinates(np_coords)
    show(render,np_coords[:num,:],fn,ONE)
    #sandstroke(render,np_coords[:num,:],8,None)

    t2 = time()
    print_stats(render.steps, t2-t1, DF)

    i += 1

    return True

  render = Animate(SIZE, BACK, FRONT, None, wrap)
  render.ctx.set_source_rgba(*FRONT)
  render.ctx.set_line_width(LINEWIDTH)

  gtk.main()


if __name__ == '__main__':

  main()

