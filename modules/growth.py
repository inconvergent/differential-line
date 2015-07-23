#!/usr/bin/python
# -*- coding: utf-8 -*-

from numpy.random import random

def spawn(df, d, limit):

  enum = df.get_enum()

  rnd = random(enum)
  rndmask = (rnd<limit).nonzero()[0]
  for e in rndmask:

    l = df.get_edge_length(e)
    if l<d:
      continue

    try:
      df.split_edge(e)
    except ValueError:
      pass

def spawn_curl(df, limit):

  enum = df.get_enum()
  ind_curv = {}
  tot_curv = 0
  max_curv = -100000

  for e in xrange(enum):
    try:
      t = df.get_edge_curvature(e)
      ind_curv[e] = t
      tot_curv += t
      max_curv = max(max_curv, t)
    except ValueError:
      pass

  ne = len(ind_curv)
  for r,(e,t) in zip(random(ne),ind_curv.iteritems()):

    if r<t/max_curv:
    #if t>2*limit or r<t/max_curv:
    #if r<sqrt(t):
    #if True:
      try:
        df.split_edge(e, minimum_length=limit)
      except ValueError:
        pass

def spawn_short(df, short, long):

  enum = df.get_enum()

  for e in xrange(enum):
    l = df.get_edge_length(e)
    if l>long:
      try:
        df.split_edge(e, minimum_length=short)
      except ValueError:
        pass

def collapse(df, d, limit):

  enum = df.get_enum()
  rnd = random(enum)
  rndmask = (rnd<limit).nonzero()[0]
  for e in rndmask:

    l = df.get_edge_length(e)
    if l<d:
      try:
        df.collapse_edge(e)
      except ValueError:
        pass

