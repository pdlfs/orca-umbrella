#
# caliper.cmake  umbrella for LLNL Caliper
#
# config:
#  CALIPER_REPO - url of git repository
#  CALIPER_TAG  - tag to checkout of git
#  CALIPER_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET caliper)

#
# umbrella option variables
#
umbrella_defineopt (CALIPER_REPO "https://github.com/LLNL/Caliper.git"
     STRING "Caliper GIT repository")
umbrella_defineopt (CALIPER_TAG "master" STRING "Caliper GIT tag")
umbrella_defineopt (CALIPER_TAR "caliper-${CALIPER_TAG}.tar.gz"
     STRING "Caliper cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (CALIPER_DOWNLOAD caliper ${CALIPER_TAR}
                   GIT_REPOSITORY ${CALIPER_REPO}
                   GIT_TAG ${CALIPER_TAG})
umbrella_patchcheck (CALIPER_PATCHCMD caliper)

#
# create caliper target
#
ExternalProject_Add (caliper
    ${CALIPER_DOWNLOAD} ${CALIPER_PATCHCMD}
    CMAKE_ARGS -DBUILD_SHARED_LIBS=ON
        -DWITH_MPI=ON
        -DWITH_KOKKOS=ON
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET caliper)
