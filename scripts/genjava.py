#!/usr/bin/env python

"""
ROS message source code generation for Java

Converts ROS .msg files in a package into Java source code implementations.
"""
import os
import sys

#import genjava.generator
import genjava.genjava_main

if __name__ == "__main__":
    genjava.genjava_main.genmain(sys.argv, 'genmsg_java.py') #, genpy.generator.MsgGenerator())

