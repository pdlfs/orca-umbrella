# haven't tested with a version below this, need at least 3.16 for arrow
cmake_minimum_required (VERSION 3.22)

#
# put the umbrella scripts in our search path and include umbrella-init
# (umbrella-init needs to run before "project")
#
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/umbrella")

if (POLICY CMP0135)
    # Set this to new to use current timestamps for extracting archives
    # Not having this triggers DOWNLOAD_EXTRACT_TIMESTAMP warnings
    # CMake unsets policies set in umbrella-init.cmake, hence this
    cmake_policy(SET CMP0135 NEW)
endif()

include (umbrella-init)

#
# we don't really use MPICXX for now. The difference between CXX and MPICXX
# is that CXX refers to the MPI C API being usable from C++, whereas MPICXX
# refers to the MPI-2 C++ API that was removed again in MPI-3.
# To enable MPICXX, run umbrella with -DMPI_CXX_SKIP_MPICXX=Off.
#
set (MPI_CXX_SKIP_MPICXX ON CACHE BOOL "True if MPICXX should be skipped")

#
# need to mark project as using C/CXX so we can probe for MPI
# using a compiler that may have been passed in via the command line
# or by using environment vars.
#
project (mon-umbrella C CXX)

#
# configure umbrella and pull in the main routines
#
set (UMBRELLA_MPI 1)             # amr-umbrella uses MPI
set (UMBRELLA_HAS_GNULIBDIRS 1)  # our pkgs use cmake GNUInstallDirs
set (UMBRELLA_CXX_STANDARD 17)   # default C++ standard

include (umbrella-main)

#
# set default options for packages
#
umbrella_opt_default (MERCURY_NA_INITIALLY_ON "sm")

#
# propagate the MPICXX setting to all cmake subprojects
#
list(APPEND UMBRELLA_CMAKECACHE -DMPI_CXX_SKIP_MPICXX:BOOL=${MPI_CXX_SKIP_MPICXX})


#
# set git tags to the versions we want to stick to by default...
#
umbrella_opt_default (GOOGLETEST_TAG "v1.15.2")
umbrella_opt_default (MON_TAG "main")
umbrella_opt_default (MERCURY_REPO "https://github.com/chuckcranor/mercury.git")
umbrella_opt_default (MERCURY_TAG "hg_rpcgen")
umbrella_opt_default (YAML_CPP_TAG "0.8.0")

#
# any additional cache variables we want to add that are not already
# part of the umbrella?
#
umbrella_opt_default(ARROW_DEPENDENCY_SOURCE "SYSTEM")
umbrella_opt_default(ARROW_FLIGHT ON)
umbrella_opt_default(ARROW_FLIGHT_SQL ON)
umbrella_opt_default(ARROW_PARQUET ON)
umbrella_opt_default (BOOST_WITHLIBS 
    "chrono,filesystem,program_options,random,system,thread,test")

#
# Actual repos we want to build
#
include (umbrella/googletest)
include (umbrella/arrow)
include (umbrella/mercury)
include (umbrella/duckdb)
include (umbrella/yaml-cpp)
# include (umbrella/mon)
