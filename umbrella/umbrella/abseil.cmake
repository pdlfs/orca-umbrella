#
# abseil.cmake  umbrella for Abseil (gRPC dep)
# 2025-03-28  ankushj@andrew.cmu.edu
#

#
# config:
#  ABSEIL_BASEURL - base url of abseil
#  ABSEIL_URLDIR  - subdir in base where util-linux lives
#  ABSEIL_TAG     - upstream release tag
#  ABSEIL_TAR     - local cache tar file
#  ABSEIL_URLMD5  - md5 of tar file
#

if (NOT TARGET abseil)

#
# umbrella option variables
#
umbrella_defineopt (ABSEIL_BASEURL "https://github.com/abseil/abseil-cpp"
                    STRING "Abseil base url")
umbrella_defineopt (ABSEIL_URLDIR "archive/refs/tags"
                    STRING "Abseil subdir")
umbrella_defineopt (ABSEIL_TAG "20220623.0"
                    STRING "Abseil release tag")
umbrella_defineopt (ABSEIL_TAR "abseil-${ABSEIL_TAG}.tar.gz"
                    STRING "Abseil cache tar file")
umbrella_defineopt (ABSEIL_URLMD5 "955b6faedf32ec2ce1b7725561d15618"
                    STRING "Abseil tar md5")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (ABSEIL_DOWNLOAD abseil
                   ${ABSEIL_TAR}
                   URL "${ABSEIL_BASEURL}/${ABSEIL_URLDIR}/${ABSEIL_TAG}.tar.gz"
                   URL_MD5 ${ABSEIL_URLMD5}
                   )
umbrella_patchcheck (ABSEIL_PATCHCMD abseil)

#
# configure flags for abseil
#
set(ABSEIL_CMAKE_ARGS
  -DBUILD_SHARED_LIBS=ON
  -DABSL_PROPAGATE_CXX_STD=ON
)

#
# create abseil target
#
ExternalProject_Add (abseil DEPENDS ${ABSEIL_DEPENDS}
    ${ABSEIL_DOWNLOAD} ${ABSEIL_PATCHCMD}
    CMAKE_ARGS ${ABSEIL_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET abseil) 
