#!/usr/bin/python
# -*- coding: utf-8 -*-

import time


def print_stats(steps,t_diff,dl):

  print
  print time.strftime('%d/%m/%Y %H:%M:%S'),
  print '| steps:',steps,
  print 'time:', '{:.5f}'.format(t_diff),
  print 'vnum:', dl.get_vnum(),
  print 'enum:', dl.get_enum()

def print_debug(dl):

  print
  print 'edges',dl.get_edges()
  print 'edges vertices',dl.get_edges_vertices()
  print

