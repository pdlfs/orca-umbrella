# have not tested with cmake < v3.22, arrow needs >= v3.16
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
project (orca-umbrella C CXX)

#
# configure umbrella and pull in the main routines
#
set (UMBRELLA_MPI 1)             # orca-umbrella uses MPI
set (UMBRELLA_HAS_GNULIBDIRS 1)  # our pkgs use cmake GNUInstallDirs
set (UMBRELLA_CXX_STANDARD 17)   # default C++ standard

include (umbrella-main)

#
# set default options for packages
#
umbrella_opt_default (MERCURY_NA_INITIALLY_ON "sm")

# We need to make ORCA force-depend on Kokkos hooks
# for the Phoebus demo even though it is optional.
umbrella_opt_default (ORCA_KOKKOS_HOOKS ON)

# Options for Parthenon stack
umbrella_opt_default (PARTHENON_TAG "lb3bar")
umbrella_opt_default (PHOEBUS_TAG "lb")
umbrella_opt_default(HDF5_TAG "hdf5_1_12_2")
umbrella_opt_default(HDF5_ENABLE_PARALLEL "ON")

#
# propagate the MPICXX setting to all cmake subprojects
#
list(APPEND UMBRELLA_CMAKECACHE -DMPI_CXX_SKIP_MPICXX:BOOL=${MPI_CXX_SKIP_MPICXX})


#
# set git tags to the versions we want to stick to by default...
#
umbrella_opt_default (GOOGLETEST_TAG "v1.15.2")
umbrella_opt_default (MERCURY_REPO "https://github.com/chuckcranor/mercury.git")
umbrella_opt_default (MERCURY_TAG "hg_rpcgen")
umbrella_opt_default (DFTRACER_REPO "https://github.com/anku94/dftracer.git")
umbrella_opt_default (DFTRACER_TAG "main")

#
# any additional cache variables we want to add that are not already
# part of the umbrella?
#
umbrella_opt_default(ARROW_DEPENDENCY_SOURCE "SYSTEM")
umbrella_opt_default(ARROW_FLIGHT ON)
umbrella_opt_default(ARROW_FLIGHT_SQL ON)
umbrella_opt_default(ARROW_PARQUET ON)

#
# Actual repos we want to build. Package combos are selected via UMBRELLA_PROFILE variants
# - DEPS: Dependencies needed to build ORCA. Useful for an out-of-tree ORCA build.
# - FULL: Builds orca + orca-utils (deps are pulled automatically)
# - ADAE: FULL + ORCA-augmented AMR code (phoebus) for AD/AE and testing
# - EVAL: FULL + phoebus + tracers (dftracer, caliper, scorep). 
#   + TAU needs to be built manually as its build system builds in-tree.
#   + Jul 2026: dftracer is removed as upstream dependencies seem to have gone offline.
# - XTRA: FULL + packages for experimental ORCA utils (libunwind, dyninst, libbpf)
#
set (UMBRELLA_PROFILE "FULL" CACHE STRING "Build profile: DEPS FULL ADAE EVAL XTRA")

set (UMBRELLA_PKGS_DEPS googletest mercury arrow yaml-cpp duckdb)
set (UMBRELLA_PKGS_FULL orca orca-utils)
set (UMBRELLA_PKGS_ADAE ${UMBRELLA_PKGS_FULL} phoebus)
set (UMBRELLA_PKGS_EVAL ${UMBRELLA_PKGS_ADAE} caliper scorep)
set (UMBRELLA_PKGS_XTRA ${UMBRELLA_PKGS_FULL} libunwind dyninst libbpf)

set (UMBRELLA_PKGS_ACTIVE ${UMBRELLA_PKGS_${UMBRELLA_PROFILE}})
message (INFO "Building following packages + dependencies: ${UMBRELLA_PKGS_ACTIVE}")

foreach (pkg IN LISTS UMBRELLA_PKGS_ACTIVE)
    include (umbrella/${pkg})
endforeach()
