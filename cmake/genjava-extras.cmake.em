@[if DEVELSPACE]@
# location of scripts in develspace
set(GENJAVA_BIN_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/scripts")
@[else]@
# location of scripts in installspace
set(GENJAVA_BIN_DIR "${GENJAVA_DIR}/../../../@(CATKIN_PACKAGE_BIN_DESTINATION)")
@[end if]@

set(GENJAVA_BIN ${GENJAVA_BIN_DIR}/genjava_gradle_project.py)
#set(GENMSG_JAVA_BIN ${GENJAVA_BIN_DIR}/genmsg_java.py)
#set(GENSRV_JAVA_BIN ${GENJAVA_BIN_DIR}/gensrv_java.py)

# genmsg usually uses this variable to configure the install location. we typically pick
# it up from the environment configured by rosjava_build_tools.
set(genjava_INSTALL_DIR "maven/org/ros/rosjava_messages")
set(ROS_MAVEN_DEPLOYMENT_REPOSITORY $ENV{ROS_MAVEN_DEPLOYMENT_REPOSITORY})
if(NOT ROS_MAVEN_DEPLOYMENT_REPOSITORY)
    set(ROS_MAVEN_DEPLOYMENT_REPOSITORY "${CATKIN_DEVEL_PREFIX}/${CATKIN_GLOBAL_MAVEN_DESTINATION}")
endif()

# Generate .msg->.h for py
# The generated .h files should be added ALL_GEN_OUTPUT_FILES_py
#
# Example arguments:
#
#   ARG_PKG      : foo_msgs
#   ARG_MSG      : /mnt/zaphod/ros/rosjava/hydro/src/foo_msgs/msg/Foo.msg
#   ARG_IFLAGS   : -Ifoo_msgs:/mnt/zaphod/ros/rosjava/hydro/src/foo_msgs/msg;-Istd_msgs:/opt/ros/hydro/share/std_msgs/cmake/../msg
#   ARG_MSG_DEPS : ???
#   ARG_GEN_OUTPUT_DIR : /mnt/zaphod/ros/rosjava/hydro/devel/${genjava_INSTALL_DIR}/foo_msgs
macro(_generate_msg_java ARG_PKG ARG_MSG ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)

    message(STATUS "GEN_MSG_JAVA..........._generate_msg_java [${ARG_PKG}][${ARG_MSG}]")
    #message(STATUS "  ARG_IFLAGS...........${ARG_IFLAGS}")
    #message(STATUS "  ARG_MSG_DEPS.........${ARG_MSG_DEPS}")
    #message(STATUS "  ARG_GEN_OUTPUT_DIR...${ARG_GEN_OUTPUT_DIR}")
    #message(STATUS "GEN_MSG_JAVA...........done")
    #message(STATUS "CMAKE_CURRENT_BINARY_DIR.......${CMAKE_CURRENT_BINARY_DIR}")

    #Append msg to output dir
    #set(GEN_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    #file(MAKE_DIRECTORY ${GEN_OUTPUT_DIR})
    # Create input and output filenames
    get_filename_component(MSG_SHORT_NAME ${ARG_MSG} NAME_WE)

    #file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/gradle)

    #set(MSG_GENERATED_NAME ${MSG_SHORT_NAME}.java)
    #set(GEN_OUTPUT_FILE ${GEN_OUTPUT_DIR}/${MSG_GENERATED_NAME})
    #message(STATUS "GEN_OUTPUT_FILE..........${GEN_OUTPUT_FILE}")
    #add_custom_command(OUTPUT ${GEN_OUTPUT_FILE}
    #  DEPENDS ${GENMSG_JAVA_BIN} ${ARG_MSG} ${ARG_MSG_DEPS}
    #  COMMAND ${CATKIN_ENV} cmake
    #  -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}
    #  -m ${ARG_MSG}
    #  ${ARG_IFLAGS}
    #  -p ${ARG_PKG}
    #  -o ${GEN_OUTPUT_DIR}
    #  COMMENT "Generating Java code from MSG ${ARG_PKG}/${MSG_SHORT_NAME}"
    #)

    #list(APPEND ALL_GEN_OUTPUT_FILES_java ${GEN_OUTPUT_FILE})
    #set(GEN_OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/java/org/ros/rosjava_messages/${ARG_PKG}/${MSG_SHORT_NAME}.java")
    #list(APPEND ALL_GEN_OUTPUT_FILES_java ${GEN_OUTPUT_FILE})
endmacro()

#todo, these macros are practically equal. Check for input file extension instead
macro(_generate_srv_java ARG_PKG ARG_SRV ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)

    message(STATUS "GEN_SRV_JAVA..........._generate_srv_java [${ARG_PKG}][${ARG_SRV}]")
    #Append msg to output dir
    #  set(GEN_OUTPUT_DIR "${ARG_GEN_OUTPUT_DIR}/srv")
    #  file(MAKE_DIRECTORY ${GEN_OUTPUT_DIR})
    #
    #Create input and output filenames
    #  get_filename_component(SRV_SHORT_NAME ${ARG_SRV} NAME_WE)
    #
    #  set(SRV_GENERATED_NAME _${SRV_SHORT_NAME}.py)
    #  set(GEN_OUTPUT_FILE ${GEN_OUTPUT_DIR}/${SRV_GENERATED_NAME})
    #
    #  add_custom_command(OUTPUT ${GEN_OUTPUT_FILE}
    #    DEPENDS ${GENSRV_PY_BIN} ${ARG_SRV} ${ARG_MSG_DEPS}
    #    COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENSRV_PY_BIN} ${ARG_SRV}
    #    ${ARG_IFLAGS}
    #    -p ${ARG_PKG}
    #    -o ${GEN_OUTPUT_DIR}
    #    COMMENT "Generating Python code from SRV ${ARG_PKG}/${SRV_SHORT_NAME}"
    #    )
    #
    #list(APPEND ALL_GEN_OUTPUT_FILES_java ${GEN_OUTPUT_FILE})
endmacro()

macro(_generate_module_java ARG_PKG ARG_GEN_OUTPUT_DIR ARG_GENERATED_FILES)

    message(STATUS "GEN_MODULE_JAVA..........._generate_module_java")
    message(STATUS "  ARG_PKG.................${ARG_PKG}")
    message(STATUS "  ARG_GEN_OUTPUT_DIR......${ARG_GEN_OUTPUT_DIR}")
    message(STATUS "  ARG_GENERATED_FILES.....${ARG_GENERATED_FILES}")
      
    set(GEN_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/java")
    set(GEN_OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/java/build.gradle")
    
    message(STATUS "  GEN_OUTPUT_FILE.........${GEN_OUTPUT_FILE}")
    message(STATUS "  GENJAVA_BIN.............${GENJAVA_BIN}")
    file(MAKE_DIRECTORY ${GEN_OUTPUT_DIR})
    #  if(IS_DIRECTORY ${GEN_OUTPUT_DIR})
    list(APPEND ALL_GEN_OUTPUT_FILES_java ${GEN_OUTPUT_FILE})
    add_custom_command(OUTPUT ${GEN_OUTPUT_FILE} # ${ARG_GENERATED_FILES}
        DEPENDS ${GENJAVA_BIN} # ${ARG_GENERATED_FILES}
        COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENJAVA_BIN}
            -o ${GEN_OUTPUT_DIR}
            -p ${ARG_PKG}
        COMMENT "Generating java gradle project for compiling ${ARG_PKG}"
    )
    #  list(APPEND ALL_GEN_OUTPUT_FILES_py ${GEN_OUTPUT_FILE})
endmacro()

