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


def export(orderd_verts, fn, meta=None):

  with open(fn, 'wb') as f:
    f.write('# differential line export. beta.\n')
    if meta:
      f.write('{:s}\n'.format(meta))

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

