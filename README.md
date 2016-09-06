Differential Line
=============

![ani](/img/ani2.gif?raw=true "animation")

This algorithm is inspired by the way a number of biological things in nature
grows. Among other things it is made to mimic the growth of the human brain, as
well as a great number of plants.

![ani](/img/ani.gif?raw=true "animation")

![img](/img/img.jpg?raw=true "image")

In brief; we start of with a number of connected nodes in a circle. Gradually
we introduce new nodes on the line—prioritizing segments where the curve bends
more sharply.  Over time the curve grows increasingly intricate, but it never
self-intersects.

![img](/img/img1.jpg?raw=true "image")

![img](/img/img2.jpg?raw=true "image")

If we start with a different shape, and draw the outside position of the object
for each growth step, we can get an entirely different kind of system with an
interesting 3D illusion.

![img](/img/img3.jpg?raw=true "image")

## Prerequisites

In order for this code to run you must first download and install these two
repositories:

*    `iutils`: http://github.com/inconvergent/iutils
*    `zonemap`: https://github.com/inconvergent/zonemap
*    `fn`: https://github.com/inconvergent/fn-python3 (used to generate
     filenames, you can remove this dependency in the main files)

## Other Dependencies

The code also depends on:

*    `gi` (replaces pyGTK)
*    `numpy`
*    `cython`
*    `python-cairo` (do not install with pip, this generally does not work)

## Running it on Linux (Ubuntu)

To install the libraries locally, run `./install`. I have only tested this code
in Ubuntu 14.04 LTS, but my guess is that it should work on most other
platforms platforms as well.  However i know that the scripted install in
`./install` will not work in Windows

## Running it on Windows?

The code will probably work just fine under Windows, but I'm not sure how to
install it. (Let me know if you get it working!)

## Why all the main files?

If you just want to try this out you should have a look at `main_ani.py`. It is
pretty safe to ignore all the others main files. (They implement different
behaviour, and some of them are very experimental.)

## Similar code

If you find this alorithm insteresting you might also want to check out:
https://github.com/inconvergent/differential-mesh.

Recently I also implemented a version of this algorithm using CUDA:

https://github.com/inconvergent/differential-line-cuda

