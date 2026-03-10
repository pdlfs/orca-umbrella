#
# libbacktrace.cmake  umbrella for libbacktrace (stack trace library)
# 09-Mar-2026  ankushj@andrew.cmu.edu
#

#
# config:
#  LIBBACKTRACE_REPO - url of git repository
#  LIBBACKTRACE_TAG  - tag to checkout of git
#  LIBBACKTRACE_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET libbacktrace)

#
# umbrella option variables
#
umbrella_defineopt (LIBBACKTRACE_REPO
     "https://github.com/ianlancetaylor/libbacktrace.git"
     STRING "libbacktrace GIT repository")
umbrella_defineopt (LIBBACKTRACE_TAG "master"
     STRING "libbacktrace GIT tag")
umbrella_defineopt (LIBBACKTRACE_TAR "libbacktrace-${LIBBACKTRACE_TAG}.tar.gz"
     STRING "libbacktrace cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (LIBBACKTRACE_DOWNLOAD libbacktrace ${LIBBACKTRACE_TAR}
                   GIT_REPOSITORY ${LIBBACKTRACE_REPO}
                   GIT_TAG ${LIBBACKTRACE_TAG})
umbrella_patchcheck (LIBBACKTRACE_PATCHCMD libbacktrace)

#
# create libbacktrace target
#
ExternalProject_Add (libbacktrace ${LIBBACKTRACE_DOWNLOAD} ${LIBBACKTRACE_PATCHCMD}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure ${UMBRELLA_COMP}
                      ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      --enable-shared
                      --with-pic
    BUILD_COMMAND $(MAKE)
    INSTALL_COMMAND $(MAKE) install
    UPDATE_COMMAND "")

endif (NOT TARGET libbacktrace)
