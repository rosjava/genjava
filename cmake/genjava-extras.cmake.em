@[if DEVELSPACE]@
# location of scripts in develspace
set(GENJAVA_BIN_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/scripts")
@[else]@
# location of scripts in installspace
set(GENJAVA_BIN_DIR "${genjava_DIR}/../../../@(CATKIN_PACKAGE_BIN_DESTINATION)")
@[end if]@

set(GENJAVA_BIN ${GENJAVA_BIN_DIR}/genjava_gradle_project.py)
set(genjava_INSTALL_DIR "maven/org/ros/rosjava_messages")

macro(_generate_msg_java ARG_PKG ARG_MSG ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)
  list(APPEND ALL_GEN_OUTPUT_FILES_java ${ARG_MSG} ${ARG_MSG_DEPS})

    # Example arguments:
    #
    #   ARG_PKG      : foo_msgs
    #   ARG_MSG      : /mnt/zaphod/ros/rosjava/hydro/src/foo_msgs/msg/Foo.msg
    #   ARG_IFLAGS   : -Ifoo_msgs:/mnt/zaphod/ros/rosjava/hydro/src/foo_msgs/msg;-Istd_msgs:/opt/ros/hydro/share/std_msgs/cmake/../msg
    #   ARG_MSG_DEPS : ???
    #   ARG_GEN_OUTPUT_DIR : /mnt/zaphod/ros/rosjava/hydro/devel/${genjava_INSTALL_DIR}/foo_msgs
    
    #message(STATUS "Java generator for [${ARG_PKG}][${ARG_MSG}]")
    #message(STATUS "  ARG_IFLAGS...........${ARG_IFLAGS}")
    #message(STATUS "  ARG_MSG_DEPS.........${ARG_MSG_DEPS}")
    #message(STATUS "  ARG_GEN_OUTPUT_DIR...${ARG_GEN_OUTPUT_DIR}")
    #message(STATUS "GEN_MSG_JAVA...........done")
    #message(STATUS "CMAKE_CURRENT_BINARY_DIR.......${CMAKE_CURRENT_BINARY_DIR}")
endmacro()

macro(_generate_srv_java ARG_PKG ARG_SRV ARG_IFLAGS ARG_MSG_DEPS ARG_GEN_OUTPUT_DIR)
  list(APPEND ALL_GEN_OUTPUT_FILES_java ${ARG_SRV} ${ARG_MSG_DEPS})
endmacro()

# This is a bit different to the other generators - it generates the whole message package together
# (unless there's another api I'm not aware of yet in the generator jar). It's a few milliseconds
# of overkill generating all .java files if only one msg changed, but it's not worth the effort to
# break that down yet.
# 
# To facilitate this, the ARG_GENERATED_FILES is actually just the underlying ARG_MSG and ARG_SRV
# files which we feed the commands as DEPENDS to trigger their execution.
macro(_generate_module_java ARG_PKG ARG_GEN_OUTPUT_DIR ARG_GENERATED_FILES)
    ################################
    # Gradle Subproject
    ################################
    set(GRADLE_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/java")
    set(GRADLE_BUILD_FILE "${GRADLE_BUILD_DIR}/${ARG_PKG}/build.gradle")
    list(APPEND ALL_GEN_OUTPUT_FILES_java ${GRADLE_BUILD_FILE})
    # a marker for the compiling script later to discover
    # this command will only get run when an underlying dependency changes, whereas the compiling
    # add_custom_target always runs (this was so we can ensure compile time dependencies are ok).
    # So we leave this dropping to inform it when gradle needs to run so that we can skip by
    # without the huge latency whenever we don't.
    set(DROPPINGS_FILE "${GRADLE_BUILD_DIR}/${ARG_PKG}/droppings")
    add_custom_command(OUTPUT ${GRADLE_BUILD_FILE}
        DEPENDS ${GENJAVA_BIN} ${ARG_GENERATED_FILES}
        COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENJAVA_BIN}
            -o ${GRADLE_BUILD_DIR}
            -p ${ARG_PKG}
        COMMAND touch ${DROPPINGS_FILE}
        COMMENT "Generating Java gradle project from ${ARG_PKG}"
    )

    ################################
    # Compile Gradle Subproject
    ################################
    # Push the compile back to the last thing that gets done before the generate messages
    # is done for this package (see the PRE_LINK coupled with the TARGET option below). This
    # is different to genpy, gencpp since it's a compile step. If you don't force it to be
    # the last thing, then it may be trying to compile while dependencies are still getting
    # themselves ready for ${ARG_PKG}_generate_messages in parallel.
    # (i.e. beware of sequencing add_custom_command, it usually has to compete)
    set(ROS_GRADLE_VERBOSE $ENV{ROS_GRADLE_VERBOSE})
    if(ROS_GRADLE_VERBOSE)
        set(verbosity "--verbosity")
    else()
        set(verbosity "")
    endif()

    add_custom_target(${ARG_PKG}_generate_messages_java_gradle
        COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENJAVA_BIN}
            ${verbosity}
            --compile
            -o ${GRADLE_BUILD_DIR}
            -p ${ARG_PKG}
        DEPENDS ${GRADLE_BUILD_FILE} ${ARG_GENERATED_FILES}
        WORKING_DIRECTORY ${GRADLE_BUILD_DIR}/${ARG_PKG}
        COMMENT "Compiling Java code for ${ARG_PKG}"
    )
    add_dependencies(${ARG_PKG}_generate_messages ${ARG_PKG}_generate_messages_java_gradle)

    ################################
    # Dependent Targets
    ################################
    # This is a bad hack that needs to disappear. e.g.
    # - topic_tools and roscpp are both packages with a couple of msgs
    # - topic tools messages doesn't actually depend on roscpp messages
    # this is guarded, so it's not doubling up on work when called from catkin_package (roscpp does this too)
    # and we need it to get access to the build_depends list just in case people called generate_messages before catkin_package()
    if(NOT DEFINED ${ARG_PKG}_BUILD_DEPENDS)
        catkin_package_xml(DIRECTORY ${PROJECT_SOURCE_DIR})
    endif()
    foreach(depends ${${ARG_PKG}_BUILD_DEPENDS})
        if(TARGET ${depends}_generate_messages_java_gradle)
            #message(STATUS "Adding dependency.....${depends}_generate_messages -> ${ARG_PKG}_generate_messages")
            add_dependencies(${ARG_PKG}_generate_messages_java_gradle ${depends}_generate_messages_java_gradle)
        endif()
    endforeach()
    # Make sure we have built gradle-rosjava_bootstrap if it is in the source workspace
    # (otherwise package.xml will make sure it has installed via rosdep/deb.
    if(TARGET gradle-rosjava_bootstrap)
        # Preference would be to add it to ${ARG_PKG}_generate_messages_java but that
        # is not defined till after this module is parsed, so add it all
        add_dependencies(${ARG_PKG}_generate_messages_java_gradle gradle-rosjava_bootstrap)
    endif()

    ################################
    # Debugging
    ################################
    #foreach(gen_output_file ${ALL_GEN_OUTPUT_FILES_java})
    #    message(STATUS "ALL_GEN_OUTPUT_FILES_java..........${gen_output_file}")
    #endforeach()
endmacro()

