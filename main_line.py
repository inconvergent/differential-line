#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi, cos, sin, linspace, zeros
from numpy.random import random, seed
from modules.growth import spawn, spawn_curl

NMAX = 10**7
SIZE = 3000
ONE = 1./SIZE

STP = ONE*0.01
NEARL = 3*ONE
FARL = 800*ONE

PROCS = 4

MID = 0.5

LINEWIDTH = 5.*ONE

STEPS_ITT = 1000
INIT_NUM = 10

BACK = [1,1,1,1]
FRONT = [0,0,0,0.08]

TWOPI = pi*2.

ZONEWIDTH = 2.*FARL/ONE
NZ = int(SIZE/ZONEWIDTH)

print 'NZ', NZ
print 'ZONEWIDTH', ZONEWIDTH


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


  DF = DifferentialLine(NMAX, NZ, NEARL, FARL, PROCS)

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

  ## vertical line

  #yy = sorted(MID + 0.2*(1-2*random(INIT_NUM)))
  #xx = MID+0.005*(0.5-random(INIT_NUM))
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))

  ## diagonal line

  #yy = sorted(0.2+0.6*random(INIT_NUM))
  #xx = sorted(0.2+0.6*random(INIT_NUM))
  #xx = 0.2+linspace(0,0.6,num=INIT_NUM)
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))


  DF.init_line_segment(xys, lock_edges=1)


  for i in count():

    t_start = time()

    DF.optimize_avoid(STP)
    spawn_curl(DF,NEARL)

    if i%100==0:
      fn = './res/line_ee_{:04d}.png'.format(i)
    else:
      fn = None

    render.set_front(FRONT)
    num = DF.np_get_edges_coordinates(np_coords)
    sandstroke(render,np_coords[:num,:],5,fn)

    if i%20==0:
      render.set_front([0,0,0,0.3])
      num = DF.np_get_vert_coordinates(np_vert_coords)
      dots(render,np_vert_coords[:num,:],fn)

    if i%40==0:
      render.set_front([0,0,0,0.8])
      num = DF.np_get_vert_coordinates(np_vert_coords)
      dots(render,np_vert_coords[:num,:],fn)

    t_stop = time()

    print_stats(i,t_stop-t_start,DF)


if __name__ == '__main__':

    main()

