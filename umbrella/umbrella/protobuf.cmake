#
# protobuf.cmake  umbrella for protobuf
# 2025-03-22  ankushj@andrew.cmu.edu
#

#
# config:
#  PROTOBUF_BASEURL - base url of protobuf
#  PROTOBUF_URLDIR  - subdir in base where util-linux lives
#  PROTOBUF_URLFILE - tar file within urldir
#  PROTOBUF_URLMD5  - md5 of tar file
#

if (NOT TARGET protobuf)

#
# umbrella option variables
#
umbrella_defineopt (PROTOBUF_BASEURL "https://github.com/protocolbuffers/protobuf/releases/download"
                    STRING "protobuf base url")
umbrella_defineopt (PROTOBUF_URLDIR "v21.3"
                    STRING "protobuf url dir")
umbrella_defineopt (PROTOBUF_URLFILE "protobuf-all-21.3.tar.gz"
                    STRING "protobuf url file")
umbrella_defineopt (PROTOBUF_URLMD5 "92eb6e0a462a99f5fbdf92bac672a16d"
                    STRING "protobuf url md5")
#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (PROTOBUF_DOWNLOAD protobuf
                   ${PROTOBUF_URLFILE}
                   URL "${PROTOBUF_BASEURL}/${PROTOBUF_URLDIR}/${PROTOBUF_URLFILE}"
                   URL_MD5 ${PROTOBUF_URLMD5})
umbrella_patchcheck (PROTOBUF_PATCHCMD protobuf)

#   
# set dependencies
#
set (PROTOBUF_DEPENDS abseil)

#
# configure flags for protobuf
#
set(PROTOBUF_CMAKE_ARGS
    -DBUILD_TESTING=OFF
    -Dprotobuf_BUILD_TESTS=OFF
    -DCMAKE_CXX_STANDARD=14
    -DBUILD_GMOCK=OFF
    -Dprotobuf_BUILD_SHARED_LIBS=ON
    -Dprotobuf_BUILD_LIBPROTOC=ON
)

#
# include dependency targets
#
include (umbrella/abseil)

#
# create protobuf target
#
ExternalProject_Add (protobuf DEPENDS ${PROTOBUF_DEPENDS}
    ${PROTOBUF_DOWNLOAD} ${PROTOBUF_PATCHCMD}
    CMAKE_ARGS ${PROTOBUF_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET protobuf)
