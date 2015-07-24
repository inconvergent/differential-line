#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi
from numpy.random import random, seed
from modules.growth import spawn, spawn_curl

NMAX = 10**7
SIZE = 500
ONE = 1./SIZE

PROCS = 2

INIT_RAD = 25*ONE
INIT_NUM = 40


STP = ONE*0.2
NEARL = 5*ONE
FARL = 2.5*30*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,1]
RED = [1,0,0,0.3]

TWOPI = pi*2.

ZONEWIDTH = 2.*FARL/ONE
NZ = int(SIZE/ZONEWIDTH)

print 'NZ', NZ
print 'ZONEWIDTH', ZONEWIDTH

i = 0 


def main():

  import gtk
  from time import time

  from render.render import Animate
  from modules.helpers import print_stats
  from differentialLine import DifferentialLine

  from modules.show import show_closed
  from modules.show import show_detail
  from modules.show import show

  DF = DifferentialLine(NMAX, NZ, NEARL, FARL, PROCS)

  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,INIT_RAD, angles)


  def steps(df):

    global i

    df.optimize_avoid(STP)
    spawn_curl(df, NEARL)


  def wrap(steps_itt, render):

    global i

    t1 = time()

    steps(DF)
    fn = None

    #edges_coordinates = DF.get_edges_coordinates()
    #sorted_vert_coordinates = DF.get_sorted_vert_coordinates()
    #fn = './res/ani{:04d}.png'.format(i)
    #show_detail(render,edges_coordinates,sorted_vert_coordinates,fn)

    edges_coordinates = DF.get_edges_coordinates()
    fn = './res/ani{:04d}.png'.format(i)
    show(render,edges_coordinates,fn)

    #sorted_vert_coordinates = DF.get_sorted_vert_coordinates()
    #fn = './res/ani{:04d}.png'.format(i)
    #show_closed(render,sorted_vert_coordinates,fn)

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

