#
# re2.cmake  umbrella for re2 (gRPC dep)
# 2025-03-28  ankushj@andrew.cmu.edu
#

#
# config:
#  RE2_BASEURL - base url of re2
#  RE2_URLDIR  - subdir in base where util-linux lives
#  RE2_URLFILE - tar file within urldir
#  RE2_URLMD5  - md5 of tar file
#

if (NOT TARGET re2)

#
# umbrella option variables
#
umbrella_defineopt (RE2_BASEURL "https://github.com/google/re2"
                    STRING "re2 base url")
umbrella_defineopt (RE2_URLDIR "archive/refs/tags"
                    STRING "re2 subdir")
umbrella_defineopt (RE2_URLFILE "2022-06-01.tar.gz"
                    STRING "re2 tar file")
umbrella_defineopt (RE2_URLMD5 "cb629f38da6b7234a9e9eba271ded5d6"
                    STRING "re2 tar md5")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (RE2_DOWNLOAD re2
                   ${RE2_URLFILE}
                   URL "${RE2_BASEURL}/${RE2_URLDIR}/${RE2_URLFILE}"
                   URL_MD5 ${RE2_URLMD5})
umbrella_patchcheck (RE2_PATCHCMD re2)

#
# configure flags for re2
# - set fPIC for static linkage to arrow.so
#
set(RE2_CMAKE_ARGS
  -DBUILD_TESTING=OFF
  -DRE2_BUILD_TESTING=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
)

#
# create re2 target
#
ExternalProject_Add (re2 DEPENDS ${RE2_DEPENDS}
    ${RE2_DOWNLOAD} ${RE2_PATCHCMD}
    CMAKE_ARGS ${RE2_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET re2) 
