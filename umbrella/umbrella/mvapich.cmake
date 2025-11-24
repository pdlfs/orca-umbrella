#
# mvapich.cmake  umbrella for mvapich package
# 30-Jul-2020  chuck@ece.cmu.edu
#

#
# config:
#  MVAPICH_BASEURL - base url of mvapich
#  MVAPICH_URLDIR  - subdir in base where it lives
#  MVAPICH_URLFILE - tar file within urldir
#  MVAPICH_URLMD5  - md5 of tar file
#
#  MVAPICH_DEVICE - optional --with-device option
#

if (NOT TARGET mvapich)

#
# umbrella option variables
#
umbrella_defineopt (MVAPICH_BASEURL
    "http://mvapich.cse.ohio-state.edu/download/mvapich"
    STRING "base url for mvapich")
umbrella_defineopt (MVAPICH_URLDIR "mv2" STRING "mvapich subdir")
umbrella_defineopt (MVAPICH_URLFILE "mvapich2-2.3.7-1.tar.gz"
    STRING "mvapich tar file name")
umbrella_defineopt (MVAPICH_URLMD5 "22f78ec18d417781ff803943ae62d6a9"
    STRING "MD5 of tar file")
#
# Cluster profile for device configuration
umbrella_defineopt(MVAPICH_PROFILE "" STRING "Cluster profile (wolf, orca)")

#
# local vars
#
unset(mvapich_devflags)
unset(mvapich_xtradeps)

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (MVAPICH_DOWNLOAD mvapich ${MVAPICH_URLFILE}
    URL "${MVAPICH_BASEURL}/${MVAPICH_URLDIR}/${MVAPICH_URLFILE}"
    URL_MD5 ${MVAPICH_URLMD5})
umbrella_patchcheck (MVAPICH_PATCHCMD mvapich)

#
# depends
#
# XXX: required?  (yes by default, maybe not for ch3:psm?)
include (umbrella/rdma-core)

#
# profile-based configuration
#
if ("${MVAPICH_PROFILE}" STREQUAL "wolf")
    message(STATUS "  MVAPICH wolf profile: PSM for QLogic fabric")
    include (umbrella/psm)
    set (mvapich_xtradeps "psm")
    set (mvapich_devflags "--with-device=ch3:psm")
elseif ("${MVAPICH_PROFILE}" STREQUAL "orca")
    message(STATUS "  MVAPICH orca profile: MRAIL/gen2 for Mellanox RoCE")
    set (mvapich_devflags "--with-device=ch3:mrail" "--with-rdma=gen2")
elseif ("${MVAPICH_PROFILE}" STREQUAL "")
    message(STATUS "  MVAPICH default configuration")
else()
    message(FATAL_ERROR "MVAPICH unknown profile ${MVAPICH_PROFILE}")
endif()

#
# create mvapich target
#
ExternalProject_Add (mvapich DEPENDS rdma-core ${mvapich_xtradeps}
    ${MVAPICH_DOWNLOAD} ${MVAPICH_PATCHCMD}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
                      FFLAGS=-fallow-argument-mismatch
                      FCFLAGS=-fallow-argument-mismatch
                      <SOURCE_DIR>/configure ${UMBRELLA_COMP}
                      ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      ${mvapich_devflags}
                      BUILD_IN_SOURCE 1  # XXX: bug. fails w/o this.
                      UPDATE_COMMAND "")

endif (NOT TARGET mvapich)
