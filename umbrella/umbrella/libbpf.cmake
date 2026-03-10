#
# libbpf.cmake  umbrella for libbpf (eBPF user-space library)
# 10-Mar-2026  ankushj@andrew.cmu.edu
#

#
# config:
#  LIBBPF_REPO - url of git repository
#  LIBBPF_TAG  - tag to checkout of git
#  LIBBPF_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET libbpf)

#
# umbrella option variables
#
umbrella_defineopt (LIBBPF_REPO "https://github.com/libbpf/libbpf.git"
     STRING "libbpf GIT repository")
umbrella_defineopt (LIBBPF_TAG "v1.6.3" STRING "libbpf GIT tag")
umbrella_defineopt (LIBBPF_TAR "libbpf-${LIBBPF_TAG}.tar.gz"
     STRING "libbpf cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (LIBBPF_DOWNLOAD libbpf ${LIBBPF_TAR}
                   GIT_REPOSITORY ${LIBBPF_REPO}
                   GIT_TAG ${LIBBPF_TAG})
umbrella_patchcheck (LIBBPF_PATCHCMD libbpf)

#
# depends
#
include (umbrella/zlib)
include (umbrella/elfutils)

#
# create libbpf target
#
ExternalProject_Add (libbpf DEPENDS zlib elfutils
    ${LIBBPF_DOWNLOAD} ${LIBBPF_PATCHCMD}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND /usr/bin/make -C <SOURCE_DIR>/src -j16
        OBJDIR=<BINARY_DIR>
        PREFIX=${CMAKE_INSTALL_PREFIX}
        DESTDIR=
        PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/lib/pkgconfig
    INSTALL_COMMAND /usr/bin/make -C <SOURCE_DIR>/src install
        OBJDIR=<BINARY_DIR>
        PREFIX=${CMAKE_INSTALL_PREFIX}
        DESTDIR=
        PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/lib/pkgconfig
    UPDATE_COMMAND "")

endif (NOT TARGET libbpf)
