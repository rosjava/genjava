##############################################################################
# CMake
##############################################################################

cmake_minimum_required(VERSION 2.8.3)
project(genjava)

##############################################################################
# Dependencies
##############################################################################

find_package(catkin REQUIRED COMPONENTS genmsg)

##############################################################################
# Package
##############################################################################

catkin_package(
  CATKIN_DEPENDS genmsg
  CFG_EXTRAS genjava-extras.cmake
)

add_subdirectory(scripts)

message(STATUS "GENMSG_LANGS_DESTINATION...........${GENMSG_LANGS_DESTINATION}")
file(WRITE ${CATKIN_DEVEL_PREFIX}/${GENMSG_LANGS_DESTINATION}/genjava "Java")
install(FILES ${CATKIN_DEVEL_PREFIX}/${GENMSG_LANGS_DESTINATION}/genjava
  DESTINATION ${GENMSG_LANGS_DESTINATION})

catkin_python_setup()

if(CATKIN_ENABLE_TESTING)
  catkin_add_nosetests(test)
endif()

