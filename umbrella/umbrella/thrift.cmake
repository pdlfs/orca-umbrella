#
# thrift.cmake  umbrella for thrift (Arrow dep)
# 2025-03-28  ankushj@andrew.cmu.edu
#

#
# config:
#  THRIFT_BASEURL - base url of thrift
#  THRIFT_URLDIR  - subdir in base where util-linux lives
#  THRIFT_URLFILE - tar file within urldir
#  THRIFT_URLMD5  - md5 of tar file
#

if (NOT TARGET thrift)

#
# umbrella option variables
#
umbrella_defineopt(THRIFT_BASEURL "https://github.com/apache/thrift"
                    STRING "thrift base url")
umbrella_defineopt(THRIFT_URLDIR "archive/refs/tags"
                    STRING "thrift url dir")
umbrella_defineopt(THRIFT_URLFILE "v0.22.0.tar.gz"
                    STRING "thrift url file")
umbrella_defineopt(THRIFT_URLMD5 "a91b02cfbbfd90c18c7621e8ea6fb234"
                    STRING "thrift url md5")

if (POLICY CMP0148)
  # Thrift throws some warnings without it
  cmake_policy(SET CMP0148 NEW)
endif (POLICY CMP0148)

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (THRIFT_DOWNLOAD thrift
                   ${THRIFT_URLFILE}
                   URL "${THRIFT_BASEURL}/${THRIFT_URLDIR}/${THRIFT_URLFILE}"
                   URL_MD5 ${THRIFT_URLMD5})
umbrella_patchcheck (THRIFT_PATCHCMD thrift)

# if CXX_STANDARD > 14, warn and set to 14 anyway
set (THRIFT_CXX_STANDARD ${UMBRELLA_CXX_STANDARD})

if (THRIFT_CXX_STANDARD GREATER 14)
  message (WARNING "Thrift: this version requires CXX_STD <= 14, overriding")
  set (THRIFT_CXX_STANDARD 14)
endif (THRIFT_CXX_STANDARD GREATER 14)

#
# configure flags for thrift
# - set fPIC for static linkage to arrow.so
#
set(THRIFT_CMAKE_ARGS
  -DBUILD_SHARED_LIBS=OFF
  -DBUILD_STATIC_LIBS=ON
  -DBUILD_TESTING=OFF
  -DBoost_NO_BOOST_CMAKE=ON
  -DBUILD_COMPILER=OFF
  -DBUILD_EXAMPLES=OFF
  -DBUILD_TUTORIALS=OFF
  -DCMAKE_DEBUG_POSTFIX=
  -DWITH_AS3=OFF
  -DWITH_CPP=ON
  -DWITH_C_GLIB=OFF
  -DWITH_JAVA=OFF
  -DWITH_JAVASCRIPT=OFF
  -DWITH_LIBEVENT=OFF
  -DWITH_NODEJS=OFF
  -DWITH_PYTHON=OFF
  -DWITH_QT5=OFF
  -DWITH_ZLIB=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
)

#
# set dependencies
#
set (THRIFT_DEPENDS boost)

#
# include dependency targets
#
include (umbrella/boost)

#
# create thrift target
#
ExternalProject_Add (thrift DEPENDS ${THRIFT_DEPENDS}
    ${THRIFT_DOWNLOAD} ${THRIFT_PATCHCMD}
    CMAKE_ARGS ${THRIFT_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    -DCMAKE_CXX_STANDARD:STRING=${THRIFT_CXX_STANDARD}
    UPDATE_COMMAND ""
)

endif (NOT TARGET thrift) 
