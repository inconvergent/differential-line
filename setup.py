#!/usr/bin/python3

try:
  from setuptools import setup
  from setuptools.extension import Extension
except Exception:
  from distutils.core import setup
  from distutils.extension import Extension

from Cython.Build import cythonize
from Cython.Distutils import build_ext
import numpy

_extra = [ '-fopenmp' , '-O3', '-ffast-math']


extensions = [
  Extension('segments',
            sources = ['./src/segments.pyx'],
            extra_compile_args = _extra
  ),
  Extension('differentialLine',
            sources = ['./src/differentialLine.pyx'],
            extra_compile_args = _extra,
            extra_link_args = ['-fopenmp']
  )
]

setup(
  name = "differential-line",
  version = '0.1.0',
  author = '@inconvergent',
  install_requires = ['numpy', 'cython'],
  license = 'MIT',
  cmdclass={'build_ext' : build_ext},
  include_dirs = [numpy.get_include()],
  ext_modules = cythonize(extensions,include_path = [numpy.get_include()])
)
