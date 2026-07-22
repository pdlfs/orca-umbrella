#
# orca.cmake  umbrella for orca
# 06-Nov-2025  ankushj@andrew.cmu.edu
#

#
# config:
#  ORCA_REPO - url of git repository
#  ORCA_TAG  - tag to checkout of git
#  ORCA_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET orca)

umbrella_defineopt (ORCA_REPO "https://github.com/pdlfs/orca.git"
     STRING "ORCA GIT repository")
umbrella_defineopt (ORCA_TAG "main" STRING "ORCA GIT tag")
umbrella_defineopt (ORCA_TAR "orca-${ORCA_TAG}.tar.gz"
     STRING "ORCA cache tar file")
umbrella_buildtests(orca ORCA_BUILDTESTS)

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (ORCA_DOWNLOAD orca
                   ${ORCA_TAR}
                   GIT_REPOSITORY ${ORCA_REPO}
                   GIT_TAG ${ORCA_TAG})
umbrella_patchcheck (ORCA_PATCHCMD orca)
# TODO: hook up tests (also add to ExternalProject_Add)
# umbrella_testcommand (orca ORCA_TESTCMD
#                       ctest -R preload -V )

#
# depends
#
include (umbrella/googletest)
include (umbrella/mercury)
include (umbrella/arrow)
include (umbrella/yaml-cpp)
include (umbrella/duckdb)

#
# create orca target
#
ExternalProject_Add (orca
    DEPENDS googletest mercury arrow yaml-cpp duckdb
    ${ORCA_DOWNLOAD} ${ORCA_PATCHCMD}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${UMBRELLA_PKGCFGPATH}
        ${CMAKE_COMMAND} -S <SOURCE_DIR> -B <BINARY_DIR>
            -DCMAKE_PREFIX_PATH=${UMBRELLA_PREFIX_PATH}
            -DORCA_BUILD_TESTING=${ORCA_BUILDTESTS}
            ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET orca)
