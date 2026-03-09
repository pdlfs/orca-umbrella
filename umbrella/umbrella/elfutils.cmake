#
# elfutils.cmake  umbrella for elfutils (libelf, libdw)
# 09-Mar-2026  ankushj@andrew.cmu.edu
#

#
# config:
#  ELFUTILS_BASEURL - base url for downloading
#  ELFUTILS_URLFILE - tar file name
#  ELFUTILS_URLMD5  - md5 checksum of tar file
#

if (NOT TARGET elfutils)

#
# umbrella option variables
#
umbrella_defineopt (ELFUTILS_BASEURL
                    "https://sourceware.org/elfutils/ftp/0.192"
                    STRING "elfutils download URL base")
umbrella_defineopt (ELFUTILS_URLFILE "elfutils-0.192.tar.bz2"
                    STRING "elfutils tar file")
umbrella_defineopt (ELFUTILS_URLMD5 "a6bb1efc147302cfc15b5c2b827f186a"
                    STRING "MD5 of tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (ELFUTILS_DOWNLOAD elfutils ${ELFUTILS_URLFILE}
                   URL "${ELFUTILS_BASEURL}/${ELFUTILS_URLFILE}"
                   URL_MD5 ${ELFUTILS_URLMD5})
umbrella_patchcheck (ELFUTILS_PATCHCMD elfutils)

#
# create elfutils target
#
ExternalProject_Add (elfutils ${ELFUTILS_DOWNLOAD} ${ELFUTILS_PATCHCMD}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure ${UMBRELLA_COMP}
                      ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      --disable-debuginfod
                      --disable-libdebuginfod
    BUILD_COMMAND /usr/bin/make -j16
    INSTALL_COMMAND /usr/bin/make install
    UPDATE_COMMAND "")

endif (NOT TARGET elfutils)
