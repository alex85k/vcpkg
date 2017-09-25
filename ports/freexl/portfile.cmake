# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freexl-1.0.4)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/freexl-1.0.4.tar.gz"
    FILENAME "freexl-1.0.4.tar.gz"
    SHA512 d72561f7b82e0281cb211fbf249e5e45411a7cdd009cfb58da3696f0a0341ea7df210883bfde794be28738486aeb4ffc67ec2c98fd2acde5280e246e204ce788
)
vcpkg_extract_source_archive(${ARCHIVE})

find_program(NMAKE nmake)

################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
message(STATUS "Options ${NMAKE_OPTIONS_REL}")

file(READ "${SOURCE_PATH}/makefile.vc" mkfile)
string(REPLACE "C:\\OSGeo4w" "${CURRENT_INSTALLED_DIR}" mkfile "${mkfile}")
file(WRITE "${SOURCE_PATH}/makefile2.vc" ${mkfile})

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile2.vc
    WORKING_DIRECTORY ${SOURCE_PATH}
    "${NMAKE_OPTIONS_REL}"
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")


# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/freexl RENAME copyright)
