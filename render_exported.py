#!/usr/bin/python
# -*- coding: utf-8 -*-

BACK = [1,1,1,1]
FRONT = [0,0,0,1]


def main(args):

  from render.render import Render
  from modules.helpers import load

  #from modules.show import show
  from modules.show import show_closed

  data = load(args.fn)

  size = data['size']
  one = 1.0/size
  vertices = data['vertices']

  render = Render(size, BACK, FRONT)

  render.ctx.set_source_rgba(*FRONT)
  render.ctx.set_line_width(args.width*one)

  out = ''.join(args.fn.split('.')[:-1])+'.png'

  show_closed(render, vertices, out, fill=args.closed)
  #for vv in vertices:
    #render.circle(vv[0], vv[1], one, fill=True)

  render.write_to_png(out)


  return

if __name__ == '__main__':

  import argparse

  parser = argparse.ArgumentParser()
  parser.add_argument(
    '--fn',
    type=str,
    required=True
  )
  parser.add_argument(
    '--closed',
    type=bool,
    default=False
  )
  parser.add_argument(
    '--width',
    type=float,
    default=1.0
  )

  args = parser.parse_args()

  main(args)

