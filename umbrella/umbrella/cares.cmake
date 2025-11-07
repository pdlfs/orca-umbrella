#
# cares.cmake  umbrella for cares (gRPC dep)
# 2025-03-28  ankushj@andrew.cmu.edu
#

#
# config:
#  CARES_BASEURL - base url of cares
#  CARES_URLDIR  - subdir in base where util-linux lives
#  CARES_URLFILE - tar file within urldir
#  CARES_URLMD5  - md5 of tar file
#

if (NOT TARGET cares)

#
# umbrella option variables
#
umbrella_defineopt (CARES_BASEURL "https://github.com/c-ares/c-ares"
                    STRING "cares base url")
umbrella_defineopt (CARES_URLDIR "releases/download/cares-1_21_0"
                    STRING "cares url dir")
umbrella_defineopt (CARES_URLFILE "c-ares-1.21.0.tar.gz"
                    STRING "cares url file")
umbrella_defineopt (CARES_URLMD5 "cf0808e65175571ef23d7c4a6d4673d6"
                    STRING "cares url md5")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (CARES_DOWNLOAD cares
                   ${CARES_URLFILE}
                   URL "${CARES_BASEURL}/${CARES_URLDIR}/${CARES_URLFILE}"
                   URL_MD5 ${CARES_URLMD5})
umbrella_patchcheck (CARES_PATCHCMD cares)

#
# create cares target
#
ExternalProject_Add (cares DEPENDS ${CARES_DEPENDS}
    ${CARES_DOWNLOAD} ${CARES_PATCHCMD}
    CMAKE_ARGS ${CARES_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET cares) 
