##############################################################################
# Installs
##############################################################################

# Rosrunnable installation of scripts
catkin_install_python(
  PROGRAMS 
    genjava_gradle_project.py
    genjava_message_artifacts
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)