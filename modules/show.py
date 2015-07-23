#!/usr/bin/python
# -*- coding: utf-8 -*-

CONTRASTA = [0.84,0.37,0,1] # orange
CONTRASTB = [0.53,0.53,1,1] # lightblue
CONTRASTC = [0.84,1,0,1]
CONTRASTA = [0,0.7,0.8,1]
CONTRASTB = [1,1,1,0.5]


def show_detail(render,edges_coordinates,coords,fn=None):

  render.clear_canvas()
  render_circles = render.circles
  render_circle_path = render.circle_path

  render.ctx.set_line_width(render.pix)
  render_circle_path(coords,render.pix*3,fill=True)

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

def show_closed(render,coords,fn=None):

  render.clear_canvas()
  render.closed_path(coords)

  if fn:
    render.write_to_png(fn)

