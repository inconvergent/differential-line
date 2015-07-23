
PYX = $(shell find ./src -iname "*.pyx"| sort)

.PHONY: pyx clean

all: clean pyx

pyx:
	python setup.py build_ext --inplace
	cython -a $(PYX)

clean:
	rm -f src/*.html src/*.c
	rm -f modules/*.pyc
	rm -f *.so
	rm -f *.pyc
	rm -rf build

