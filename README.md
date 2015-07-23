Differential Line
=============

The Differential [github] algorithm is inspired by the way a number of
biological things in nature grows. Among other things it is made to mimic the
growth of the human brain, as well as a great number of plants. In brief; we
start of with a number of connected nodes in a circle. Gradually we introduce
new nodes on the line—prioritizing segments where the curve bends more sharply.
Over time the curve grows increasingly intricate, but it never self-intersects.

If we start with a different shape, and draw the outside position of the object
for each growth step, we can get an entirely different kind of system with an
interesting 3D illusion.

![img](/img/img.jpg?raw=true "image")

![img](/img/img1.jpg?raw=true "image")

![img](/img/img2.jpg?raw=true "image")

![img](/img/img3.jpg?raw=true "image")

## Requirements

*    `numpy`
*    `cython`
*    `python-cairo` (do not install with pip, this generally does not work)
*    `render` TODO: add link
*    `zonemap` TODO: add link

-----------
http://inconvergent.net

