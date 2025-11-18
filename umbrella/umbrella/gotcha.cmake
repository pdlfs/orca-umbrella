#
# gotcha.cmake  umbrella for LLNL GOTCHA library
# 18-Nov-2024  for Score-P dependency
#

#
# config:
#  GOTCHA_BASEURL - base url for downloading
#  GOTCHA_URLFILE - tar file name
#  GOTCHA_URLMD5  - md5 checksum of tar file
#

if (NOT TARGET gotcha)

#
# umbrella option variables
#
umbrella_defineopt (GOTCHA_BASEURL
                    "https://github.com/LLNL/GOTCHA/archive/refs/tags"
                    STRING "GOTCHA download URL base")
umbrella_defineopt (GOTCHA_URLFILE "1.0.8.tar.gz"
                    STRING "GOTCHA tar file")
umbrella_defineopt (GOTCHA_URLMD5 "42e0fe959d4ccf100f0856be74239f6f"
                    STRING "MD5 of tar file")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (GOTCHA_DOWNLOAD gotcha ${GOTCHA_URLFILE}
                   URL "${GOTCHA_BASEURL}/${GOTCHA_URLFILE}"
                   URL_MD5 ${GOTCHA_URLMD5})
umbrella_patchcheck (GOTCHA_PATCHCMD gotcha)

#
# create gotcha target
#
ExternalProject_Add (gotcha
    ${GOTCHA_DOWNLOAD} ${GOTCHA_PATCHCMD}
    CMAKE_ARGS -DBUILD_SHARED_LIBS=ON
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET gotcha)
