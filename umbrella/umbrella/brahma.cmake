#
# brahma.cmake  umbrella for brahma I/O interception framework
# 18-Nov-2024  for DFTracer dependency
#

#
# config:
#  BRAHMA_REPO - url of git repository
#  BRAHMA_TAG  - tag to checkout of git
#  BRAHMA_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET brahma)

#
# umbrella option variables
#
umbrella_defineopt (BRAHMA_REPO
                    "https://github.com/hariharan-devarajan/brahma.git"
                    STRING "brahma GIT repository")
umbrella_defineopt (BRAHMA_TAG "v1.0.1" STRING "brahma GIT tag")
umbrella_defineopt (BRAHMA_TAR "brahma-${BRAHMA_TAG}.tar.gz"
                    STRING "brahma cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (BRAHMA_DOWNLOAD brahma ${BRAHMA_TAR}
                   GIT_REPOSITORY ${BRAHMA_REPO}
                   GIT_TAG ${BRAHMA_TAG})
umbrella_patchcheck (BRAHMA_PATCHCMD brahma)

#
# depends on gotcha and yaml-cpp
#
set (BRAHMA_DEPENDS gotcha yaml-cpp)
include (umbrella/gotcha)
include (umbrella/yaml-cpp)

#
# create brahma target
#
ExternalProject_Add (brahma
    DEPENDS ${BRAHMA_DEPENDS}
    ${BRAHMA_DOWNLOAD} ${BRAHMA_PATCHCMD}
    CMAKE_ARGS -DBUILD_SHARED_LIBS=ON
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET brahma)
