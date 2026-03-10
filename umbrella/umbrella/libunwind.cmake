#
# libunwind.cmake  umbrella for libunwind (stack unwinding library)
# 09-Mar-2026  ankushj@andrew.cmu.edu
#

#
# config:
#  LIBUNWIND_BASEURL - base url for downloading
#  LIBUNWIND_URLFILE - tar file name
#  LIBUNWIND_URLMD5  - md5 checksum of tar file
#

if (NOT TARGET libunwind)

#
# umbrella option variables
#
umbrella_defineopt (LIBUNWIND_BASEURL
                    "https://github.com/libunwind/libunwind/releases/download/v1.8.3"
                    STRING "libunwind download URL base")
umbrella_defineopt (LIBUNWIND_URLFILE "libunwind-1.8.3.tar.gz"
                    STRING "libunwind tar file")
umbrella_defineopt (LIBUNWIND_URLMD5 "13bc7b41462ac6ea157d350eaf6c1503"
                    STRING "MD5 of tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (LIBUNWIND_DOWNLOAD libunwind ${LIBUNWIND_URLFILE}
                   URL "${LIBUNWIND_BASEURL}/${LIBUNWIND_URLFILE}"
                   URL_MD5 ${LIBUNWIND_URLMD5})
umbrella_patchcheck (LIBUNWIND_PATCHCMD libunwind)

#
# create libunwind target
#
ExternalProject_Add (libunwind ${LIBUNWIND_DOWNLOAD} ${LIBUNWIND_PATCHCMD}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure ${UMBRELLA_COMP}
                      ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      --enable-shared
                      --with-pic
                      --disable-tests
    BUILD_COMMAND $(MAKE)
    INSTALL_COMMAND $(MAKE) install
    UPDATE_COMMAND "")

endif (NOT TARGET libunwind)
