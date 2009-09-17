AC_DEFUN([CHOOSE_BACKEND_COMPILER],
dnl Written by Dan Quinlan, 12/17/2001
dnl This macro selects the back-end C++ compiler to use to compile output 
dnl generated by preprocessors build using ROSE.  This macro needs to be called
dnl before the GET_COMPILER_SPECIFIC_DEFINES macro is called (so that defines 
dnl for the correct back-end C++ compiler are identified for use in preprocessors 
dnl build using ROSE)
[
# Make sure that we select a backend compiler before building the backend specific header files
# AC_BEFORE([CHOOSE_BACKEND_COMPILER],[GENERATE_BACKEND_COMPILER_SPECIFIC_HEADERS])
  AC_BEFORE([CHOOSE_BACKEND_COMPILER],[GENERATE_BACKEND_CXX_COMPILER_SPECIFIC_HEADERS])
  AC_ARG_WITH(alternate_backend_Cxx_compiler,
    [  --with-alternate_backend_Cxx_compiler=<compiler name>
                                Specify an alternative C++ back-end compiler],
    [
    # Use a different compiler for the backend than for the compilation of ROSE source code
      BACKEND_CXX_COMPILER=$with_alternate_backend_Cxx_compiler

      echo "alternative back-end C++ compiler specified for generated translators to use: $BACKEND_CXX_COMPILER"
    ] ,
    [ 
    # Alternatively use the specified C++ compiler
	   BACKEND_CXX_COMPILER="$CXX"
      echo "default back-end C++ compiler for generated translators to use: $BACKEND_CXX_COMPILER"
    ])

  AC_ARG_WITH(alternate_backend_C_compiler,
    [  --with-alternate_backend_C_compiler=<compiler name>
                                Specify an alternative C back-end compiler],
    [
    # Use a different compiler for the backend than for the compilation of ROSE source code
      BACKEND_C_COMPILER=$with_alternate_backend_C_compiler
      echo "alternative back-end C compiler specified for generated translators to use: $BACKEND_C_COMPILER"
    ] ,
    [ 
    # Alternatively use the specified C compiler
	   BACKEND_C_COMPILER="$CC"
      echo "default back-end C compiler for generated translators to use: $BACKEND_C_COMPILER"
    ])

# DQ (10/3/2008): Added option to specify backend fortran compiler
  AC_ARG_WITH(alternate_backend_fortran_compiler,
    [  --with-alternate_backend_fortran_compiler=<compiler name>
                                Specify an alternative fortran back-end compiler],
    [
    # Use a different compiler for the backend than for the compilation of ROSE source code
      BACKEND_FORTRAN_COMPILER=$with_alternate_backend_fortran_compiler
      echo "alternative back-end fortran compiler specified for generated translators to use: $BACKEND_FORTRAN_COMPILER"
    ] ,
    [ 
    # Alternatively use the specified fortran compiler
	 # BACKEND_FORTRAN_COMPILER="$FC"
	   BACKEND_FORTRAN_COMPILER="gfortran"
      echo "default back-end fortran compiler for generated translators to use: $BACKEND_FORTRAN_COMPILER"
    ])

# DQ (8/29/2005): Added support for version numbering of backend compiler
  BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER=`echo|$BACKEND_CXX_COMPILER -dumpversion | cut -d\. -f1`
  BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER=`echo|$BACKEND_CXX_COMPILER -dumpversion | cut -d\. -f2`

# echo "back-end compiler for generated translators to use will be: $BACKEND_CXX_COMPILER"
  echo "     C++ back-end compiler major version number = $BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER"
  echo "     C++ back-end compiler minor version number = $BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER"

# Use this to get the major and minor version numbers for gfortran (which maps --version to -dumpversion, unlike gcc and g++)
# gfortran --version | head -1 | cut -f2 -d\) | tr -d \  | cut -d\. -f2
# Or Jeremiah suggests the alternative:
# gfortran --version | sed -n '1s/.*) //;1p'
  echo "BACKEND_FORTRAN_COMPILER = $BACKEND_FORTRAN_COMPILER"

# Testing the 4.0.x compiler
# BACKEND_FORTRAN_COMPILER="/usr/apps/gcc/4.0.2/bin/gfortran"
# echo "BACKEND_FORTRAN_COMPILER = $BACKEND_FORTRAN_COMPILER"

# DQ (9/15/2009): Normally we expect a string such as "GNU Fortran 95 (GCC) 4.1.2", but 
# the GNU 4.0.x compiler's gfortran outputs a string such as "GNU Fortran 95 (GCC 4.0.2)"
# So for this case we detect it explicitly and fill in the values directly!
  BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER=`echo|$BACKEND_FORTRAN_COMPILER --version | head -1 | cut -f2 -d\) | tr -d \  | cut -d\. -f1`
  BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER=`echo|$BACKEND_FORTRAN_COMPILER --version | head -1 | cut -f2 -d\) | tr -d \  | cut -d\. -f2`

# Test if we computed the major and minor version numbers correctly...recompute if required
  if test x$BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER == x; then
    echo "Warning: BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER = $BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER (blank) so this is likely the GNU 4.0.x version (try again to get the version number)"
    BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER=`echo|$BACKEND_FORTRAN_COMPILER --version | head -1 | sed s/"GNU Fortran 95 (GCC "//g | cut -f1 -d \) | cut -d\. -f1`
    BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER=`echo|$BACKEND_FORTRAN_COMPILER --version | head -1 | sed s/"GNU Fortran 95 (GCC "//g | cut -f1 -d \) | cut -d\. -f2`
  fi

# echo "back-end compiler for generated translators to use will be: $BACKEND_CXX_COMPILER"
  echo "     Fortran back-end compiler major version number = $BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER"
  echo "     Fortran back-end compiler minor version number = $BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER"

# Test that we have correctly evaluated the major and minor versions numbers...
  if test x$BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER == x; then
    echo "Warning: Could not compute the MAJOR version number of $BACKEND_FORTRAN_COMPILER"
  # exit 1
  fi

  if test x$BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER == x; then
    echo "Warning: Could not compute the MINOR version number of $BACKEND_FORTRAN_COMPILER"
  # exit 1
  fi

# DQ (9/16/2009): GNU gfortran 4.0 has special problems so we avoid some tests where it fails.
  gfortran_version_4_0=no
  if test x$BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER == x; then
     if test x$BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER == x; then
        gfortran_version_4_0=yes
     fi
  fi
  AM_CONDITIONAL(ROSE_USING_GFORTRAN_VERSION_4_0, [test "x$gfortran_version_4_0" = "xyes"])

# DQ (9/17/2009): GNU gfortran 4.1 has special problems so we avoid some tests where it fails.
  gfortran_version_4_1=no
  if test x$BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER == x4; then
     if test x$BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER == x1; then
        gfortran_version_4_1=yes
     fi
  fi
  AM_CONDITIONAL(ROSE_USING_GFORTRAN_VERSION_4_1, [test "x$gfortran_version_4_1" = "xyes"])

# echo "Exiting after test of backend version number support ..."
# exit 1

# We use the name of the backend C++ compiler to generate a compiler name that will be used
# elsewhere (CXX_ID might be a better name to use, instead we use basename to strip the path).
# compilerName=`basename $BACKEND_CXX_COMPILER`
  COMPILER_NAME=`basename $BACKEND_CXX_COMPILER`
# echo "default back-end compiler for generated preprocessors will be: $BACKEND_CXX_COMPILER"
# export BACKEND_CXX_COMPILER
# AC_DEFINE_UNQUOTED([CXX_COMPILER_NAME],"$BACKEND_CXX_COMPILER",[Name of backend C++ compiler.])
# echo "default back-end compiler for generated preprocessors will be: $BACKEND_CXX_COMPILER compiler name = $compilerName"

# DQ (1/15/2007): This does not work, it seems that BACKEND_C_COMPILER must be a simple name not a compound name using an option!
# Specify any option that specific backend compiler require (e.g. -restrict)
  case $COMPILER_NAME in
    gcc|g++)
      ;;
    icc|icpc)
    # BACKEND_C_COMPILER="$BACKEND_C_COMPILER -restrict"
    # BACKEND_CXX_COMPILER="$BACKEND_CXX_COMPILER -restrict"
      ;;
    "KCC --c" | mpKCC|KCC)
      ;;
    cc|CC)
    ;;
  esac

  echo "After adding (required) options BACKEND_C_COMPILER   = $BACKEND_C_COMPILER"
  echo "After adding (required) options BACKEND_CXX_COMPILER = $BACKEND_CXX_COMPILER"

  echo "default back-end compiler for generated preprocessors will be: $BACKEND_CXX_COMPILER compiler name = $COMPILER_NAME"

# export BACKEND_CXX_COMPILER
# AC_DEFINE_UNQUOTED([CXX_COMPILER_NAME],"$BACKEND_CXX_COMPILER",[Name of backend C++ compiler.])

# This will be used to select options based on which backend compiler is used (g++, xlC, icc, etc.)
# we can't use the basename of the compiler to execute because it might be link using a non-standard name (e.g. mpig++-3.4.1)
  export COMPILER_NAME
  AC_DEFINE_UNQUOTED([BACKEND_CXX_COMPILER_NAME_WITHOUT_PATH],"$COMPILER_NAME",[Name of backend C++ compiler excluding path (used to select code generation options).])

# This will be called to execute the backend compiler (for C++)
  export BACKEND_CXX_COMPILER
  AC_DEFINE_UNQUOTED([BACKEND_CXX_COMPILER_NAME_WITH_PATH],"$BACKEND_CXX_COMPILER",[Name of backend C++ compiler including path (may or may not explicit include path; used to call backend).])

# This will be called to execute the backend compiler (for C)
  export BACKEND_C_COMPILER
  AC_DEFINE_UNQUOTED([BACKEND_C_COMPILER_NAME_WITH_PATH],"$BACKEND_C_COMPILER",[Name of backend C compiler including path (may or may not explicit include path; used to call backend).])

# This will be called to execute the backend compiler (for C)
  export BACKEND_FORTRAN_COMPILER
  AC_DEFINE_UNQUOTED([BACKEND_FORTRAN_COMPILER_NAME_WITH_PATH],"$BACKEND_FORTRAN_COMPILER",[Name of backend Fortran compiler including path (may or may not explicit include path; used to call backend).])

# These are useful in handling differences between different versions of the backend compiler
# we assume that the C and C++ compiler version number match and only record version information 
# for the backend C++ compiler. (for example, this helps us generated different code for 
# g++ 3.3.x and 3.4.x backend compilers).
  export BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER
  AC_DEFINE_UNQUOTED([BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER],$BACKEND_CXX_COMPILER_MAJOR_VERSION_NUMBER,[Major version number of backend C++ compiler.])
  export BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER
  AC_DEFINE_UNQUOTED([BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER],$BACKEND_CXX_COMPILER_MINOR_VERSION_NUMBER,[Minor version number of backend C++ compiler.])

  export BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER
  AC_DEFINE_UNQUOTED([BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER],$BACKEND_FORTRAN_COMPILER_MAJOR_VERSION_NUMBER,[Major version number of backend Fortran compiler.])
  export BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER
  AC_DEFINE_UNQUOTED([BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER],$BACKEND_FORTRAN_COMPILER_MINOR_VERSION_NUMBER,[Minor version number of backend Fortran compiler.])
])

