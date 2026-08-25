#
# xsimd.cmake  umbrella for xsimd (arrow dep)
# 2025-08-31  shengj2@andrew.cmu.edu
#

#
# config:
#  XSIMD_BASEURL - base url of xsimd
#  XSIMD_URLDIR  - subdir in base where util-linux lives
#  XSIMD_TAG     - upstream release tag
#  XSIMD_TAR     - local cache tar file
#  XSIMD_URLMD5  - md5 of tar file
#

if (NOT TARGET xsimd)

#
# umbrella option variables
#

umbrella_defineopt (XSIMD_BASEURL "https://github.com/xtensor-stack/xsimd/archive/refs/tags/"
                    STRING "xsimd base url")
umbrella_defineopt (XSIMD_TAG "12.0.0"
                    STRING "xsimd release tag")
umbrella_defineopt (XSIMD_TAR "xsimd-${XSIMD_TAG}.tar.gz"
                    STRING "xsimd cache tar file")
umbrella_defineopt (XSIMD_URLMD5 "ca3977abe2cebd5acd0405e6a02277a1"
                    STRING "xsimd url md5")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (XSIMD_DOWNLOAD xsimd
                   ${XSIMD_TAR}
                   URL "${XSIMD_BASEURL}/${XSIMD_TAG}.tar.gz"
                   URL_MD5 ${XSIMD_URLMD5})
umbrella_patchcheck (XSIMD_PATCHCMD xsimd)

#
# create zlib target
#
ExternalProject_Add (xsimd DEPENDS ${XSIMD_DEPENDS}
    ${XSIMD_DOWNLOAD} ${XSIMD_PATCHCMD}
    CMAKE_ARGS ${XSIMD_CMAKE_ARGS}
    CMAKE_CACHE_ARGS ${UMBRELLA_CMAKECACHE}
    UPDATE_COMMAND ""
)

endif (NOT TARGET xsimd) 
