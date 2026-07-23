#
# orca-utils.cmake  umbrella for orca-utils
#

#
# config:
#  ORCA_UTILS_REPO - url of git repository
#  ORCA_UTILS_TAG  - tag to checkout of git
#  ORCA_UTILS_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET orca-utils)

umbrella_defineopt (ORCA_UTILS_REPO "https://github.com/pdlfs/orca-utils.git"
     STRING "ORCA_UTILS GIT repository")
umbrella_defineopt (ORCA_UTILS_TAG "main" STRING "ORCA_UTILS GIT tag")
umbrella_defineopt (ORCA_UTILS_TAR "orca-utils-${ORCA_UTILS_TAG}.tar.gz"
     STRING "ORCA_UTILS cache tar file")

umbrella_download (ORCA_UTILS_DOWNLOAD orca-utils
                   ${ORCA_UTILS_TAR}
                   GIT_REPOSITORY ${ORCA_UTILS_REPO}
                   GIT_TAG ${ORCA_UTILS_TAG})
umbrella_patchcheck (ORCA_UTILS_PATCHCMD orca-utils)

#
# depends
#
include (umbrella/orca)

#
# create orca-utils target
#
ExternalProject_Add (orca-utils
    DEPENDS orca
    ${ORCA_UTILS_DOWNLOAD} ${ORCA_UTILS_PATCHCMD}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET orca-utils)
