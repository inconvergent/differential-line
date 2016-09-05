#!/usr/bin/python3
# -*- coding: utf-8 -*-



from numpy import pi
# from numpy import cos
# from numpy import sin
from numpy.random import random
from numpy import zeros
# from numpy import linspace
from numpy import floor

from modules.growth import spawn_curl


NMAX = 10**6
SIZE = 512
ONE = 1./SIZE

PROCS = 2

INIT_NUM = 10

STP = ONE*0.1
NEARL = 4*ONE
FARL = 100*ONE

MID = 0.5

LINEWIDTH = 5.*ONE

BACK = [1,1,1,1]
FRONT = [0,0,0,0.05]

TWOPI = pi*2.

grains = 10
np_coords = zeros(shape=(NMAX,4), dtype='float')
np_vert_coords = zeros(shape=(NMAX,2), dtype='float')


def steps(df):

  from time import time
  from modules.helpers import print_stats

  t1 = time()

  df.optimize_position(STP)
  spawn_curl(df, NEARL)

  if df.safe_vertex_positions(3*STP)<0:

    print('vertices reached the boundary. stopping.')
    return False

  t2 = time()
  print_stats(0, t2-t1, df)

  return True


def main():

  from iutils.render import Animate
  from differentialLine import DifferentialLine

  from fn import Fn

  from modules.show import sandstroke
  from modules.show import dots

  DF = DifferentialLine(NMAX, FARL*2, NEARL, FARL, PROCS)

  ## arc
  # angles = sorted(random(INIT_NUM)*pi*1.5)
  # xys = []
  # for a in angles:
    # x = 0.5 + cos(a)*0.06
    # y = 0.5 + sin(a)*0.06
    # xys.append((x,y))
  # DF.init_line_segment(xys, lock_edges=1)

  ## vertical line
  #xx = sorted(0.45+0.1*random(INIT_NUM))
  #yy = MID+0.005*(0.5-random(INIT_NUM))
  #xys = []
  #for x,y in zip(xx,yy):
    #xys.append((x,y))
  #DF.init_line_segment(xys, lock_edges=1)

  # diagonal line
  # yy = sorted(0.3+0.4*random(INIT_NUM))
  # xx = 0.3+linspace(0,0.4,num=INIT_NUM)
  # xys = []
  # for x,y in zip(xx,yy):
    # xys.append((x,y))
  # DF.init_line_segment(xys, lock_edges=1)


  angles = sorted(random(INIT_NUM)*TWOPI)
  DF.init_circle_segment(MID,MID,FARL*0.2, angles)

  fn = Fn(prefix='./res/', postfix='.png')


  def wrap(render):

    global np_coords
    global np_vert_coords
    global grains

    ## if fn is a path each image will be saved to that path

    if not render.steps%3:
      f = fn.name()
    else:
      f = None

    grains += (-1)**floor(2*random())
    print(grains)
    if grains<0:
      grains = 0

    res = steps(DF)
    render.set_front(FRONT)

    coord_num = DF.np_get_edges_coordinates(np_coords)
    sandstroke(render,np_coords[:coord_num,:],grains,f)

    if not random()<0.1:
      vert_num = DF.np_get_vert_coordinates(np_vert_coords)
      dots(render,np_vert_coords[:vert_num,:],None)

    return res

  render = Animate(SIZE, BACK, FRONT, wrap)
  render.start()


if __name__ == '__main__':

  main()

