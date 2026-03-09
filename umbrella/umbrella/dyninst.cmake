#
# dyninst.cmake  umbrella for Dyninst binary instrumentation framework
# 09-Mar-2026  ankushj@andrew.cmu.edu
#

#
# config:
#  DYNINST_REPO - url of git repository
#  DYNINST_TAG  - tag to checkout of git
#  DYNINST_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET dyninst)

#
# umbrella option variables
#
umbrella_defineopt (DYNINST_REPO "https://github.com/dyninst/dyninst.git"
     STRING "dyninst GIT repository")
umbrella_defineopt (DYNINST_TAG "v13.0.0" STRING "dyninst GIT tag")
umbrella_defineopt (DYNINST_TAR "dyninst-${DYNINST_TAG}.tar.gz"
     STRING "dyninst cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (DYNINST_DOWNLOAD dyninst ${DYNINST_TAR}
                   GIT_REPOSITORY ${DYNINST_REPO}
                   GIT_TAG ${DYNINST_TAG})
umbrella_patchcheck (DYNINST_PATCHCMD dyninst)

#
# depends
#
include (umbrella/elfutils)
include (umbrella/onetbb)
include (umbrella/boost)
include (umbrella/libiberty)

#
# create dyninst target
#
ExternalProject_Add (dyninst
    DEPENDS elfutils onetbb boost libiberty
    ${DYNINST_DOWNLOAD} ${DYNINST_PATCHCMD}
    CMAKE_ARGS -DUSE_OpenMP=OFF
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET dyninst)
