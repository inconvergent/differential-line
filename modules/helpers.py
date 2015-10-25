#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function

def env_or_default(name, d, t=None):

  from os import environ

  try:
    a = environ[name]
    if a:
      if t:
        return t(a)
      else:
        return a
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


def export(orderd_verts, size, fn, meta=None):

  from codecs import open

  with open(fn, 'wb', encoding='utf8') as f:
    f.write('# differential line export. beta.\n')
    if meta:
      f.write('{:s}\n'.format(meta))

    f.write('s {:d}\n'.format(size))

    for vv in orderd_verts:
      f.write('v {:f} {:f}\n'.format(*vv))

    return


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

