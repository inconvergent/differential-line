#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi, cos, sin, linspace, zeros
from numpy.random import random, seed
from modules.growth import spawn, spawn_curl

NMAX = 10**7
SIZE = 10000
ONE = 1./SIZE

STP = ONE*0.02
NEARL = 2*ONE
FARL = 0.235

PROCS = 4

MID = 0.5

LINEWIDTH = 5.*ONE

INIT_NUM = 6

BACK = [1,1,1,1]
FRONT = [0,0,0,0.04]

TWOPI = pi*2.


def main():

  from time import time
  from itertools import count

  from differentialLine import DifferentialLine

  from render.render import Render
  from modules.helpers import print_stats

  from modules.show import sandstroke
  from modules.show import show
  from modules.show import dots


  np_coords = zeros(shape=(NMAX,4), dtype='float')
  np_vert_coords = zeros(shape=(NMAX,2), dtype='float')


  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

  render = Render(SIZE, BACK, FRONT)

  render.ctx.set_source_rgba(*FRONT)
  render.ctx.set_line_width(LINEWIDTH)

  ## arc

  angles = sorted(random(INIT_NUM)*pi*1.5)
  xys = []
  for a in angles:
    x = 0.5 + cos(a)*0.2
    y = 0.5 + sin(a)*0.2
    xys.append((x,y))

  DF.init_line_segment(xys, lock_edges=1)

  ## vertical line

  #yy = sorted(MID + 0.2*(1-2*random(INIT_NUM)))
  #xx = MID+0.005*(0.5-random(INIT_NUM))
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))

  #DF.init_line_segment(xys, lock_edges=1)

  ## diagonal line

  #yy = sorted(MID + 0.2*(1-2*random(INIT_NUM)))
  #xx = sorted(MID + 0.2*(1-2*random(INIT_NUM)))
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))

  #DF.init_line_segment(xys, lock_edges=1)

  #angles = sorted(random(INIT_NUM)*TWOPI)
  #DF.init_circle_segment(MID,MID,FARL*0.2, angles)


  for i in count():

    t_start = time()

    DF.optimize_avoid(STP)
    spawn_curl(DF,NEARL, 0.016)

    if i%100==0:
      fn = './res/kine_arc_ad_{:04d}.png'.format(i)
    else:
      fn = None

    render.set_front(FRONT)
    num = DF.np_get_edges_coordinates(np_coords)
    sandstroke(render,np_coords[:num,:],20,fn)


    if random()<0.05:
      sandstroke(render,np_coords[:num,:],30,None)

    vert_num = DF.np_get_vert_coordinates(np_vert_coords)
    dots(render,np_vert_coords[:vert_num,:],None)


    t_stop = time()

    print_stats(i,t_stop-t_start,DF)


if __name__ == '__main__':

    main()

