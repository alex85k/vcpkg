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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libspatialite-4.3.0a)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.gaia-gis.it/gaia-sins/libspatialite-4.3.0a.tar.gz"
    FILENAME "libspatialite-4.3.0a.tar.gz"
    SHA512 adfd63e8dde0f370b07e4e7bb557647d2bfb5549205b60bdcaaca69ff81298a3d885e7c1ca515ef56dd0aca152ae940df8b5dbcb65bb61ae0a9337499895c3c0
)
vcpkg_extract_source_archive(${ARCHIVE})

find_program(NMAKE nmake)


# Setup sqlite3 libraries + include path
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" SQLITE_INCLUDE_DIR)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/sqlite3.lib" SQLITE_LIBRARY_REL)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/sqlite3.lib" SQLITE_LIBRARY_DBG)

set(NMAKE_OPTIONS
    SQLITE_INC=-I${SQLITE_INCLUDE_DIR}
    MSVC_VER=1900
)

set(NMAKE_OPTIONS_REL
    "${NMAKE_OPTIONS}"
#    CXX_CRT_FLAGS=${LINKAGE_FLAGS}
#    PROJ_LIBRARY=${PROJ_LIBRARY_REL}
#    PNG_LIB=${PNG_LIBRARY_REL}
#    GEOS_LIB=${GEOS_LIBRARY_REL}
#    EXPAT_LIB=${EXPAT_LIBRARY_REL}
#    "CURL_LIB=${CURL_LIBRARY_REL} wsock32.lib wldap32.lib winmm.lib"
#    INSTDIR=${SQLITE_LIBRARY_REL}
#    MYSQL_LIB=${MYSQL_LIBRARY_REL}
#    PG_LIB=${PGSQL_LIBRARY_REL}
#    OPENJPEG_LIB=${OPENJPEG_LIBRARY_REL}
#    WEBP_LIBS=${WEBP_LIBRARY_REL}
#    LIBXML2_LIB=${XML2_LIBRARY_REL}
)


file(READ "${SOURCE_PATH}/makefile.vc" mkfile)
string(REPLACE "C:\\OSGeo4W" "${CURRENT_INSTALLED_DIR}" mkfile "${mkfile}")
string(REPLACE "C:\\OSGeo4w" "${CURRENT_INSTALLED_DIR}" mkfile "${mkfile}")
file(WRITE "${SOURCE_PATH}/makefile2.vc" ${mkfile})

file(READ "${SOURCE_PATH}/config-msvc.h" cffile)
string(REPLACE "#define HAVE_UNISTD_H 1" "#undef HAVE_UNISTD_H" cffile "${cffile}")
file(WRITE "${SOURCE_PATH}/config-msvc.h" ${cffile})

file(READ "${SOURCE_PATH}/src/gaiageo/gg_extras.c" ñfile)
string(REPLACE "rint (double" "oldrint (double" cfile "${cfile}")
file(WRITE "${SOURCE_PATH}/src/gaiageo/gg_extras.c" ${cfile})

################
# Release build
################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
message(STATUS "Options ${NMAKE_OPTIONS_REL}")

vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile2.vc
    WORKING_DIRECTORY ${SOURCE_PATH}
    "${NMAKE_OPTIONS_REL}"
    LOGNAME nmake-build-${TARGET_TRIPLET}-release
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")


################
# Debug build
################
#message(STATUS "Building ${TARGET_TRIPLET}-dbg")
#set(ENV{_LINK_} ${CURRENT_INSTALLED_DIR}/debug/lib/expat.lib)
#vcpkg_execute_required_process(
#    COMMAND ${NMAKE} -f makefile.vc ${NMAKE_OPTIONS_DBG}
#    WORKING_DIRECTORY ${SOURCE_PATH}/build/msw
#    LOGNAME nmake-build-${TARGET_TRIPLET}-debug
#)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

# Install headers and libraries
#file(INSTALL ${SOURCE_PATH}/include
#    DESTINATION ${CURRENT_PACKAGES_DIR})
#file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-rel/mswu/wx/setup.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/wx)
#file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-rel/mswu/wx/msw/rcdefs.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/wx/msw)
#file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-rel/
#    DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.lib" PATTERN "*.pdb")
#file(INSTALL ${SOURCE_PATH}/lib/${LIB_SUB_PATH}-dbg/
#    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.lib" PATTERN "*.pdb")
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/mswu ${CURRENT_PACKAGES_DIR}/debug/lib/mswud)
    
# Handle copyright
#file(COPY ${SOURCE_PATH}/docs/licence.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxwidgets)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/wxWidgets/licence.txt ${CURRENT_PACKAGES_DIR}/share/wxwidgets/copyright)
