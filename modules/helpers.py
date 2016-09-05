#!/usr/bin/python
# -*- coding: utf-8 -*-




def get_exporter(nmax, data):

  from iutils.ioOBJ import export_2d as export
  from time import time
  from numpy import zeros

  verts = zeros((nmax, 2),'double')
  # edges = zeros((nmax, 2),'int')
  line = zeros(nmax,'int')

  t0 = time()

  def f(dm, fn):

    vnum = dm.np_get_vert_coordinates(verts)
    print(vnum)
    # enum = dm.np_get_edges(edges)
    linenum = dm.np_get_sorted_verts(line)
    print(linenum)

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
      0,
      time()-t0,
      data['nearl'],
      data['farl'],
      data['stp'],
      data['size']
   )
    export(
      'line',
      fn,
      verts = verts[:vnum,:],
      # edges = edges[:enum,:],
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

