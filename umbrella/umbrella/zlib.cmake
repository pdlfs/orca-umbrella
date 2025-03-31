#
# zlib.cmake  umbrella for zlib (gRPC dep)
# 2025-03-28  ankushj@andrew.cmu.edu
#

#
# config:
#  ZLIB_BASEURL - base url of zlib
#  ZLIB_URLDIR  - subdir in base where util-linux lives
#  ZLIB_URLFILE - tar file within urldir
#  ZLIB_URLMD5  - md5 of tar file
#

if (NOT TARGET zlib)

#
# umbrella option variables
#

umbrella_defineopt (ZLIB_BASEURL "https://github.com/madler/zlib/releases/download"
                    STRING "zlib base url")
umbrella_defineopt (ZLIB_URLDIR "v1.3.1"
                    STRING "zlib url dir")
umbrella_defineopt (ZLIB_URLFILE "zlib-1.3.1.tar.gz"
                    STRING "zlib url file")
umbrella_defineopt (ZLIB_URLMD5 "9855b6d802d7fe5b7bd5b196a2271655"
                    STRING "zlib url md5")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (ZLIB_DOWNLOAD zlib
                   ${ZLIB_URLFILE}
                   URL "${ZLIB_BASEURL}/${ZLIB_URLDIR}/${ZLIB_URLFILE}"
                   URL_MD5 ${ZLIB_URLMD5})
umbrella_patchcheck (ZLIB_PATCHCMD zlib)

#
# create zlib target
#
ExternalProject_Add (zlib DEPENDS ${ZLIB_DEPENDS}
    ${ZLIB_DOWNLOAD} ${ZLIB_PATCHCMD}
    CMAKE_ARGS ${ZLIB_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET zlib) 
