AC_DEFUN([GENERATE_BACKEND_CXX_COMPILER_SPECIFIC_HEADERS],
dnl DQ 12/17/2001 build from what Bobby put into configure.in directly 11/25/2001
dnl This builds the directories required for the back-end compiler specific header files.
dnl it depends upon the CHOOSE BACKEND COMPILER macro to have already been called.
[
 # BP : 11/20/2001, create a directory to store header files which are compiler specific
   compilerName="`basename $BACKEND_CXX_COMPILER`"
   chmod u+x "${srcdir}/config/create_system_headers"
   if test "$ROSE_CXX_HEADERS_DIR" = ""; then
      dnl AC_MSG_NOTICE([ROSE_CXX_HEADERS_DIR not set ...])
      ROSE_CXX_HEADERS_DIR="${prefix}/include/${compilerName}_HEADERS"
   else
      AC_MSG_NOTICE([ROSE_CXX_HEADERS_DIR set to: $ROSE_CXX_HEADERS_DIR])
   fi

   saveCurrentDirectory="`pwd`"
   cd "$srcdir"
   absolutePath_srcdir="`pwd`"
   cd "$saveCurrentDirectory"

 # DQ (9/1/2009): Output the absolute path
   echo "absolutePath_srcdir = ${absolutePath_srcdir}"

 # Use the full path name to generate the header from the correctly specified version of the backend compiler
   mkdir -p "./include-staging/${BACKEND_CXX_COMPILER}_HEADERS"
   "${srcdir}/config/create_system_headers" "${BACKEND_CXX_COMPILER}" "./include-staging/${BACKEND_CXX_COMPILER}_HEADERS" "${absolutePath_srcdir}"

   echo "BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER = $BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER"
   echo "BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER = $BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER"

 # DQ (8/14/2010): GNU 4.5 includes some code that will not compile and appears to not be valid C++ code.
 # We fixup a specific GNU 4.5 issues use of "return { __mask };"
   if test x$BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER == x4; then
      if test x$BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER == x5; then
         echo "Note: we have identified version 4.5 of GNU C/C++ which triggers use of a modified copy of iomanip header file."
         cp ${srcdir}/config/iomanip-gnu-4.5 ./include-staging/iomanip-gnu-4.5
         echo "remove the links..."
         rm ./include-staging/gcc_HEADERS/hdrs4/c++/4.5.0/iomanip;
         rm ./include-staging/g++_HEADERS/hdrs7/c++/4.5.0/iomanip;
         rm ./include-staging/g++_HEADERS/hdrs3/iomanip;
         echo "rebuild links to the modified file..."
         ln -s ./include-staging/iomanip-gnu-4.5 ./include-staging/gcc_HEADERS/hdrs4/c++/4.5.0/iomanip
         ln -s ./include-staging/iomanip-gnu-4.5 ./include-staging/g++_HEADERS/hdrs7/c++/4.5.0/iomanip
         ln -s ./include-staging/iomanip-gnu-4.5 ./include-staging/g++_HEADERS/hdrs3/iomanip
      fi
   fi

 # DQ (9/19/2010): Copy the upc.h header file from the config directory to our include-staging/${BACKEND_CXX_COMPILER}_HEADERS directory.
 # It might be that these should be put into a UPC specific subdirectory (so that the C compiler can't accedentally find them), but this should be discussed.
   echo "Copying UPC++ header files into ./include-staging/${BACKEND_CXX_COMPILER}_HEADERS directory ..."
   cp ${srcdir}/config/upc.h ./include-staging/${BACKEND_CXX_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_io.h ./include-staging/${BACKEND_CXX_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_relaxed.h ./include-staging/${BACKEND_CXX_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_strict.h ./include-staging/${BACKEND_CXX_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_collective.h ./include-staging/${BACKEND_CXX_COMPILER}_HEADERS
   cp ${srcdir}/config/bupc_extensions.h ./include-staging/${BACKEND_CXX_COMPILER}_HEADERS

   error_code=$?
   echo "error_code = $error_code"
   if test $error_code != 0; then
        echo "Error in copying of upc.h header file: nonzero exit code returned to caller error_code = $error_code"
        exit 1
   fi

 # echo "Exiting as a test in GENERATE BACKEND CXX COMPILER SPECIFIC HEADERS"
 # exit 1
])


AC_DEFUN([SETUP_BACKEND_CXX_COMPILER_SPECIFIC_REFERENCES],
dnl DQ 12/17/2001 build from what Bobby put into configure.in directly 11/25/2001
dnl This builds the directories required for the back-end compiler specific header files.
dnl it depends upon the CHOOSE BACKEND COMPILER macro to have already been called.
[
 # Now setup the include path that we will prepend to any user -I<dir> options so that the 
 # required compiler-specific header files can be found (these are often relocated versions 
 # of the compiler specific header files that have been processed so that EDG can read them)
 # It is unfortunate, but many compiler-specific files include compiler-specific code which
 # will not compile with a standard C++ compiler or can not be processed using a standard
 # C preprocessor (cpp) (an ugly fact of common compilers).

   chmod u+x "${srcdir}/$ROSE_HOME/config/dirincludes"


 #Mac OS X (and possibly other BSD-distros) does not support the echo -n option.
 #We need to detect this special case and use a "\c" in the end of the echo to not print a
 #newline.
   er=`echo -n ""`
   if test "X$er" = "X-n "
   then
     EC="\c"
     EO=""
   else
     EC=""
     EO="-n"
   fi

if test `expr index "$BACKEND_CXX_COMPILER" /` = "1"; then
	BACKEND_CXX_COMPILER_INSTALL_PATH=${BACKEND_CXX_COMPILER:1}
else
	BACKEND_CXX_COMPILER_INSTALL_PATH=${BACKEND_CXX_COMPILER}
fi

 # Include the directory with the subdirectories of header files
   if test "x$enable_new_edg_interface" = "xyes"; then
     includeString="{`${srcdir}/config/get_compiler_header_dirs ${BACKEND_CXX_COMPILER} | while read dir; do echo -n \\\"$dir\\\",\ ; done` \"/usr/include\"}"
   else
	includeString="{\"${BACKEND_CXX_COMPILER_INSTALL_PATH}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${BACKEND_CXX_COMPILER_INSTALL_PATH}_HEADERS"`, `${srcdir}/config/get_compiler_header_dirs ${BACKEND_CXX_COMPILER} | while read dir; do echo $EO \\\"$dir\\\",$EC\ ; done` \"/usr/include\"}"
   fi

   echo "includeString = $includeString"
   AC_DEFINE_UNQUOTED([CXX_INCLUDE_STRING],$includeString,[Include path for backend C++ compiler.])
])

AC_DEFUN([GENERATE_BACKEND_C_COMPILER_SPECIFIC_HEADERS],
[
   compilerName="`basename $BACKEND_C_COMPILER`"

   echo "C compilerName = ${compilerName}"

   chmod u+x "${srcdir}/config/create_system_headers"

   if test "$ROSE_C_HEADERS_DIR" = ""; then
      dnl AC_MSG_NOTICE([ROSE_C_HEADERS_DIR not set ...])
      ROSE_C_HEADERS_DIR="${compilerName}_HEADERS"
   else
      AC_MSG_NOTICE([ROSE_C_HEADERS_DIR set to: $ROSE_C_HEADERS_DIR])
   fi

   saveCurrentDirectory="`pwd`"
   cd "$srcdir"
   absolutePath_srcdir="`pwd`"
   cd "$saveCurrentDirectory"

 # DQ (9/1/2009): Output the absolute path
   echo "absolutePath_srcdir = ${absolutePath_srcdir}"

 # Use the full path name to generate the header from the correctly specified version of the backend compiler
   mkdir -p "./include-staging/${BACKEND_C_COMPILER}_HEADERS"
   "${srcdir}/config/create_system_headers" "${BACKEND_C_COMPILER}" "./include-staging/${BACKEND_C_COMPILER}_HEADERS" "${absolutePath_srcdir}"

   error_code=$?
   echo "error_code = $error_code"
   if test $error_code != 0; then
        echo "Error in ${srcdir}/config/create_system_headers: nonzero exit code returned to caller error_code = $error_code"
        exit 1
   fi

 # DQ (9/15/2010): Copy the upc.h header file from the config directory to our include-staging/${BACKEND_C_COMPILER}_HEADERS directory.
 # It might be that these should be put into a UPC specific subdirectory (so that the C compiler can't accedentally find them), but this should be discussed.
   echo "Copying UPC header files into ./include-staging/${BACKEND_C_COMPILER}_HEADERS directory ..."
   cp ${srcdir}/config/upc.h ./include-staging/${BACKEND_C_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_io.h ./include-staging/${BACKEND_C_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_relaxed.h ./include-staging/${BACKEND_C_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_strict.h ./include-staging/${BACKEND_C_COMPILER}_HEADERS
   cp ${srcdir}/config/upc_collective.h ./include-staging/${BACKEND_C_COMPILER}_HEADERS
   cp ${srcdir}/config/bupc_extensions.h ./include-staging/${BACKEND_C_COMPILER}_HEADERS

   error_code=$?
   echo "error_code = $error_code"
   if test $error_code != 0; then
        echo "Error in copying of upc.h header file: nonzero exit code returned to caller error_code = $error_code"
        exit 1
   fi
])


AC_DEFUN([SETUP_BACKEND_C_COMPILER_SPECIFIC_REFERENCES],
dnl DQ 12/17/2001 build from what Bobby put into configure.in directly 11/25/2001
dnl This builds the directories required for the back-end compiler specific header files.
dnl it depends upon the CHOOSE BACKEND COMPILER macro to have already been called.
[
 # Now setup the include path that we will prepend to any user -I<dir> options so that the 
 # required compiler-specific header files can be found (these are often relocated versions 
 # of the compiler specific header files that have been processed so that EDG can read them)
 # It is unfortunate, but many compiler-specific files include compiler-specific code which
 # will not compile with a standard C++ compiler or can not be processed using a standard
 # C preprocessor (cpp) (an ugly fact of common compilers).

   chmod u+x ${srcdir}/$ROSE_HOME/config/dirincludes

 #Mac OS X (and possibly other BSD-distros) does not support the echo -n option.
 #We need to detect this special case and use a "\c" in the end of the echo to not print a
 #newline.
   er=`echo -n ""`
   if test "X$er" = "X-n "
   then
     EC="\c"
     EO=""
   else
     EC=""
     EO="-n"
   fi

if test `expr index "$BACKEND_C_COMPILER" /` = "1"; then
  BACKEND_C_COMPILER_INSTALL_PATH=${BACKEND_C_COMPILER:1}
else
  BACKEND_C_COMPILER_INSTALL_PATH=${BACKEND_C_COMPILER}
fi

 # Include the directory with the subdirectories of header files
   if test "x$enable_new_edg_interface" = "xyes"; then
     includeString="{`${srcdir}/config/get_compiler_header_dirs ${BACKEND_C_COMPILER} | while read dir; do echo -n \\\"$dir\\\",\ ; done` \"/usr/include\"}"
   else
     includeString="{\"${BACKEND_C_COMPILER_INSTALL_PATH}_HEADERS\"`${srcdir}/$ROSE_HOME/config/dirincludes "./include-staging/" "${BACKEND_C_COMPILER_INSTALL_PATH}_HEADERS"`, `${srcdir}/config/get_compiler_header_dirs ${BACKEND_C_COMPILER} | while read dir; do echo $EO \\\"$dir\\\",$EC\ ; done` \"/usr/include\"}"
   fi

   echo "includeString = $includeString"
   AC_DEFINE_UNQUOTED([C_INCLUDE_STRING],$includeString,[Include path for backend C compiler.])
])

