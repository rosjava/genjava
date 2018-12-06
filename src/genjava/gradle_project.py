#!/usr/bin/env python

##############################################################################
# Imports
##############################################################################

from __future__ import print_function

import os
import shutil
import subprocess
from catkin_pkg.packages import find_packages
import rospkg
import rosjava_build_tools.catkin

##############################################################################
# Utils
##############################################################################

import pwd


def author_name():
    """
    Utility to compute logged in user name

    :returns: name of current user, ``str``
    """
    import getpass
    name = getpass.getuser()
    try:
        login = name
        name = pwd.getpwnam(login)[4]
        name = ''.join(name.split(','))  # strip commas
        # in case pwnam is not set
        if not name:
            name = login
    except:
        #pwd failed
        pass
    #if type(name) == str:
    #    name = name.decode('utf-8')
    return name


import tarfile


def create_gradle_wrapper(repo_path):
    archive_file = os.path.join(os.path.dirname(__file__), 'gradle', 'gradle.tar.gz')
    archive = tarfile.open(archive_file)
    archive.extractall(path=repo_path)
    archive.close()


def read_template(tmplf):
    f = open(tmplf, 'r')
    try:
        t = f.read()
    finally:
        f.close()
    return t

##############################################################################
# Methods acting on classes
##############################################################################


def instantiate_genjava_template(template, project_name, project_version, pkg_directory, author, msg_dependencies):
    return template % locals()


def get_templates():
    template_dir = os.path.join(os.path.dirname(__file__), 'templates', 'genjava_project')
    templates = {}
    templates['build.gradle'] = read_template(os.path.join(template_dir, 'build.gradle.in'))
    return templates


def populate_project(project_name, project_version, pkg_directory, gradle_project_dir, msg_dependencies):
    author = author_name()
    for filename, template in get_templates().iteritems():
        contents = instantiate_genjava_template(template, project_name, project_version, pkg_directory, author, msg_dependencies)
        try:
            p = os.path.abspath(os.path.join(gradle_project_dir, filename))
            f = open(p, 'w')
            f.write(contents)
            #console.pretty_print("Created file: ", console.cyan)
            #console.pretty_println("%s" % p, console.yellow)
        finally:
            f.close()


def create_dependency_string(project_name, msg_package_index):
    package = msg_package_index[project_name]
    gradle_dependency_string = ""
    for dep in package.build_depends:
        try:
            dependency_package = msg_package_index[dep.name]
        except KeyError:
            continue  # it's not a message package
        gradle_dependency_string += "  compile 'org.ros.rosjava_messages:" + dependency_package.name + ":" + dependency_package.version + "'\n"
    return gradle_dependency_string


def create_msg_package_index():
    """
      Scans the package paths and creates a package index always taking the
      highest in the workspace chain (i.e. takes an overlay in preference when
      there are multiple instances of the package).

      :returns: the package index
      :rtype: { name : catkin_pkg.Package }
    """
    # should use this, but it doesn't sequence them properly, so we'd have to make careful version checks
    # this is inconvenient since it would always mean we should bump the version number in an overlay
    # when all that is necessary is for it to recognise that it is in an overlay
    # ros_paths = rospkg.get_ros_paths()
    package_index = {}
    ros_paths = rospkg.get_ros_package_path()
    ros_paths = [x for x in ros_paths.split(':') if x]
    # packages that don't properly identify themselves as message packages (fix upstream).
    for path in reversed(ros_paths):  # make sure we pick up the source overlays last
        for unused_package_path, package in find_packages(path).items():
            if ('message_generation' in [dep.name for dep in package.build_depends] or
                'genmsg' in [dep.name for dep in package.build_depends] or
                package.name in rosjava_build_tools.catkin.message_package_whitelist):
#                 print(package.name)
#                 print("  version: %s" % package.version)
#                 print("  dependencies: ")
#                 for dep in package.build_depends:
#                     if not (dep.name == 'message_generation'):
#                         print("         : %s" % dep)
                package_index[package.name] = package
    return package_index


def create(msg_pkg_name, output_dir):
    '''
    Creates a standalone single project gradle build instance in the specified output directory and
    populates it with gradle wrapper and build.gradle file that will enable building of the artifact later.
    :param str project_name:
    :param dict msg_package_index:  { name : catkin_pkg.Package }
    :param str output_dir:
    '''
    genjava_gradle_dir = os.path.join(output_dir, msg_pkg_name)
    if os.path.exists(genjava_gradle_dir):
        shutil.rmtree(genjava_gradle_dir)
    os.makedirs(genjava_gradle_dir)
    msg_package_index = create_msg_package_index()
    if msg_pkg_name not in msg_package_index.keys():
        raise IOError("could not find %s among message packages. Does the package have a <build_depend> on message_generation in its package.xml?" % msg_pkg_name)

    msg_dependencies = create_dependency_string(msg_pkg_name, msg_package_index)

    create_gradle_wrapper(genjava_gradle_dir)
    pkg_directory = os.path.abspath(os.path.dirname(msg_package_index[msg_pkg_name].filename))
    msg_pkg_version = msg_package_index[msg_pkg_name].version
    populate_project(msg_pkg_name, msg_pkg_version, pkg_directory, genjava_gradle_dir, msg_dependencies)


def build(msg_pkg_name, output_dir, verbosity):
    # Are there droppings? If yes, then this genjava has marked this package as
    # needing a compile (it's new, or some msg file changed).
    droppings_file = os.path.join(output_dir, msg_pkg_name, 'droppings')
    if not os.path.isfile(droppings_file):
        #print("Nobody left any droppings - nothing to do! %s" % droppings_file)
        return
    #print("Scooping the droppings! [%s]" % droppings_file)
    os.remove(droppings_file)
    cmd = ['./gradlew']
    if not verbosity:
        cmd.append('--quiet')
    #print("COMMAND........................%s" % cmd)
    subprocess.call(cmd, stderr=subprocess.STDOUT,)


def standalone_create_and_build(msg_pkg_name, output_dir, verbosity, avoid_rebuilding=False):
    '''
    Brute force create and build the message artifact disregarding any smarts
    such as whether message files changed or not. For use with the standalone
    package builder.
    :param str msg_pkg_name:
    :param str output_dir:
    :param bool verbosity:
    :param bool avoid_rebuilding: don't rebuild if working dir is already there
    :return bool : whether it built, or skipped because it was avoiding a rebuild
    '''
    genjava_gradle_dir = os.path.join(output_dir, msg_pkg_name)
    if os.path.exists(genjava_gradle_dir) and avoid_rebuilding:
        return False
    create(msg_pkg_name, output_dir)
    working_directory = os.path.join(os.path.abspath(output_dir), msg_pkg_name)
    gradle_wrapper = os.path.join(os.path.abspath(output_dir), msg_pkg_name, 'gradlew')
    cmd = [gradle_wrapper, '-p', working_directory]
    if not verbosity:
        cmd.append('--quiet')
    #print("COMMAND........................%s" % cmd)
    subprocess.call(cmd, stderr=subprocess.STDOUT,)
    return True
