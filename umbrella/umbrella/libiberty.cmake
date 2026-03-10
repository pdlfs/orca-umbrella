#
# libiberty.cmake  umbrella for libiberty (from GNU binutils)
# 09-Mar-2026  ankushj@andrew.cmu.edu
#
# Builds libiberty standalone from the binutils tarball.
# Uses --enable-install-libiberty so headers and .a are installed properly.
# Built with -fPIC so it can be linked into shared libraries.
#

#
# config:
#  LIBIBERTY_BASEURL - base url for downloading (uses binutils tarball)
#  LIBIBERTY_URLFILE - tar file name
#  LIBIBERTY_URLMD5  - md5 checksum of tar file
#

if (NOT TARGET libiberty)

#
# umbrella option variables (same tarball as binutils)
#
umbrella_defineopt (LIBIBERTY_BASEURL "https://ftp.gnu.org/gnu/binutils"
                    STRING "libiberty download URL base")
umbrella_defineopt (LIBIBERTY_URLFILE "binutils-2.44.tar.gz"
                    STRING "libiberty tar file")
umbrella_defineopt (LIBIBERTY_URLMD5 "6c02ef5e0de5096f0e9cd6f9d48a4be3"
                    STRING "MD5 of tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (LIBIBERTY_DOWNLOAD libiberty ${LIBIBERTY_URLFILE}
                   URL "${LIBIBERTY_BASEURL}/${LIBIBERTY_URLFILE}"
                   URL_MD5 ${LIBIBERTY_URLMD5})
umbrella_patchcheck (LIBIBERTY_PATCHCMD libiberty)

#
# create libiberty target
# configure the libiberty subdir of binutils source directly
#
ExternalProject_Add (libiberty ${LIBIBERTY_DOWNLOAD} ${LIBIBERTY_PATCHCMD}
    CONFIGURE_COMMAND <SOURCE_DIR>/libiberty/configure ${UMBRELLA_COMP}
                      ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      --enable-install-libiberty
                      "CFLAGS=-g -O2 -fPIC"
    BUILD_COMMAND $(MAKE)
    INSTALL_COMMAND $(MAKE) install
    UPDATE_COMMAND "")

endif (NOT TARGET libiberty)
