#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function

def env_or_default(name, d):

  from os import environ

  try:
    a = environ[name]
    if a:
      return type(d)(a)
    else:
      return d
  except Exception:
    return d


def load(fn):

  from codecs import open

  vertices = []

  with open(fn, 'r', encoding='utf8') as f:

    for l in f:
      if l.startswith('#'):
        continue

      values = l.split()
      if not values:
        continue
      if values[0] == 's':
        size = int(values[1])
      if values[0] == 'v':
        vertices.append([float(v) for v in values[1:]])

  return {
    'size': size,
    'vertices': vertices
  }

def get_exporter(nmax):

  from dddUtils.ioOBJ import export_2d as export_obj
  from time import time
  from numpy import zeros

  verts = zeros((nmax, 2),'double')
  edges = zeros((nmax, 2),'int')
  line = zeros(nmax,'int')

  t0 = time()

  def f(dm, data, itt, final=False):

    if final:
      fn = '{:s}_final.2obj'.format(data['prefix'])
    else:
      fn = '{:s}_{:010d}.2obj'.format(data['prefix'],itt)

    vnum = dm.np_get_vert_coordinates(verts)
    enum = dm.np_get_edges(edges)
    linenum = dm.np_get_sorted_verts(line)

    meta = '\n# procs {:d}\n'+\
      '# vnum {:d}\n'+\
      '# enum {:d}\n'+\
      '# time {:f}\n'+\
      '# nearl {:f}\n'+\
      '# farl {:f}\n'+\
      '# stp {:f}\n'+\
      '# size {:d}\n'

    meta = meta.format(
      data['procs'],
      vnum,
      enum,
      time()-t0,
      data['nearl'],
      data['farl'],
      data['stp'],
      data['size']
   )
    export_obj(
      'mesh',
      fn,
      verts = verts[:vnum,:],
      edges = edges[:enum,:],
      lines = [line[:linenum]],
      meta = meta
    )

  return f


def print_stats(steps, t_diff, dl):

  from time import strftime

  print(
    '{:s} | stp: {:d} time: {:.5f} v: {:d} e: {:d}'.format(
      strftime('%d/%m/%Y %H:%M:%S'),
      steps,
      t_diff,
      dl.get_vnum(),
      dl.get_enum()
    )
  )

  return

