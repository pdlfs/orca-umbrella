#
# dftracer.cmake  umbrella for DFTracer
# 18-Nov-2024  for HPC I/O tracing
#

#
# config:
#  DFTRACER_REPO - url of git repository
#  DFTRACER_TAG  - tag to checkout of git
#  DFTRACER_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET dftracer)

#
# umbrella option variables
#
umbrella_defineopt (DFTRACER_REPO "https://github.com/anku94/dftracer.git"
                    STRING "DFTracer GIT repository")
umbrella_defineopt (DFTRACER_TAG "main" STRING "DFTracer GIT tag")
umbrella_defineopt (DFTRACER_TAR "dftracer-${DFTRACER_TAG}.tar.gz"
                    STRING "DFTracer cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (DFTRACER_DOWNLOAD dftracer ${DFTRACER_TAR}
                   GIT_REPOSITORY ${DFTRACER_REPO}
                   GIT_TAG ${DFTRACER_TAG})
umbrella_patchcheck (DFTRACER_PATCHCMD dftracer)

#
# depends on cpp-logger, brahma, gotcha, yaml-cpp, pybind11
#
set (DFTRACER_DEPENDS cpp-logger brahma gotcha yaml-cpp pybind11)
include (umbrella/cpp-logger)
include (umbrella/brahma)
include (umbrella/gotcha)
include (umbrella/yaml-cpp)
include (umbrella/pybind11)

#
# cmake args for dftracer
#
set (DFTRACER_CMAKE_ARGS
     -DDFTRACER_ENABLE_MPI=ON
     -DDFTRACER_DISABLE_HWLOC=ON
     -DDFTRACER_ENABLE_HIP_TRACING=OFF
     -DDFTRACER_ENABLE_FTRACING=OFF
     -DDFTRACER_BUILD_PYTHON_BINDINGS=OFF
     -DBUILD_SHARED_LIBS=ON)

#
# create dftracer target
#
ExternalProject_Add (dftracer
    DEPENDS ${DFTRACER_DEPENDS}
    ${DFTRACER_DOWNLOAD} ${DFTRACER_PATCHCMD}
    CMAKE_ARGS ${DFTRACER_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET dftracer)
