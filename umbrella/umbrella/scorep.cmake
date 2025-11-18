#
# scorep.cmake  umbrella for Score-P performance measurement infrastructure
# 18-Nov-2024  for HPC tracing benchmarks
#

#
# config:
#  SCOREP_BASEURL - base url for downloading
#  SCOREP_URLFILE - tar file name
#  SCOREP_URLMD5  - md5 checksum of tar file
#

if (NOT TARGET scorep)

#
# umbrella option variables
#
umbrella_defineopt (SCOREP_BASEURL
    "https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/scorep-9.3"
    STRING "Score-P download URL base")
umbrella_defineopt (SCOREP_URLFILE "scorep-9.3.tar.gz"
    STRING "Score-P tar file")
umbrella_defineopt (SCOREP_URLMD5 "661e52f439614e51164526d5a2c28b7a"
    STRING "MD5 of tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (SCOREP_DOWNLOAD scorep ${SCOREP_URLFILE}
                   URL "${SCOREP_BASEURL}/${SCOREP_URLFILE}"
                   URL_MD5 ${SCOREP_URLMD5})
umbrella_patchcheck (SCOREP_PATCHCMD scorep)

#
# depends on binutils (for libbfd) and gotcha
#
set (SCOREP_DEPENDS binutils gotcha)
include (umbrella/binutils)
include (umbrella/gotcha)

#
# create scorep target
# Note: Score-P expects paths to libbfd and libgotcha installations
#
ExternalProject_Add (scorep
    DEPENDS ${SCOREP_DEPENDS}
    ${SCOREP_DOWNLOAD} ${SCOREP_PATCHCMD}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure ${UMBRELLA_MPICOMP}
                      ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      --with-libbfd=${CMAKE_INSTALL_PREFIX}
                      --with-libgotcha=${CMAKE_INSTALL_PREFIX}
    UPDATE_COMMAND "")

endif (NOT TARGET scorep)
