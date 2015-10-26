#!/usr/bin/python
# -*- coding: utf-8 -*-

CONTRASTA = [0.84,0.37,0,1] # orange
CONTRASTB = [0.53,0.53,1,1] # lightblue
CONTRASTC = [0.84,1,0,1]
CONTRASTA = [0,0.7,0.8,1]
CONTRASTB = [1,1,1,0.5]


def show_detail(render,edges_coordinates,fn=None):

  render.clear_canvas()
  render_circle = render.circle

  small = render.pix*3.
  large = render.pix*10.

  render.set_line_width(render.pix)

  for vv in edges_coordinates:

    render.set_front([1,0,0,0.4])
    render_circle(vv[0], vv[1], r=large, fill=False)
    render_circle(vv[2], vv[3], r=large, fill=False)

    render.set_front([0,0,0,0.8])
    render_circle(vv[0], vv[1], r=small, fill=True)
    render_circle(vv[2], vv[3], r=small, fill=True)


  if fn:
    render.write_to_png(fn)

def show(render,edges_coordinates,fn=None,r=None,clear=True):

  if not r:
    r = 2.5*render.pix

  if clear:
    render.clear_canvas()

  render_circles = render.circles

  for vv in edges_coordinates:
    render_circles(*vv,r=r,nmin=2)

  if fn:
    render.write_to_png(fn)

def sandstroke(render,xys,grains=5,fn=None):

  render_sandstroke = render.sandstroke

  render_sandstroke(xys, grains=grains)

  if fn:
    render.write_to_png(fn)

def dots(render,xys,fn=None):

  render_dot = render.dot

  for vv in xys:
    render_dot(*vv)

  if fn:
    render.write_to_png(fn)

def show_closed(render,coords,fn=None, fill=True):

  render.clear_canvas()
  render.closed_path(coords)

  if fn:
    render.write_to_png(fn)

