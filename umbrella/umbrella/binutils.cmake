#
# binutils.cmake  umbrella for GNU binutils (for libbfd)
# 18-Nov-2024  for Score-P dependency
#

#
# config:
#  BINUTILS_BASEURL - base url for downloading
#  BINUTILS_URLFILE - tar file name
#  BINUTILS_URLMD5  - md5 checksum of tar file
#

if (NOT TARGET binutils)

#
# umbrella option variables
#
umbrella_defineopt (BINUTILS_BASEURL "https://ftp.gnu.org/gnu/binutils"
                    STRING "Binutils download URL base")
umbrella_defineopt (BINUTILS_URLFILE "binutils-2.44.tar.gz"
                    STRING "Binutils tar file")
umbrella_defineopt (BINUTILS_URLMD5 "6c02ef5e0de5096f0e9cd6f9d48a4be3"
                    STRING "MD5 of tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (BINUTILS_DOWNLOAD binutils ${BINUTILS_URLFILE}
                   URL "${BINUTILS_BASEURL}/${BINUTILS_URLFILE}"
                   URL_MD5 ${BINUTILS_URLMD5})
umbrella_patchcheck (BINUTILS_PATCHCMD binutils)

#
# create binutils target
# configure with --enable-shared to get shared libbfd
# only build bfd; this module exists to provide libbfd
#
ExternalProject_Add (binutils ${BINUTILS_DOWNLOAD} ${BINUTILS_PATCHCMD}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure ${UMBRELLA_COMP}
                      ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
                      MAKEINFO=true  # skip Texinfo docs by replacing makeinfo with no-op true
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      --enable-shared
                      --disable-nls
                      --disable-werror
    BUILD_COMMAND $(MAKE) MAKEINFO=true all-bfd
    INSTALL_COMMAND $(MAKE) MAKEINFO=true install-bfd
    UPDATE_COMMAND "")

endif (NOT TARGET binutils)
