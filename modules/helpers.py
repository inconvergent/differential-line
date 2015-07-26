#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function

import time


def print_stats(steps,t_diff,dl):

  s = '{:s} | steps: {:d} time: {:.5f} vnum: {:d} enum: {:d}'.format(
    time.strftime('%d/%m/%Y %H:%M:%S'),
    steps,
    t_diff,
    dl.get_vnum(),
    dl.get_enum()
  )

  print(s)

  return
