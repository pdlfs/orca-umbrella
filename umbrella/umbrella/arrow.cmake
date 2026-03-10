#
# arrow.cmake  umbrella for Apache Arrow
# 2025-02-13  ankushj@andrew.cmu.edu
#

#
# config:
#  ARROW_REPO - Arrow GIT repository
#  ARROW_TAG  - Arrow GIT tag
#  ARROW_TAR  - Arrow cache tar file
#

if (NOT TARGET arrow)

#
# umbrella option variables
#
umbrella_defineopt (ARROW_REPO "https://github.com/apache/arrow.git"
                    STRING "Apache Arrow GIT repository")

# Arrow 19.0.0 is the last version to support CMake 3.16
# Arrow 19.0.1 bumps CMake version to 3.25
umbrella_defineopt (ARROW_TAG "apache-arrow-19.0.0"
                    STRING "Apache Arrow GIT tag")
umbrella_defineopt (ARROW_TAR "arrow-${ARROW_TAG}.tar.gz"
                    STRING "Apache Arrow cache tar file")

#
# Arrow feature flags
#
umbrella_defineopt (ARROW_FLIGHT OFF BOOL "Enable Arrow Flight")
umbrella_defineopt (ARROW_FLIGHT_SQL OFF BOOL "Enable Arrow Flight SQL")
umbrella_defineopt (ARROW_PARQUET OFF BOOL "Enable Arrow Parquet")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (ARROW_DOWNLOAD arrow
                   ${ARROW_TAR}
                   GIT_REPOSITORY ${ARROW_REPO}
                   GIT_TAG ${ARROW_TAG})
umbrella_patchcheck (ARROW_PATCHCMD arrow)

#
# Arrow dependency source: AUTO, BUNDLED, SYSTEM, CONDA, VCPKG, BREW
# - AUTO and BUNDLED: both trigger a download
# - SYSTEM: uses system libraries (using find_package, or pkg-config)
#
umbrella_defineopt (ARROW_DEPENDENCY_SOURCE "AUTO" STRING
  "Arrow dependency source")

#
# configure flags for arrow
#
set(ARROW_CMAKE_ARGS
  -DARROW_CSV=ON
  -DARROW_MIMALLOC=OFF  # enabled by default, triggers download
  -DARROW_WITH_RE2=OFF
  -DARROW_WITH_UTF8PROC=OFF
  -DARROW_DEPENDENCY_SOURCE=${ARROW_DEPENDENCY_SOURCE}
  -DARROW_ALTIVEC=OFF
  -DARROW_IPC=ON # need IPC for serdes
  -DARROW_FLIGHT=${ARROW_FLIGHT} # need for flightsql
  -DARROW_FLIGHT_SQL=${ARROW_FLIGHT_SQL} # need flightsql for server
  -DBUILD_SHARED_LIBS=ON
  -DARROW_PARQUET=${ARROW_PARQUET}
)

#
# set dependencies
#
set (ARROW_DEPENDS xsimd)
include (umbrella/xsimd)

# Build umbrella dependencies if source is not BUNDLED
if (NOT ARROW_DEPENDENCY_SOURCE STREQUAL "BUNDLED")
  if (ARROW_FLIGHT OR ARROW_FLIGHT_SQL)
    message (STATUS "Arrow: flight enabled, building grpc")

    list (APPEND ARROW_DEPENDS grpc gflags)
    include (umbrella/gflags)
    include (umbrella/grpc)
  endif (ARROW_FLIGHT OR ARROW_FLIGHT_SQL)

  if (ARROW_PARQUET)
    message (STATUS "Arrow: parquet enabled, building thrift")

    list (APPEND ARROW_DEPENDS thrift)
    include (umbrella/thrift)
  endif (ARROW_PARQUET)
endif (NOT ARROW_DEPENDENCY_SOURCE STREQUAL "BUNDLED")

#
# create arrow target
#
ExternalProject_Add (arrow DEPENDS ${ARROW_DEPENDS}
    ${ARROW_DOWNLOAD} ${ARROW_PATCHCMD}
    SOURCE_SUBDIR cpp
    CMAKE_ARGS ${ARROW_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET arrow) 
