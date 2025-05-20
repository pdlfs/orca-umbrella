#
# mon.cmake  umbrella for mon
# 10-May-2023  ankushj@andrew.cmu.edu
#

#
# config:
#  MON_REPO - url of git repository
#  MON_TAG  - tag to checkout of git
#  MON_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET mon)

umbrella_defineopt (MON_REPO "https://github.com/anku94/mon.git"
     STRING "MON GIT repository")
umbrella_defineopt (MON_TAG "main" STRING "MON GIT tag")
umbrella_defineopt (MON_TAR "mon-${MON_TAG}.tar.gz"
     STRING "MON cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (MON_DOWNLOAD mon
                   ${MON_TAR}
                   GIT_REPOSITORY ${MON_REPO}
                   GIT_TAG ${MON_TAG})
umbrella_patchcheck (MON_PATCHCMD mon)
# TODO: hook up tests (also add to ExternalProject_Add)
# umbrella_testcommand (mon MON_TESTCMD
#                       ctest -R preload -V )

#
# depends
#
include (umbrella/googletest)
include (umbrella/mercury)
include (umbrella/arrow)
include (umbrella/yaml-cpp)

#
# create mon target
#
ExternalProject_Add (mon
    DEPENDS googletest mercury arrow yaml-cpp
    ${MON_DOWNLOAD} ${MON_PATCHCMD}
    CMAKE_ARGS -DCMAKE_PREFIX_PATH=${UMBRELLA_PREFIX_PATH}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET mon)
