#
# duckdb.cmake  umbrella for duckdb
# 2025-03-22  ankushj@andrew.cmu.edu
#

if (NOT TARGET duckdb)

#
# umbrella option variables
#
umbrella_defineopt (DUCKDB_REPO "https://github.com/duckdb/duckdb.git"
                    STRING "duckdb GIT repository")
umbrella_defineopt (DUCKDB_TAG "v1.2.1"
                    STRING "duckdb GIT tag")
umbrella_defineopt (DUCKDB_TAR "duckdb-${DUCKDB_TAG}.tar.gz"
                    STRING "duckdb cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (DUCKDB_DOWNLOAD duckdb
                   ${DUCKDB_TAR}
                   GIT_REPOSITORY ${DUCKDB_REPO}
                   GIT_TAG ${DUCKDB_TAG})
umbrella_patchcheck (DUCKDB_PATCHCMD duckdb)

#
# set dependencies
#
set (DUCKDB_DEPENDS arrow)

#
# include dependency targets
#
include (umbrella/arrow)

#
# configure flags for duckdb
#
set(DUCKDB_CMAKE_ARGS
  BUILD_SHELL=OFF
  BUILD_TESTING=OFF
  BUILD_UNITTESTS=OFF
)

#
# create duckdb target
#
ExternalProject_Add (duckdb DEPENDS ${DUCKDB_DEPENDS}
    ${DUCKDB_DOWNLOAD} ${DUCKDB_PATCHCMD}
    CMAKE_ARGS ${DUCKDB_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)


endif (NOT TARGET duckdb)

