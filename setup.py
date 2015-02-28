#!/usr/bin/env python

from distutils.core import setup
from catkin_pkg.python_setup import generate_distutils_setup

d = generate_distutils_setup(
    packages=['genjava'],
    package_dir={'': 'src'},
    requires=['genmsg'],
    scripts=['scripts/genjava_message_artifacts'],
    package_data = {'genjava': [
           'templates/genjava_project/*',
           'gradle/*',
        ]},
)

setup(**d)
