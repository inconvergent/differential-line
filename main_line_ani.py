#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy import pi, cos, sin
from numpy.random import random, seed
from numpy import zeros, linspace

from modules.growth import spawn, spawn_curl

NMAX = 10**7
SIZE = 1000
ONE = 1./SIZE

PROCS = 2

INIT_NUM = 6

STP = ONE*0.1
NEARL = 4*ONE
FARL = 120*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,0.1]

TWOPI = pi*2.

ZONEWIDTH = 2.*FARL/ONE
NZ = int(SIZE/ZONEWIDTH)

print 'NZ', NZ
print 'ZONEWIDTH', ZONEWIDTH

i = 0 
np_coords = zeros(shape=(NMAX,4), dtype='float')
np_vert_coords = zeros(shape=(NMAX,2), dtype='float')


def main():

  import gtk
  from time import time

  from render.render import Animate
  from modules.helpers import print_stats
  from differentialLine import DifferentialLine

  from modules.show import sandstroke
  from modules.show import dots
  from modules.show import show

  DF = DifferentialLine(NMAX, NZ, NEARL, FARL, PROCS)


  ## arc

  #angles = sorted(random(INIT_NUM)*pi*1.5)
  #xys = []
  #for a in angles:
    #x = 0.5 + cos(a)*0.06
    #y = 0.5 + sin(a)*0.06
    #xys.append((x,y))

  ## vertical line

  #xx = sorted(0.45+0.1*random(INIT_NUM))
  #yy = MID+0.005*(0.5-random(INIT_NUM))
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))

  ## diagonal line

  #yy = sorted(0.2+0.6*random(INIT_NUM))
  #xx = 0.2+linspace(0,0.6,num=INIT_NUM)
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))


  #DF.init_line_segment(xys, lock_edges=1)

  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,FARL*0.2, angles)


  def steps(df):

    global i

    df.optimize_avoid(STP)
    spawn_curl(df, NEARL)


  def wrap(steps_itt, render):

    global i
    global np_coords
    global np_vert_coords

    fn = None

    t1 = time()

    steps(DF)

    #coord_num = DF.np_get_edges_coordinates(np_coords)
    ##fn = './res/ani{:04d}.png'.format(i)
    #sandstroke(render,np_coords[:coord_num,:],10,fn)


    #if i%2==0:
      #fn = './res/ani{:04d}.png'.format(i)
    #else:
      #fn=None

    render.set_front(FRONT)
    vert_num = DF.np_get_vert_coordinates(np_vert_coords)
    dots(render,np_vert_coords[:vert_num,:],fn)

    #render.set_front([0,0.8,0.8,0.05])
    #coord_num = DF.np_get_edges_coordinates(np_coords)
    #sandstroke(render,np_coords[:coord_num,:],8,None)

    #coord_num = DF.np_get_edges_coordinates(np_coords)
    #show(render,np_coords[:coord_num,:],clear=True)

    if i%10==0:
      coord_num = DF.np_get_edges_coordinates(np_coords)
      sandstroke(render,np_coords[:coord_num,:],8,None)

    t2 = time()
    print_stats(render.steps, t2-t1, DF)

    i += 1

    return True

  render = Animate(SIZE, BACK, FRONT, None, wrap)
  gtk.main()


if __name__ == '__main__':

  main()

