# Software License Agreement (BSD License)
#
# Copyright (c) 2014, Daniel Stonier.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
#  * Neither the name of Willow Garage, Inc. nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

##############################################################################
# Imports
##############################################################################

from __future__ import print_function
import argparse
#import os
#import sys
#import traceback
#import genmsg
#import genmsg.command_line

#from genmsg import MsgGenerationException
#from . generate_initpy import write_modules
from . import gradle_project

##############################################################################
# Methods
##############################################################################


def parse_arguments(argv):
    '''
      The include path has a special format, e.g.
         -Ifoo_msgs:/mnt/zaphod/ros/rosjava/hydro/src/foo_msgs/msg;-Istd_msgs:/opt/ros/hydro/share/std_msgs/cmake/../msg
    '''
    parser = argparse.ArgumentParser(description='Generate java code for a single ros message.')
    #parser.add_argument('-m', '--message', action='store', help='the message file')
    parser.add_argument('-p', '--package', action='store', help='package to find the message file')
    parser.add_argument('-o', '--output-dir', action='store', help='output directory for the java code (e.g. build/foo_msgs)')
    #parser.add_argument('-I', '--include-path', action='append', help="include paths to the package and deps msg files")
    #myargs = rospy.myargv(argv=sys.argv)
    #return parser.parse_args(args=myargs[1:])
    return parser.parse_args(argv)

##############################################################################
# Main
##############################################################################


def main(argv):
    args = parse_arguments(argv[1:])
    #print("genjava %s/%s" % (args.package, args.message))
    gradle_project.create(args.package, args.output_dir)
