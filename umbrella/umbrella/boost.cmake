#
# boost.cmake  umbrella for the massive boost package
# 01-Oct-2017  chuck@ece.cmu.edu
#

#
# boost is big.  really big.  massive.  you really don't want
# to git clone this because it takes _forever_ to clone all
# the submodules.  let's just get a tar file, but be warned
# that even unpacking that is going to take ages.
#

#
# config:
#  BOOST_BASEURL - base url of boost
#  BOOST_URLDIR  - subdir in base where util-linux lives
#  BOOST_URLFILE - tar file within urldir
#  BOOST_URLMD5  - md5 of tar file
#

if (NOT TARGET boost)

#
# umbrella option variables
#
umbrella_defineopt (BOOST_BASEURL
    "https://archives.boost.io/release" STRING "base url for boost")
umbrella_defineopt (BOOST_URLDIR "1.74.0/source" STRING "boost subdir")
umbrella_defineopt (BOOST_URLFILE "boost_1_74_0.tar.gz"
    STRING "boost tar file name")
umbrella_defineopt (BOOST_SHA256
    "afff36d392885120bcac079148c177d1f6f7730ec3d47233aa51b0afa4db94a5"
    STRING "sha256sum of tar file")

#
# boost libraries to build, staged by consumer
# thrift/yaml-cpp: headers only, no compiled libs needed
#
set (_boost_libs "")

# dyninst
list(APPEND _boost_libs atomic chrono date_time filesystem thread timer)

list(REMOVE_DUPLICATES _boost_libs)
string(JOIN "," _boost_libs_str ${_boost_libs})

#
# generate parts of the ExternalProject_Add args...
#
umbrella_download (BOOST_DOWNLOAD boost ${BOOST_URLFILE}
    URL "${BOOST_BASEURL}/${BOOST_URLDIR}/${BOOST_URLFILE}"
    URL_HASH SHA256=${BOOST_SHA256})
umbrella_patchcheck (BOOST_PATCHCMD boost)

#
# create boost target
#
ExternalProject_Add (boost ${BOOST_DOWNLOAD} ${BOOST_PATCHCMD}
    CONFIGURE_COMMAND cd <SOURCE_DIR> &&
        env ${UMBRELLA_COMP} ${UMBRELLA_CPPFLAGS} ${UMBRELLA_LDFLAGS}
          ./bootstrap.sh --with-libraries=${_boost_libs_str}
                       --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND cd <SOURCE_DIR> &&
        ./b2 --prefix=${CMAKE_INSTALL_PREFIX} --build-dir=<BINARY_DIR> install
    INSTALL_COMMAND true
    UPDATE_COMMAND "")

endif (NOT TARGET boost)
