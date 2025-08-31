#
# xsimd.cmake  umbrella for xsimd (arrow dep)
# 2025-08-31  shengj2@andrew.cmu.edu
#

#
# config:
#  XSIMD_BASEURL - base url of xsimd
#  XSIMD_URLDIR  - subdir in base where util-linux lives
#  XSIMD_URLFILE - tar file within urldir
#  XSIMD_URLMD5  - md5 of tar file
#

if (NOT TARGET xsimd)

#
# umbrella option variables
#

umbrella_defineopt (XSIMD_BASEURL "https://github.com/xtensor-stack/xsimd/archive/refs/tags/"
                    STRING "xsimd base url")
umbrella_defineopt (XSIMD_URLFILE "11.0.0.tar.gz"
                    STRING "xsimd url file")
umbrella_defineopt (XSIMD_URLMD5 "8b734292633a5f931b7ffad028a53f58"
                    STRING "xsimd url md5")

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (XSIMD_DOWNLOAD xsimd
                   ${XSIMD_URLFILE}
                   URL "${XSIMD_BASEURL}/${XSIMD_URLFILE}"
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
