##############################################################################
# CMake
##############################################################################

cmake_minimum_required(VERSION 2.8.3)
project(genjava)

##############################################################################
# Find Package
##############################################################################

find_package(catkin REQUIRED COMPONENTS genmsg rosjava_build_tools)

##############################################################################
# Catkin
##############################################################################

catkin_package(
  CATKIN_DEPENDS genmsg rosjava_build_tools
  CFG_EXTRAS
    genjava-extras.cmake
    genjava-catkin-api.cmake
)

catkin_python_setup()

##############################################################################
# Installs
##############################################################################

add_subdirectory(scripts)

file(WRITE ${CATKIN_DEVEL_PREFIX}/${GENMSG_LANGS_DESTINATION}/genjava "Java")
install(FILES ${CATKIN_DEVEL_PREFIX}/${GENMSG_LANGS_DESTINATION}/genjava
  DESTINATION ${GENMSG_LANGS_DESTINATION})

##############################################################################
# Tests
##############################################################################

#if(CATKIN_ENABLE_TESTING)
#  catkin_add_nosetests(test)
#endif()

