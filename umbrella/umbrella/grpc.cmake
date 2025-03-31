#
# grpc.cmake  umbrella for gRPC
# 2025-03-22  ankushj@andrew.cmu.edu
#

#
# config:
#  GRPC_BASEURL - base url of gRPC
#  GRPC_URLDIR  - subdir in base where util-linux lives
#  GRPC_URLFILE - tar file within urldir
#  GRPC_URLMD5  - md5 of tar file
#

if (NOT TARGET grpc)

#
# umbrella option variables
#
umbrella_defineopt (GRPC_BASEURL "https://github.com/grpc/grpc"
                    STRING "gRPC base url")
umbrella_defineopt (GRPC_URLDIR "archive/refs/tags"
                    STRING "gRPC url dir")
umbrella_defineopt (GRPC_URLFILE "v1.46.3.tar.gz"
                    STRING "gRPC url file")
umbrella_defineopt (GRPC_URLMD5 "fa4b4aa04ba22841b29ffe920f0b133f"
                    STRING "gRPC url md5")
#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (GRPC_DOWNLOAD grpc
                   ${GRPC_URLFILE}
                   URL "${GRPC_BASEURL}/${GRPC_URLDIR}/${GRPC_URLFILE}"
                   URL_MD5 ${GRPC_URLMD5})
umbrella_patchcheck (GRPC_PATCHCMD grpc)

#
# set dependencies
#
set (GRPC_DEPENDS abseil protobuf re2 zlib cares)

#
# configure flags for grpc
#
set(GRPC_CMAKE_ARGS
    -DgRPC_ABSL_PROVIDER=package
    -DgRPC_CARES_PROVIDER=package
    -DgRPC_PROTOBUF_PROVIDER=package
    -DgRPC_RE2_PROVIDER=package
    -DgRPC_SSL_PROVIDER=package
    -DgRPC_ZLIB_PROVIDER=package
    # fails on mac with SHARED_LIBS ON (https://github.com/grpc/grpc/issues/36654)
    # -DBUILD_SHARED_LIBS=OFF 
    -DgRPC_BUILD_CODEGEN=ON
    -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON
    -DgRPC_BUILD_GRPC_CSHARP_EXT=OFF
    -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF
    -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF
    -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF
    -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF
    -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF
    -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF
)

#
# include dependency targets
#
include (umbrella/abseil)
include (umbrella/protobuf)
include (umbrella/re2)
include (umbrella/zlib)
include (umbrella/cares)

#
# create grpc target
#
ExternalProject_Add (grpc DEPENDS ${GRPC_DEPENDS}
    ${GRPC_DOWNLOAD} ${GRPC_PATCHCMD}
    CMAKE_ARGS ${GRPC_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET grpc)