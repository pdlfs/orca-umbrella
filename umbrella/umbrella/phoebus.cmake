#
# phoebus.cmake  umbrella for phoebus
# 10-May-2023  ankushj@andrew.cmu.edu
#

#
# config:
#  PHOEBUS_REPO - url of git repository
#  PHOEBUS_TAG  - tag to checkout of git
#  PHOEBUS_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET phoebus)

umbrella_defineopt (PHOEBUS_REPO "https://github.com/anku94/phoebus.git"
     STRING "PHOEBUS GIT repository")
umbrella_defineopt (PHOEBUS_TAG "main" STRING "PHOEBUS GIT tag")
umbrella_defineopt (PHOEBUS_TAR "phoebus-${PHOEBUS_TAG}.tar.gz"
     STRING "PHOEBUS cache tar file")
#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (PHOEBUS_DOWNLOAD phoebus
                   ${PHOEBUS_TAR}
                   GIT_REPOSITORY ${PHOEBUS_REPO}
                   GIT_TAG ${PHOEBUS_TAG})
umbrella_patchcheck (PHOEBUS_PATCHCMD phoebus)
# TODO: hook up tests (also add to ExternalProject_Add)
# umbrella_testcommand (phoebus PHOEBUS_TESTCMD
    # TEST_COMMAND ctest -R preload -V )

#
# depends
#
include (umbrella/hdf5)

#
# create phoebus target
#
ExternalProject_Add (phoebus
  DEPENDS hdf5
    ${PHOEBUS_DOWNLOAD} ${PHOEBUS_PATCHCMD}
    CMAKE_ARGS -DBUILD_SHARED_LIBS=OFF -DTAU_ROOT=${CMAKE_INSTALL_PREFIX}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET phoebus)
