#
# pybind11.cmake  umbrella for pybind11
# 18-Nov-2024  for DFTracer dependency
#

#
# config:
#  PYBIND11_REPO - url of git repository
#  PYBIND11_TAG  - tag to checkout of git
#  PYBIND11_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET pybind11)

#
# umbrella option variables
#
umbrella_defineopt (PYBIND11_REPO
                    "https://github.com/pybind/pybind11.git"
                    STRING "pybind11 GIT repository")
umbrella_defineopt (PYBIND11_TAG "v2.12.0" STRING "pybind11 GIT tag")
umbrella_defineopt (PYBIND11_TAR "pybind11-${PYBIND11_TAG}.tar.gz"
                    STRING "pybind11 cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (PYBIND11_DOWNLOAD pybind11 ${PYBIND11_TAR}
                   GIT_REPOSITORY ${PYBIND11_REPO}
                   GIT_TAG ${PYBIND11_TAG})
umbrella_patchcheck (PYBIND11_PATCHCMD pybind11)

#
# create pybind11 target
#
ExternalProject_Add (pybind11
    ${PYBIND11_DOWNLOAD} ${PYBIND11_PATCHCMD}
    CMAKE_ARGS -DPYBIND11_TEST=OFF -DBUILD_SHARED_LIBS=ON
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET pybind11)
