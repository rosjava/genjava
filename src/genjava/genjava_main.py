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
import os
#import sys
#import traceback
#import genmsg
#import genmsg.command_line

import rosjava_build_tools
import catkin_pkg.packages
from . import gradle_project

##############################################################################
# Methods
##############################################################################


def parse_arguments(argv):
    parser = argparse.ArgumentParser(description='Generate java code for a single ros message.')
    #parser.add_argument('-m', '--message', action='store', help='the message file')
    parser.add_argument('-p', '--package', action='store', help='package to find the message file')
    parser.add_argument('-o', '--output-dir', action='store', help='output directory for the java code (e.g. build/foo_msgs)')
    parser.add_argument('-c', '--compile', default=False, action='store_true', help='switch to compile mode (default is generating mode)')
    parser.add_argument('-v', '--verbosity', default=False, action='store_true', help='enable verbosity in debugging (false)')
    #  The include path has a special format, e.g.
    #     -Ifoo_msgs:/mnt/zaphod/ros/rosjava/hydro/src/foo_msgs/msg;-Istd_msgs:/opt/ros/hydro/share/std_msgs/cmake/../msg
    #parser.add_argument('-I', '--include-path', action='append', help="include paths to the package and deps msg files")
    #myargs = rospy.myargv(argv=sys.argv)
    #return parser.parse_args(args=myargs[1:])
    return parser.parse_args(argv)

##############################################################################
# Main
##############################################################################


def main(argv):
    '''
    Used as the builder for genjava on the fly as other message language interfaces
    are built. There is a bit of smarts inside this to work out when msgs have
    changed and so forth.
    '''
    args = parse_arguments(argv[1:])
    #print("genjava %s/%s" % (args.package, args.message))
    if not args.compile:
        gradle_project.create(args.package, args.output_dir)
    else:
        gradle_project.build(args.package, args.output_dir, args.verbosity)


def standalone_parse_arguments(argv):
    parser = argparse.ArgumentParser(description='Generate artifacts for any/all discoverable message packages.')
    parser.add_argument('-p', '--packages', action='store', nargs='*', default=[], help='a list of packages to generate artifacts for')
    parser.add_argument('-o', '--output-dir', action='store', default='build', help='output directory for the java code (e.g. build/foo_msgs)')
    parser.add_argument('-v', '--verbose', default=False, action='store_true', help='enable verbosity in debugging (false)')
    parser.add_argument('-f', '--fakeit', default=False, action='store_true', help='dont build, just list the packages it would build (false)')
    parser.add_argument('-a', '--avoid-rebuilding', default=False, action='store_true', help='avoid rebuilding if the working directory is already present (false)')
    parsed_arguments = parser.parse_args(argv)
    return parsed_arguments


def standalone_main(argv):
    '''
    This guy is a brute force standalone message artifact generator. It parses
    the environment looking for the package (or just all) you wish to
    generate artifacts for.
    '''
    args = standalone_parse_arguments(argv[1:])
    #print("genjava %s/%s/%s" % (args.package, args.output_dir, args.verbose))

    sorted_package_tuples = rosjava_build_tools.catkin.index_message_package_dependencies_from_local_environment(package_name_list=args.packages)

    print("")
    print("Generating message artifacts for: \n%s" % [p.name for (unused_relative_path, p) in sorted_package_tuples])
    did_not_rebuild_these_packages = []
    if not args.fakeit:
        for unused_relative_path, p in sorted_package_tuples:
            result = gradle_project.standalone_create_and_build(p.name, args.output_dir, args.verbose, args.avoid_rebuilding)
            if not result:
                did_not_rebuild_these_packages.append(p.name)
    if did_not_rebuild_these_packages:
        print("")
        print("Skipped re-generation of these message artifacts (clean first): %s" % did_not_rebuild_these_packages)
        print("")
