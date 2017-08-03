@[if DEVELSPACE]@
# location of scripts in develspace
  set(GENJAVA_MESSAGE_ARTIFACTS_BIN_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/scripts")
@[else]@
  set(GENJAVA_MESSAGE_ARTIFACTS_BIN_DIR "${genjava_DIR}/../../../@(CATKIN_PACKAGE_BIN_DESTINATION)")
@[end if]@

set(GENJAVA_MESSAGE_ARTIFACTS_BIN ${GENJAVA_MESSAGE_ARTIFACTS_BIN_DIR}/genjava_message_artifacts)
set(genjava_INSTALL_DIR "maven/org/ros/rosjava_messages")

include(CMakeParseArguments)

# Api for a a catkin metapackage rolls rosjava messages for
# its dependencies. Accepts a list of package names attached
# to the PACKAGES arg (similar to the genmsg
# 'generate_messages' api.
#
#   generate_rosjava_messages(
#     PACKAGES
#         std_msgs
#         geometry_msgs
#   )
macro(generate_rosjava_messages)
  if( ${ARGC} EQUAL 0 )
    return() # Nothing to do (no packages specified)
  else()
    cmake_parse_arguments(ARG "" "" "PACKAGES" ${ARGN})
  endif()
  if(ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "generate_rosjava_messages() called with unused arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  catkin_rosjava_env_setup()
  set(ROS_GRADLE_VERBOSE $ENV{ROS_GRADLE_VERBOSE})
  if(ROS_GRADLE_VERBOSE)
      set(verbosity "--verbosity")
  else()
      set(verbosity "")
  endif()
  string(REPLACE ";" " " package_list "${ARG_PACKAGES}")

  add_custom_target(${PROJECT_NAME}_generate_artifacts
    ALL
    COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENJAVA_MESSAGE_ARTIFACTS_BIN}
        ${verbosity}
        --avoid-rebuilding
        -o ${CMAKE_CURRENT_BINARY_DIR}
        -p ${ARG_PACKAGES} # this has to be a list argument so it separates each arg (not a single string!)
    DEPENDS
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Compiling rosjava message artifacts for [${package_list}]"
  )
  set(build_dir_to_be_cleaned_list)
  foreach(pkg ${ARG_PACKAGES})
    list(APPEND build_dir_to_be_cleaned_list "${CMAKE_CURRENT_BINARY_DIR}/${pkg}")
  endforeach()
  set_directory_properties(PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${build_dir_to_be_cleaned_list}")
endmacro()
