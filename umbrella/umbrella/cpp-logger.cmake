#
# cpp-logger.cmake  umbrella for cpp-logger
# 18-Nov-2024  for DFTracer dependency
#

#
# config:
#  CPP_LOGGER_REPO - url of git repository
#  CPP_LOGGER_TAG  - tag to checkout of git
#  CPP_LOGGER_TAR  - cache tar file name (default should be ok)
#

if (NOT TARGET cpp-logger)

#
# umbrella option variables
#
umbrella_defineopt (CPP_LOGGER_REPO
                    "https://github.com/hariharan-devarajan/cpp-logger.git"
                    STRING "cpp-logger GIT repository")
umbrella_defineopt (CPP_LOGGER_TAG "v0.0.6" STRING "cpp-logger GIT tag")
umbrella_defineopt (CPP_LOGGER_TAR "cpp-logger-${CPP_LOGGER_TAG}.tar.gz"
                    STRING "cpp-logger cache tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (CPP_LOGGER_DOWNLOAD cpp-logger ${CPP_LOGGER_TAR}
                   GIT_REPOSITORY ${CPP_LOGGER_REPO}
                   GIT_TAG ${CPP_LOGGER_TAG})
umbrella_patchcheck (CPP_LOGGER_PATCHCMD cpp-logger)

#
# create cpp-logger target
#
ExternalProject_Add (cpp-logger
    ${CPP_LOGGER_DOWNLOAD} ${CPP_LOGGER_PATCHCMD}
    CMAKE_ARGS -DBUILD_SHARED_LIBS=ON
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET cpp-logger)
