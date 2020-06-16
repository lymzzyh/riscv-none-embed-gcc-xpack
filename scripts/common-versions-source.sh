# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build 
# scripts. As the name implies, it should contain only functions and 
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

function prepare_versions()
{

  APP_PREFIX_NANO="${INSTALL_FOLDER_PATH}/${APP_LC_NAME}-nano"

  # The \x2C is a comma in hex; without this trick the regular expression
  # that processes this string in the Makefile, silently fails and the 
  # bfdver.h file remains empty.
  BRANDING="${BRANDING}\x2C ${TARGET_BITS}-bit"

  CFLAGS_OPTIMIZATIONS_FOR_TARGET="-ffunction-sections -fdata-sections -O2"
  # Cannot use medlow with 64 bits, so all must be medany.
  CFLAGS_OPTIMIZATIONS_FOR_TARGET+=" -mcmodel=medany"

  BINUTILS_PROJECT_NAME="riscv-binutils-gdb"
  GCC_PROJECT_NAME="riscv-gcc"
  NEWLIB_PROJECT_NAME="riscv-newlib"
  GDB_PROJECT_NAME="riscv-binutils-gdb"

  # -----------------------------------------------------------------------------
  # Defaults. Must be present.

  MULTILIB_FLAGS=""

  BINUTILS_PATCH=""
  GDB_PATCH=""

  WITH_GDB_PY="y"
  WITH_GDB_PY3=""
  USE_PLATFORM_PYTHON=""
  USE_PLATFORM_PYTHON3=""
  PYTHON3_VERSION=""

  # -----------------------------------------------------------------------------

  # Redefine to "y" to create the LTO plugin links.
  FIX_LTO_PLUGIN=""
  if [ "${TARGET_PLATFORM}" == "darwin" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.0.so"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${TARGET_PLATFORM}" == "linux" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin.so.0.0.0"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin.so"
  elif [ "${TARGET_PLATFORM}" == "win32" ]
  then
    LTO_PLUGIN_ORIGINAL_NAME="liblto_plugin-0.dll"
    LTO_PLUGIN_BFD_PATH="lib/bfd-plugins/liblto_plugin-0.dll"
  fi

  FIX_LTO_PLUGIN="y"

  # -----------------------------------------------------------------------------

  README_OUT_FILE_NAME="README-${RELEASE_VERSION}.md"

  # In reverse chronological order.
  # Keep them in sync with https://github.com/sifive/freedom-tools/releases.
  if [[ "${RELEASE_VERSION}" =~ 8\.3\.0-* ]]
  then
    # This is similar to SiFive 2019.08.0 release.
    # https://github.com/sifive/freedom-tools/releases

    # Binutils 2.32 with SiFive CLIC patches
    # https://github.com/sifive/riscv-binutils-gdb/tree/03d23d58701bdd425c613b0be2d458bcde46912b

    # GCC 8.3.0 with SiFive CLIC patches
    # https://github.com/sifive/riscv-gcc/tree/e195042babe2dc30d9fabb88d336d8c8679b3702

    # Newlib 3.1.0 from SiFive branch
    # https://github.com/sifive/riscv-newlib/tree/0d24a86822a5ee73d6a6aa69e2a0118aa1e35204

    # GDB 8.3 from FSF gdb-8.3-release branch
    # riscv-gdb @ 9b40759 (11 May 2019)
    # https://sourceware.org/git/?p=binutils-gdb.git
    # git://sourceware.org/git/binutils-gdb.git


    # ---------------------------------------------------------------------------

    # Inspired from SiFive
    # MULTILIBS_GEN :=            rv32e-ilp32e--c rv32em-ilp32e--c rv32eac-ilp32e-- rv32emac-ilp32e-- rv32i-ilp32--c rv32im-ilp32--c rv32imf-ilp32f--c rv32iac-ilp32-- rv32imac-ilp32-- rv32imafc-ilp32f-rv32imafdc- rv32imafdc-ilp32d-- rv64i-lp64--c rv64im-lp64--c rv64imf-lp64f--c rv64iac-lp64-- rv64imac-lp64-- rv64imafc-lp64f-rv64imafdc- rv64imafdc-lp64d--

    # Minimal list, for tests only. Pass it via the environment.
    # GCC_MULTILIB=${GCC_MULTILIB:-"rv32imac-ilp32-- rv64imac-lp64--"}

    # New extended list, based on SiFive list.
    # Added: rv32imaf-ilp32f--
    GCC_MULTILIB=${GCC_MULTILIB:-"\
    rv32e-ilp32e--c \
    rv32ea-ilp32e--m \
    rv32em-ilp32e--c \
    rv32eac-ilp32e-- \
    rv32emac-ilp32e-- \
    rv32i-ilp32--c \
    rv32ia-ilp32--m \
    rv32im-ilp32--c \
    rv32if-ilp32f-rv32ifd-c \
    rv32iaf-ilp32f-rv32imaf,rv32iafc-d \
    rv32imf-ilp32f-rv32imfd-c \
    rv32imaf-ilp32f-- \
    rv32iac-ilp32-- \
    rv32imac-ilp32-- \
    rv32imafc-ilp32f-rv32imafdc- \
    rv32ifd-ilp32d--c \
    rv32imfd-ilp32d--c \
    rv32iafd-ilp32d-rv32imafd,rv32iafdc- \
    rv32imafdc-ilp32d-- \
    rv64i-lp64--c \
    rv64ia-lp64--m \
    rv64im-lp64--c \
    rv64if-lp64f-rv64ifd-c \
    rv64iaf-lp64f-rv64iafc-d \
    rv64imf-lp64f-rv64imfd-c \
    rv64imaf-lp64f-- \
    rv64iac-lp64-- \
    rv64imac-lp64-- \
    rv64imafc-lp64f-rv64imafdc- \
    rv64ifd-lp64d--m,c \
    rv64iafd-lp64d-rv64imafd,rv64iafdc- \
    rv64imafdc-lp64d-- \
    "}

    GCC_MULTILIB_FILE=${GCC_MULTILIB_FILE:-"t-elf-multilib"}

    # ---------------------------------------------------------------------------

    BINUTILS_VERSION="2.32"
    # From gcc/BASE_VER
    GCC_VERSION="8.3.0"
    # From newlib/configure, VERSION=
    NEWLIB_VERSION="3.1.0"
    # From gdb/VERSION.in
    GDB_VERSION="8.3"

    # ---------------------------------------------------------------------------

    if [ "${USE_GITS}" != "y" ]
    then

      # Be sure there is no `v`, it is added in the URL.
      GH_RELEASE="8.3.0-1.1"
      BINUTILS_GH_RELEASE=${BINUTILS_GH_RELEASE:-"${GH_RELEASE}"}
      GCC_GH_RELEASE=${GCC_GH_RELEASE:-"${GH_RELEASE}"}
      NEWLIB_GH_RELEASE=${NEWLIB_GH_RELEASE:-"${GH_RELEASE}"}
      # Same, with a `-gdb` suffix added.
      GDB_GH_RELEASE=${GDB_GH_RELEASE:-"${GH_RELEASE}-gdb"}

    else

      BINUTILS_GIT_BRANCH=${BINUTILS_GIT_BRANCH:-"sifive-binutils-2.32-xpack"}
      # 16 April 2019
      BINUTILS_GIT_COMMIT=${BINUTILS_GIT_COMMIT:-"03d23d58701bdd425c613b0be2d458bcde46912b"}

      GCC_GIT_BRANCH=${GCC_GIT_BRANCH:-"sifive-gcc-8.3.0-xpack"}
      GCC_GIT_COMMIT=${GCC_GIT_COMMIT:-"e195042babe2dc30d9fabb88d336d8c8679b3702"}

      NEWLIB_GIT_BRANCH=${NEWLIB_GIT_BRANCH:-"sifive-master-xpack"}
      NEWLIB_GIT_COMMIT=${NEWLIB_GIT_COMMIT:-"0d24a86822a5ee73d6a6aa69e2a0118aa1e35204"}

      GDB_SRC_FOLDER_NAME=${GDB_SRC_FOLDER_NAME:-"binutils-gdb.git"}
      GDB_GIT_BRANCH=${GDB_GIT_BRANCH:-"sifive-gdb-8.3-xpack"}
      GDB_GIT_COMMIT=${GDB_GIT_COMMIT:-"9b8cecd18313807ac0cc4d2b1871603279b94244"}

    fi
    
    # ---------------------------------------------------------------------------

    ZLIB_VERSION="1.2.8"
    GMP_VERSION="6.1.2"
    MPFR_VERSION="3.1.6"
    MPC_VERSION="1.0.3"
    ISL_VERSION="0.18"
    LIBELF_VERSION="0.8.13"
    EXPAT_VERSION="2.2.5"
    LIBICONV_VERSION="1.15"
    XZ_VERSION="5.2.3"

    PYTHON_WIN_VERSION="2.7.13"

    # GDB 8.3 with Python3 not yet functional on Windows.
    # GDB does not know the Python3 API when compiled with mingw.
    if [ "${TARGET_PLATFORM}" != "win32" ]
    then
      # checking for python3.7... no
      # configure: error: no usable python found at /Users/ilg/opt/xbb/bin/python3

      : # WITH_GDB_PY3="y" 
      : # PYTHON3_VERSION="3.7.2"
    fi

    if [ "${TARGET_PLATFORM}" == "darwin" ]
    then
      USE_PLATFORM_PYTHON="y"
    fi

    BINUTILS_PATCH="binutils-gdb-${BINUTILS_VERSION}.patch"
    GDB_PATCH="binutils-gdb-${BINUTILS_VERSION}.patch"

    # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 8\.2\.0-3\.* ]]
  then
    # This is similar to SiFive 2019.05.0 release.
    # https://github.com/sifive/freedom-tools/releases

    # Binutils 2.32 with SiFive CLIC patches
    # https://github.com/sifive/riscv-binutils-gdb/tree/164267155c96f91472a539ca78ac919993bc5b4e

    # GCC 8.2.0 with SiFive CLIC patches
    # https://github.com/sifive/riscv-gcc/tree/242abcaff697d0a1ea12dccc975465e1bfeb8331

    # GDB 8.3 from FSF gdb-8.3-release branch
    # riscv-gdb @ 9b40759 (11 May 2019)
    # https://sourceware.org/git/?p=binutils-gdb.git
    # git://sourceware.org/git/binutils-gdb.git

    # Newlib 3.0.0 from SiFive branch
    # https://github.com/sifive/riscv-newlib/tree/42c2e3fb9f557d59b76d1a64bb6fb32707ff4530

    # ---------------------------------------------------------------------------

    # Inspired from SiFive
    # MULTILIBS_GEN :=            rv32e-ilp32e--c rv32em-ilp32e--c rv32eac-ilp32e-- rv32emac-ilp32e-- rv32i-ilp32--c rv32im-ilp32--c rv32imf-ilp32f--c rv32iac-ilp32-- rv32imac-ilp32-- rv32imafc-ilp32f-rv32imafdc- rv32imafdc-ilp32d-- rv64i-lp64--c rv64im-lp64--c rv64imf-lp64f--c rv64iac-lp64-- rv64imac-lp64-- rv64imafc-lp64f-rv64imafdc- rv64imafdc-lp64d--

    # Minimal list, for tests only. Pass it via the environment.
    # GCC_MULTILIB=${GCC_MULTILIB:-"rv32imac-ilp32-- rv64imac-lp64--"}

    # New extended list, based on SiFive list.
    # Added: rv32imaf-ilp32f--
    GCC_MULTILIB=${GCC_MULTILIB:-"rv32e-ilp32e--c rv32em-ilp32e--c rv32eac-ilp32e-- rv32emac-ilp32e-- rv32i-ilp32--c rv32im-ilp32--c rv32imf-ilp32f--c rv32imaf-ilp32f-- rv32iac-ilp32-- rv32imac-ilp32-- rv32imafc-ilp32f-rv32imafdc- rv32imafdc-ilp32d-- rv64i-lp64--c rv64im-lp64--c rv64imf-lp64f--c rv64iac-lp64-- rv64imac-lp64-- rv64imafc-lp64f-rv64imafdc- rv64imafdc-lp64d--"}

    GCC_MULTILIB_FILE=${GCC_MULTILIB_FILE:-"t-elf-multilib"}

    # ---------------------------------------------------------------------------

    BINUTILS_VERSION="2.32"
    # From gcc/BASE_VER
    GCC_VERSION="8.2.0"
    # From newlib/configure, VERSION=
    NEWLIB_VERSION="3.0.0"
    # From gdb/VERSION.in
    GDB_VERSION="8.3"


    # ---------------------------------------------------------------------------

    if [ "${USE_GITS}" != "y" ]
    then

      # Be sure there is no `v`, it is added in the URL.
      GH_RELEASE="8.2.0-3.1"
      BINUTILS_GH_RELEASE=${BINUTILS_GH_RELEASE:-"${GH_RELEASE}"}
      GCC_GH_RELEASE=${GCC_GH_RELEASE:-"${GH_RELEASE}"}
      NEWLIB_GH_RELEASE=${NEWLIB_GH_RELEASE:-"${GH_RELEASE}"}
      # Same, with a `-gdb` suffix added.
      GDB_GH_RELEASE=${GDB_GH_RELEASE:-"${GH_RELEASE}-gdb"}

    else

      BINUTILS_GIT_BRANCH=${BINUTILS_GIT_BRANCH:-"sifive-binutils-2.32-xpack"}
      # 16 April 2019
      BINUTILS_GIT_COMMIT=${BINUTILS_GIT_COMMIT:-"82b51c7b5087ddb77988287cd7a2dd8921331bfd"}

      GCC_GIT_BRANCH=${GCC_GIT_BRANCH:-"sifive-gcc-8.2.0-xpack"}
      GCC_GIT_COMMIT=${GCC_GIT_COMMIT:-"0c7a874f0b6f452eeafde57731646e5f460187e4"}

      NEWLIB_GIT_BRANCH=${NEWLIB_GIT_BRANCH:-"sifive-newlib-3.0.0-xpack"}
      NEWLIB_GIT_COMMIT=${NEWLIB_GIT_COMMIT:-"1975c561730cbd4b93c491eaadeb6c3b01a89447"}

      GDB_SRC_FOLDER_NAME=${GDB_SRC_FOLDER_NAME:-"binutils-gdb.git"}
      GDB_GIT_BRANCH=${GDB_GIT_BRANCH:-"sifive-gdb-8.3-xpack"}
      GDB_GIT_COMMIT=${GDB_GIT_COMMIT:-"9b8cecd18313807ac0cc4d2b1871603279b94244"}

    fi
    
    # ---------------------------------------------------------------------------

    ZLIB_VERSION="1.2.8"
    GMP_VERSION="6.1.2"
    MPFR_VERSION="3.1.6"
    MPC_VERSION="1.0.3"
    ISL_VERSION="0.18"
    LIBELF_VERSION="0.8.13"
    EXPAT_VERSION="2.2.5"
    LIBICONV_VERSION="1.15"
    XZ_VERSION="5.2.3"

    PYTHON_WIN_VERSION="2.7.13"

    BINUTILS_PATCH="binutils-gdb-${BINUTILS_VERSION}.patch"
    GDB_PATCH="binutils-gdb-${BINUTILS_VERSION}.patch"

    # ---------------------------------------------------------------------------
  else
    echo "Unsupported version ${RELEASE_VERSION}."
    exit 1
  fi

  if [ "${USE_GITS}" != "y" ]
  then

    # ---------------------------------------------------------------------------

    BINUTILS_SRC_FOLDER_NAME=${BINUTILS_SRC_FOLDER_NAME:-"${BINUTILS_PROJECT_NAME}-${BINUTILS_GH_RELEASE}"}
    BINUTILS_ARCHIVE_NAME=${BINUTILS_ARCHIVE_NAME:-"${BINUTILS_SRC_FOLDER_NAME}.tar.gz"}

    BINUTILS_ARCHIVE_URL=${BINUTILS_ARCHIVE_URL:-"https://github.com/xpack-dev-tools/${BINUTILS_PROJECT_NAME}/archive/v${BINUTILS_GH_RELEASE}.tar.gz"}

    BINUTILS_GIT_URL=""

    # ---------------------------------------------------------------------------

    GCC_SRC_FOLDER_NAME=${GCC_SRC_FOLDER_NAME:-"${GCC_PROJECT_NAME}-${GCC_GH_RELEASE}"}
    GCC_ARCHIVE_NAME=${GCC_ARCHIVE_NAME:-"${GCC_SRC_FOLDER_NAME}.tar.gz"}

    GCC_ARCHIVE_URL=${GCC_ARCHIVE_URL:-"https://github.com/xpack-dev-tools/${GCC_PROJECT_NAME}/archive/v${GCC_GH_RELEASE}.tar.gz"}

    GCC_GIT_URL=""

    # ---------------------------------------------------------------------------

    NEWLIB_SRC_FOLDER_NAME=${NEWLIB_SRC_FOLDER_NAME:-"${NEWLIB_PROJECT_NAME}-${NEWLIB_GH_RELEASE}"}
    NEWLIB_ARCHIVE_NAME=${NEWLIB_ARCHIVE_NAME:-"${NEWLIB_SRC_FOLDER_NAME}.tar.gz"}

    NEWLIB_ARCHIVE_URL=${NEWLIB_ARCHIVE_URL:-"https://github.com/xpack-dev-tools/${NEWLIB_PROJECT_NAME}/archive/v${NEWLIB_GH_RELEASE}.tar.gz"}

    NEWLIB_GIT_URL=""

    # ---------------------------------------------------------------------------

    GDB_SRC_FOLDER_NAME=${GDB_SRC_FOLDER_NAME:-"${GDB_PROJECT_NAME}-${GDB_GH_RELEASE}"}
    GDB_ARCHIVE_NAME=${GDB_ARCHIVE_NAME:-"${GDB_SRC_FOLDER_NAME}.tar.gz"}

    GDB_ARCHIVE_URL=${GDB_ARCHIVE_URL:-"https://github.com/xpack-dev-tools/${GDB_PROJECT_NAME}/archive/v${GDB_GH_RELEASE}.tar.gz"}

    GDB_GIT_URL=""

    # ---------------------------------------------------------------------------
  else
    # ---------------------------------------------------------------------------

    BINUTILS_SRC_FOLDER_NAME=${BINUTILS_SRC_FOLDER_NAME:-"${BINUTILS_PROJECT_NAME}.git"}

    BINUTILS_GIT_URL=${BINUTILS_GIT_URL:-"https://github.com/xpack-dev-tools/${BINUTILS_PROJECT_NAME}.git"}

    BINUTILS_ARCHIVE_URL=""

    # ---------------------------------------------------------------------------

    GCC_SRC_FOLDER_NAME=${GCC_SRC_FOLDER_NAME:-"${GCC_PROJECT_NAME}.git"}

    GCC_GIT_URL=${GCC_GIT_URL:-"https://github.com/xpack-dev-tools/${GCC_PROJECT_NAME}.git"}

    GCC_ARCHIVE_URL=""

    # ---------------------------------------------------------------------------

    NEWLIB_SRC_FOLDER_NAME=${NEWLIB_SRC_FOLDER_NAME:-"${NEWLIB_PROJECT_NAME}.git"}
      
    NEWLIB_GIT_URL=${NEWLIB_GIT_URL:-"https://github.com/xpack-dev-tools/${NEWLIB_PROJECT_NAME}.git"}

    NEWLIB_ARCHIVE_URL=""

    # ---------------------------------------------------------------------------

    # Pre 8.x builds define it to reuse the binutils repo.
    GDB_SRC_FOLDER_NAME=${GDB_SRC_FOLDER_NAME:-"binutils-gdb.git"}

    GDB_GIT_URL=${GDB_GIT_URL:-"https://github.com/xpack-dev-tools/${GDB_PROJECT_NAME}.git"}

    GDB_ARCHIVE_URL=""

    # ---------------------------------------------------------------------------
  fi

  # -----------------------------------------------------------------------------

  BINUTILS_FOLDER_NAME="binutils-${BINUTILS_VERSION}"
  GCC_FOLDER_NAME="gcc-${GCC_VERSION}"
  NEWLIB_FOLDER_NAME="newlib-${NEWLIB_VERSION}"
  GDB_FOLDER_NAME="gdb-${GDB_VERSION}"

  # Note: The 5.x build failed with various messages.

  if [ "${WITHOUT_MULTILIB}" == "y" ]
  then
    MULTILIB_FLAGS="--disable-multilib"
  fi

  if [ "${TARGET_BITS}" == "32" ]
  then
    PYTHON_WIN=python-"${PYTHON_WIN_VERSION}"
  else
    PYTHON_WIN=python-"${PYTHON_WIN_VERSION}".amd64
  fi

  PYTHON_WIN_PACK="${PYTHON_WIN}".msi
  PYTHON_WIN_URL="https://www.python.org/ftp/python/${PYTHON_WIN_VERSION}/${PYTHON_WIN_PACK}"

  # -----------------------------------------------------------------------------

  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    # The Windows GDB needs some headers from the Python distribution.
    if [ "${WITH_GDB_PY}" == "y" ]
    then
      download_python_win
    fi

    if [ "${WITH_GDB_PY3}" == "y" ]
    then
      download_python3_win
    fi
  fi

  # -----------------------------------------------------------------------------
  # Build dependent libraries.

  # For better control, without it some components pick the lib packed 
  # inside the archive.
  build_zlib "${ZLIB_VERSION}"

  # The classical GCC libraries.
  build_gmp "${GMP_VERSION}"
  build_mpfr "${MPFR_VERSION}"
  build_mpc "${MPC_VERSION}"
  build_isl "${ISL_VERSION}"

  # More libraries.
  # Fails on mingw
  ## do_libelf
  build_expat "${EXPAT_VERSION}"
  build_libiconv "${LIBICONV_VERSION}"
  build_xz "${XZ_VERSION}"

  # -----------------------------------------------------------------------------

  # The task descriptions are from the ARM build script.

  # Task [III-0] /$HOST_NATIVE/binutils/
  # Task [IV-1] /$HOST_MINGW/binutils/
  do_binutils
  # copy_dir to libs included above

  if [ "${TARGET_PLATFORM}" != "win32" ]
  then

    # Task [III-1] /$HOST_NATIVE/gcc-first/
    do_gcc_first

    # Task [III-2] /$HOST_NATIVE/newlib/
    do_newlib ""
    # Task [III-3] /$HOST_NATIVE/newlib-nano/
    do_newlib "-nano"

    # Task [III-4] /$HOST_NATIVE/gcc-final/
    do_gcc_final ""

    # Task [III-5] /$HOST_NATIVE/gcc-size-libstdcxx/
    do_gcc_final "-nano"

  else

    # Task [IV-2] /$HOST_MINGW/copy_libs/
    copy_linux_libs

    # Task [IV-3] /$HOST_MINGW/gcc-final/
    do_gcc_final ""

  fi

  # Task [III-6] /$HOST_NATIVE/gdb/
  # Task [IV-4] /$HOST_MINGW/gdb/
  do_gdb ""
  if [ "${WITH_GDB_PY}" == "y" ]
  then
    do_gdb "-py"
  fi

  if [ "${WITH_GDB_PY3}" == "y" ]
  then
    do_gdb "-py3"
  fi

  # Task [III-7] /$HOST_NATIVE/build-manual
  # Nope, the build process is different.

  # -----------------------------------------------------------------------------

  # Task [III-8] /$HOST_NATIVE/pretidy/
  # Task [IV-5] /$HOST_MINGW/pretidy/
  tidy_up

  # Task [III-9] /$HOST_NATIVE/strip_host_objects/
  # Task [IV-6] /$HOST_MINGW/strip_host_objects/
  if [ "${WITH_STRIP}" == "y" ]
  then
    strip_binaries
  fi

  # Must be done after gcc 2 make install, otherwise some wrong links
  # are created in libexec.
  # Must also be done after strip binaries, since strip after patchelf
  # damages the binaries.
  prepare_app_folder_libraries

  if [ "${WITH_STRIP}" == "y" -a "${TARGET_PLATFORM}" != "win32" ]
  then
    # Task [III-10] /$HOST_NATIVE/strip_target_objects/
    strip_libs
  fi

  final_tunings

  # Task [IV-7] /$HOST_MINGW/installation/
  # Nope, no setup.exe.

  # Task [III-11] /$HOST_NATIVE/package_tbz2/
  # Task [IV-8] /Package toolchain in zip format/

  check_binaries

}

# -----------------------------------------------------------------------------
