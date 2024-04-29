dnl $XTermId: aclocal.m4,v 1.10 2024/03/30 00:08:49 tom Exp $
dnl
dnl ---------------------------------------------------------------------------
dnl
dnl Copyright 2015-2022,2024 by Thomas E. Dickey
dnl
dnl                         All Rights Reserved
dnl
dnl Permission is hereby granted, free of charge, to any person obtaining a
dnl copy of this software and associated documentation files (the
dnl "Software"), to deal in the Software without restriction, including
dnl without limitation the rights to use, copy, modify, merge, publish,
dnl distribute, sublicense, and/or sell copies of the Software, and to
dnl permit persons to whom the Software is furnished to do so, subject to
dnl the following conditions:
dnl
dnl The above copyright notice and this permission notice shall be included
dnl in all copies or substantial portions of the Software.
dnl
dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
dnl OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
dnl MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
dnl IN NO EVENT SHALL THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY
dnl CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
dnl TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
dnl SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
dnl
dnl Except as contained in this notice, the name(s) of the above copyright
dnl holders shall not be used in advertising or otherwise to promote the
dnl sale, use or other dealings in this Software without prior written
dnl authorization.
dnl
dnl ---------------------------------------------------------------------------
dnl See
dnl		https://invisible-island.net/autoconf/autoconf.html
dnl ---------------------------------------------------------------------------
dnl ---------------------------------------------------------------------------
dnl CF_ACVERSION_CHECK version: 5 updated: 2014/06/04 19:11:49
dnl ------------------
dnl Conditionally generate script according to whether we're using a given autoconf.
dnl
dnl $1 = version to compare against
dnl $2 = code to use if AC_ACVERSION is at least as high as $1.
dnl $3 = code to use if AC_ACVERSION is older than $1.
define([CF_ACVERSION_CHECK],
[
ifdef([AC_ACVERSION], ,[ifdef([AC_AUTOCONF_VERSION],[m4_copy([AC_AUTOCONF_VERSION],[AC_ACVERSION])],[m4_copy([m4_PACKAGE_VERSION],[AC_ACVERSION])])])dnl
ifdef([m4_version_compare],
[m4_if(m4_version_compare(m4_defn([AC_ACVERSION]), [$1]), -1, [$3], [$2])],
[CF_ACVERSION_COMPARE(
AC_PREREQ_CANON(AC_PREREQ_SPLIT([$1])),
AC_PREREQ_CANON(AC_PREREQ_SPLIT(AC_ACVERSION)), AC_ACVERSION, [$2], [$3])])])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ACVERSION_COMPARE version: 3 updated: 2012/10/03 18:39:53
dnl --------------------
dnl CF_ACVERSION_COMPARE(MAJOR1, MINOR1, TERNARY1,
dnl                      MAJOR2, MINOR2, TERNARY2,
dnl                      PRINTABLE2, not FOUND, FOUND)
define([CF_ACVERSION_COMPARE],
[ifelse(builtin([eval], [$2 < $5]), 1,
[ifelse([$8], , ,[$8])],
[ifelse([$9], , ,[$9])])])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_CFLAGS version: 15 updated: 2020/12/31 10:54:15
dnl -------------
dnl Copy non-preprocessor flags to $CFLAGS, preprocessor flags to $CPPFLAGS
dnl $1 = flags to add
dnl $2 = if given makes this macro verbose.
dnl
dnl Put any preprocessor definitions that use quoted strings in $EXTRA_CPPFLAGS,
dnl to simplify use of $CPPFLAGS in compiler checks, etc., that are easily
dnl confused by the quotes (which require backslashes to keep them usable).
AC_DEFUN([CF_ADD_CFLAGS],
[
cf_fix_cppflags=no
cf_new_cflags=
cf_new_cppflags=
cf_new_extra_cppflags=

for cf_add_cflags in $1
do
case "$cf_fix_cppflags" in
(no)
	case "$cf_add_cflags" in
	(-undef|-nostdinc*|-I*|-D*|-U*|-E|-P|-C)
		case "$cf_add_cflags" in
		(-D*)
			cf_tst_cflags=`echo "${cf_add_cflags}" |sed -e 's/^-D[[^=]]*='\''\"[[^"]]*//'`

			test "x${cf_add_cflags}" != "x${cf_tst_cflags}" \
				&& test -z "${cf_tst_cflags}" \
				&& cf_fix_cppflags=yes

			if test "$cf_fix_cppflags" = yes ; then
				CF_APPEND_TEXT(cf_new_extra_cppflags,$cf_add_cflags)
				continue
			elif test "${cf_tst_cflags}" = "\"'" ; then
				CF_APPEND_TEXT(cf_new_extra_cppflags,$cf_add_cflags)
				continue
			fi
			;;
		esac
		case "$CPPFLAGS" in
		(*$cf_add_cflags)
			;;
		(*)
			case "$cf_add_cflags" in
			(-D*)
				cf_tst_cppflags=`echo "x$cf_add_cflags" | sed -e 's/^...//' -e 's/=.*//'`
				CF_REMOVE_DEFINE(CPPFLAGS,$CPPFLAGS,$cf_tst_cppflags)
				;;
			esac
			CF_APPEND_TEXT(cf_new_cppflags,$cf_add_cflags)
			;;
		esac
		;;
	(*)
		CF_APPEND_TEXT(cf_new_cflags,$cf_add_cflags)
		;;
	esac
	;;
(yes)
	CF_APPEND_TEXT(cf_new_extra_cppflags,$cf_add_cflags)

	cf_tst_cflags=`echo "${cf_add_cflags}" |sed -e 's/^[[^"]]*"'\''//'`

	test "x${cf_add_cflags}" != "x${cf_tst_cflags}" \
		&& test -z "${cf_tst_cflags}" \
		&& cf_fix_cppflags=no
	;;
esac
done

if test -n "$cf_new_cflags" ; then
	ifelse([$2],,,[CF_VERBOSE(add to \$CFLAGS $cf_new_cflags)])
	CF_APPEND_TEXT(CFLAGS,$cf_new_cflags)
fi

if test -n "$cf_new_cppflags" ; then
	ifelse([$2],,,[CF_VERBOSE(add to \$CPPFLAGS $cf_new_cppflags)])
	CF_APPEND_TEXT(CPPFLAGS,$cf_new_cppflags)
fi

if test -n "$cf_new_extra_cppflags" ; then
	ifelse([$2],,,[CF_VERBOSE(add to \$EXTRA_CPPFLAGS $cf_new_extra_cppflags)])
	CF_APPEND_TEXT(EXTRA_CPPFLAGS,$cf_new_extra_cppflags)
fi

AC_SUBST(EXTRA_CPPFLAGS)

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_LIB version: 2 updated: 2010/06/02 05:03:05
dnl ----------
dnl Add a library, used to enforce consistency.
dnl
dnl $1 = library to add, without the "-l"
dnl $2 = variable to update (default $LIBS)
AC_DEFUN([CF_ADD_LIB],[CF_ADD_LIBS(-l$1,ifelse($2,,LIBS,[$2]))])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_LIBS version: 3 updated: 2019/11/02 16:47:33
dnl -----------
dnl Add one or more libraries, used to enforce consistency.  Libraries are
dnl prepended to an existing list, since their dependencies are assumed to
dnl already exist in the list.
dnl
dnl $1 = libraries to add, with the "-l", etc.
dnl $2 = variable to update (default $LIBS)
AC_DEFUN([CF_ADD_LIBS],[
cf_add_libs="[$]ifelse($2,,LIBS,[$2])"
# reverse order
cf_add_0lib=
for cf_add_1lib in $1; do cf_add_0lib="$cf_add_1lib $cf_add_0lib"; done
# filter duplicates
for cf_add_1lib in $cf_add_0lib; do
	for cf_add_2lib in $cf_add_libs; do
		if test "x$cf_add_1lib" = "x$cf_add_2lib"; then
			cf_add_1lib=
			break
		fi
	done
	test -n "$cf_add_1lib" && cf_add_libs="$cf_add_1lib $cf_add_libs"
done
ifelse($2,,LIBS,[$2])="$cf_add_libs"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ADD_LIB_AFTER version: 3 updated: 2013/07/09 21:27:22
dnl ----------------
dnl Add a given library after another, e.g., following the one it satisfies a
dnl dependency for.
dnl
dnl $1 = the first library
dnl $2 = its dependency
AC_DEFUN([CF_ADD_LIB_AFTER],[
CF_VERBOSE(...before $LIBS)
LIBS=`echo "$LIBS" | sed -e "s/[[ 	]][[ 	]]*/ /g" -e "s%$1 %$1 $2 %" -e 's%  % %g'`
CF_VERBOSE(...after  $LIBS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_APPEND_CFLAGS version: 3 updated: 2021/09/05 17:25:40
dnl ----------------
dnl Use CF_ADD_CFLAGS after first checking for potential redefinitions.
dnl $1 = flags to add
dnl $2 = if given makes this macro verbose.
define([CF_APPEND_CFLAGS],
[
for cf_add_cflags in $1
do
	case "x$cf_add_cflags" in
	(x-[[DU]]*)
		CF_REMOVE_CFLAGS($cf_add_cflags,CFLAGS,[$2])
		CF_REMOVE_CFLAGS($cf_add_cflags,CPPFLAGS,[$2])
		;;
	esac
	CF_ADD_CFLAGS([$cf_add_cflags],[$2])
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_APPEND_TEXT version: 1 updated: 2017/02/25 18:58:55
dnl --------------
dnl use this macro for appending text without introducing an extra blank at
dnl the beginning
define([CF_APPEND_TEXT],
[
	test -n "[$]$1" && $1="[$]$1 "
	$1="[$]{$1}$2"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ARG_DISABLE version: 3 updated: 1999/03/30 17:24:31
dnl --------------
dnl Allow user to disable a normally-on option.
AC_DEFUN([CF_ARG_DISABLE],
[CF_ARG_OPTION($1,[$2],[$3],[$4],yes)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ARG_ENABLE version: 3 updated: 1999/03/30 17:24:31
dnl -------------
dnl Allow user to enable a normally-off option.
AC_DEFUN([CF_ARG_ENABLE],
[CF_ARG_OPTION($1,[$2],[$3],[$4],no)])dnl
dnl ---------------------------------------------------------------------------
dnl CF_ARG_OPTION version: 5 updated: 2015/05/10 19:52:14
dnl -------------
dnl Restricted form of AC_ARG_ENABLE that ensures user doesn't give bogus
dnl values.
dnl
dnl Parameters:
dnl $1 = option name
dnl $2 = help-string
dnl $3 = action to perform if option is not default
dnl $4 = action if perform if option is default
dnl $5 = default option value (either 'yes' or 'no')
AC_DEFUN([CF_ARG_OPTION],
[AC_ARG_ENABLE([$1],[$2],[test "$enableval" != ifelse([$5],no,yes,no) && enableval=ifelse([$5],no,no,yes)
	if test "$enableval" != "$5" ; then
ifelse([$3],,[    :]dnl
,[    $3]) ifelse([$4],,,[
	else
		$4])
	fi],[enableval=$5 ifelse([$4],,,[
	$4
])dnl
])])dnl
dnl ---------------------------------------------------------------------------
dnl CF_C11_NORETURN version: 4 updated: 2023/02/18 17:41:25
dnl ---------------
AC_DEFUN([CF_C11_NORETURN],
[
AC_MSG_CHECKING(if you want to use C11 _Noreturn feature)
CF_ARG_ENABLE(stdnoreturn,
	[  --enable-stdnoreturn    enable C11 _Noreturn feature for diagnostics],
	[enable_stdnoreturn=yes],
	[enable_stdnoreturn=no])
AC_MSG_RESULT($enable_stdnoreturn)

if test $enable_stdnoreturn = yes; then
AC_CACHE_CHECK([for C11 _Noreturn feature], cf_cv_c11_noreturn,
	[AC_TRY_COMPILE([
$ac_includes_default
#include <stdnoreturn.h>
static _Noreturn void giveup(void) { exit(0); }
	],
	[if (feof(stdin)) giveup()],
	cf_cv_c11_noreturn=yes,
	cf_cv_c11_noreturn=no)
	])
else
	cf_cv_c11_noreturn=no,
fi

if test "$cf_cv_c11_noreturn" = yes; then
	AC_DEFINE(HAVE_STDNORETURN_H, 1,[Define if <stdnoreturn.h> header is available and working])
	AC_DEFINE_UNQUOTED(STDC_NORETURN,_Noreturn,[Define if C11 _Noreturn keyword is supported])
	HAVE_STDNORETURN_H=1
else
	HAVE_STDNORETURN_H=0
fi

AC_SUBST(HAVE_STDNORETURN_H)
AC_SUBST(STDC_NORETURN)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CC_ENV_FLAGS version: 11 updated: 2023/02/20 11:15:46
dnl ---------------
dnl Check for user's environment-breakage by stuffing CFLAGS/CPPFLAGS content
dnl into CC.  This will not help with broken scripts that wrap the compiler
dnl with options, but eliminates a more common category of user confusion.
dnl
dnl In particular, it addresses the problem of being able to run the C
dnl preprocessor in a consistent manner.
dnl
dnl Caveat: this also disallows blanks in the pathname for the compiler, but
dnl the nuisance of having inconsistent settings for compiler and preprocessor
dnl outweighs that limitation.
AC_DEFUN([CF_CC_ENV_FLAGS],
[
# This should have been defined by AC_PROG_CC
: "${CC:=cc}"

AC_MSG_CHECKING(\$CFLAGS variable)
case "x$CFLAGS" in
(*-[[IUD]]*)
	AC_MSG_RESULT(broken)
	AC_MSG_WARN(your environment uses the CFLAGS variable to hold CPPFLAGS options)
	cf_flags="$CFLAGS"
	CFLAGS=
	for cf_arg in $cf_flags
	do
		CF_ADD_CFLAGS($cf_arg)
	done
	;;
(*)
	AC_MSG_RESULT(ok)
	;;
esac

AC_MSG_CHECKING(\$CC variable)
case "$CC" in
(*[[\ \	]]-*)
	AC_MSG_RESULT(broken)
	AC_MSG_WARN(your environment uses the CC variable to hold CFLAGS/CPPFLAGS options)
	# humor him...
	cf_prog=`echo "$CC" | sed -e 's/	/ /g' -e 's/[[ ]]* / /g' -e 's/[[ ]]*[[ ]]-[[^ ]].*//'`
	cf_flags=`echo "$CC" | sed -e "s%^$cf_prog%%"`
	CC="$cf_prog"
	for cf_arg in $cf_flags
	do
		case "x$cf_arg" in
		(x-[[IUDfgOW]]*)
			CF_ADD_CFLAGS($cf_arg)
			;;
		(*)
			CC="$CC $cf_arg"
			;;
		esac
	done
	CF_VERBOSE(resulting CC: '$CC')
	CF_VERBOSE(resulting CFLAGS: '$CFLAGS')
	CF_VERBOSE(resulting CPPFLAGS: '$CPPFLAGS')
	;;
(*)
	AC_MSG_RESULT(ok)
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CHECK_CACHE version: 13 updated: 2020/12/31 10:54:15
dnl --------------
dnl Check if we're accidentally using a cache from a different machine.
dnl Derive the system name, as a check for reusing the autoconf cache.
dnl
dnl If we've packaged config.guess and config.sub, run that (since it does a
dnl better job than uname).  Normally we'll use AC_CANONICAL_HOST, but allow
dnl an extra parameter that we may override, e.g., for AC_CANONICAL_SYSTEM
dnl which is useful in cross-compiles.
dnl
dnl Note: we would use $ac_config_sub, but that is one of the places where
dnl autoconf 2.5x broke compatibility with autoconf 2.13
AC_DEFUN([CF_CHECK_CACHE],
[
if test -f "$srcdir/config.guess" || test -f "$ac_aux_dir/config.guess" ; then
	ifelse([$1],,[AC_CANONICAL_HOST],[$1])
	system_name="$host_os"
else
	system_name="`(uname -s -r) 2>/dev/null`"
	if test -z "$system_name" ; then
		system_name="`(hostname) 2>/dev/null`"
	fi
fi
test -n "$system_name" && AC_DEFINE_UNQUOTED(SYSTEM_NAME,"$system_name",[Define to the system name.])
AC_CACHE_VAL(cf_cv_system_name,[cf_cv_system_name="$system_name"])

test -z "$system_name" && system_name="$cf_cv_system_name"
test -n "$cf_cv_system_name" && AC_MSG_RESULT(Configuring for $cf_cv_system_name)

if test ".$system_name" != ".$cf_cv_system_name" ; then
	AC_MSG_RESULT(Cached system name ($system_name) does not agree with actual ($cf_cv_system_name))
	AC_MSG_ERROR("Please remove config.cache and try again.")
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CHECK_CFLAGS version: 4 updated: 2021/01/02 19:22:58
dnl ---------------
dnl Conditionally add to $CFLAGS and $CPPFLAGS values which are derived from
dnl a build-configuration such as imake.  These have the pitfall that they
dnl often contain compiler-specific options which we cannot use, mixed with
dnl preprocessor options that we usually can.
AC_DEFUN([CF_CHECK_CFLAGS],
[
CF_VERBOSE(checking additions to CFLAGS)
cf_check_cflags="$CFLAGS"
cf_check_cppflags="$CPPFLAGS"
CF_ADD_CFLAGS($1,yes)
if test "x$cf_check_cflags" != "x$CFLAGS" ; then
AC_TRY_LINK([#include <stdio.h>],[printf("Hello world");],,
	[CF_VERBOSE(test-compile failed.  Undoing change to \$CFLAGS)
	 if test "x$cf_check_cppflags" != "x$CPPFLAGS" ; then
		 CF_VERBOSE(but keeping change to \$CPPFLAGS)
	 fi
	 CFLAGS="$cf_check_cflags"])
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CHECK_LIBTOOL_VERSION version: 2 updated: 2021/05/01 16:24:34
dnl ------------------------
dnl Show the version of libtool
dnl
dnl Save the version in a cache variable - this is not entirely a good thing,
dnl but the version string from libtool is very ugly, and for bug reports it
dnl might be useful to have the original string.
dnl
dnl There is an imitation in OpenBSD, which has no apparent use other than to
dnl deny that it is GNU libtool.  Just ignore it.
AC_DEFUN([CF_CHECK_LIBTOOL_VERSION],[
if test -n "$LIBTOOL" && test "$LIBTOOL" != none
then
	AC_MSG_CHECKING(version of $LIBTOOL)
	CF_LIBTOOL_VERSION
	AC_MSG_RESULT($cf_cv_libtool_version)
	if test -n "$cf_cv_libtool_version"
	then
		cf_check_libtool_version=`$LIBTOOL --version 2>&1 | sed -e '/^$/d' -e 's,[[()]],...,g' -e 's,[[ ]],-,g' -e '2,$d'`
		case "x$cf_check_libtool_version" in
		(*...GNU-libtool...*)
			;;
		(*)
			AC_MSG_ERROR(This is not GNU libtool)
			;;
		esac
	else
		AC_MSG_ERROR(No version found for $LIBTOOL)
	fi
else
	AC_MSG_ERROR(GNU libtool has not been found)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_CLANG_COMPILER version: 9 updated: 2023/02/18 17:41:25
dnl -----------------
dnl Check if the given compiler is really clang.  clang's C driver defines
dnl __GNUC__ (fooling the configure script into setting $GCC to yes) but does
dnl not ignore some gcc options.
dnl
dnl This macro should be run "soon" after AC_PROG_CC or AC_PROG_CPLUSPLUS, to
dnl ensure that it is not mistaken for gcc/g++.  It is normally invoked from
dnl the wrappers for gcc and g++ warnings.
dnl
dnl $1 = GCC (default) or GXX
dnl $2 = CLANG_COMPILER (default)
dnl $3 = CFLAGS (default) or CXXFLAGS
AC_DEFUN([CF_CLANG_COMPILER],[
ifelse([$2],,CLANG_COMPILER,[$2])=no

if test "$ifelse([$1],,[$1],GCC)" = yes ; then
	AC_MSG_CHECKING(if this is really Clang ifelse([$1],GXX,C++,C) compiler)
	cf_save_CFLAGS="$ifelse([$3],,CFLAGS,[$3])"
	AC_TRY_COMPILE([],[
#ifdef __clang__
#else
#error __clang__ is not defined
#endif
],[ifelse([$2],,CLANG_COMPILER,[$2])=yes
],[])
	ifelse([$3],,CFLAGS,[$3])="$cf_save_CFLAGS"
	AC_MSG_RESULT($ifelse([$2],,CLANG_COMPILER,[$2]))
fi

CLANG_VERSION=none

if test "x$ifelse([$2],,CLANG_COMPILER,[$2])" = "xyes" ; then
	case "$CC" in
	(c[[1-9]][[0-9]]|*/c[[1-9]][[0-9]])
		AC_MSG_WARN(replacing broken compiler alias $CC)
		CFLAGS="$CFLAGS -std=`echo "$CC" | sed -e 's%.*/%%'`"
		CC=clang
		;;
	esac

	AC_MSG_CHECKING(version of $CC)
	CLANG_VERSION="`$CC --version 2>/dev/null | sed -e '2,$d' -e 's/^.*(CLANG[[^)]]*) //' -e 's/^.*(Debian[[^)]]*) //' -e 's/^[[^0-9.]]*//' -e 's/[[^0-9.]].*//'`"
	test -z "$CLANG_VERSION" && CLANG_VERSION=unknown
	AC_MSG_RESULT($CLANG_VERSION)

	for cf_clang_opt in \
		-Qunused-arguments \
		-Wno-error=implicit-function-declaration
	do
		AC_MSG_CHECKING(if option $cf_clang_opt works)
		cf_save_CFLAGS="$CFLAGS"
		CFLAGS="$CFLAGS $cf_clang_opt"
		AC_TRY_LINK([
			#include <stdio.h>],[
			printf("hello!\\n");],[
			cf_clang_optok=yes],[
			cf_clang_optok=no])
		AC_MSG_RESULT($cf_clang_optok)
		CFLAGS="$cf_save_CFLAGS"
		if test "$cf_clang_optok" = yes; then
			CF_VERBOSE(adding option $cf_clang_opt)
			CF_APPEND_TEXT(CFLAGS,$cf_clang_opt)
		fi
	done
fi
])
dnl ---------------------------------------------------------------------------
dnl CF_CONST_X_STRING version: 8 updated: 2023/12/01 17:22:50
dnl -----------------
dnl The X11R4-X11R6 Xt specification uses an ambiguous String type for most
dnl character-strings.
dnl
dnl It is ambiguous because the specification accommodated the pre-ANSI
dnl compilers bundled by more than one vendor in lieu of providing a standard C
dnl compiler other than by costly add-ons.  Because of this, the specification
dnl did not take into account the use of const for telling the compiler that
dnl string literals would be in readonly memory.
dnl
dnl As a workaround, one could (starting with X11R5) define XTSTRINGDEFINES, to
dnl let the compiler decide how to represent Xt's strings which were #define'd.
dnl That does not solve the problem of using the block of Xt's strings which
dnl are compiled into the library (and is less efficient than one might want).
dnl
dnl Xt specification 7 introduces the _CONST_X_STRING symbol which is used both
dnl when compiling the library and compiling using the library, to tell the
dnl compiler that String is const.
AC_DEFUN([CF_CONST_X_STRING],
[
AC_REQUIRE([AC_PATH_XTRA])

CF_SAVE_XTRA_FLAGS([CF_CONST_X_STRING])

AC_TRY_COMPILE(
[
#include <stdlib.h>
#include <X11/Intrinsic.h>
],
[String foo = malloc(1); free((void*)foo)],[

AC_CACHE_CHECK(for X11/Xt const-feature,cf_cv_const_x_string,[
	AC_TRY_COMPILE(
		[
#undef  _CONST_X_STRING
#define _CONST_X_STRING	/* X11R7.8 (perhaps) */
#undef  XTSTRINGDEFINES	/* X11R5 and later */
#include <stdlib.h>
#include <X11/Intrinsic.h>
		],[String foo = malloc(1); *foo = 0],[
			cf_cv_const_x_string=no
		],[
			cf_cv_const_x_string=yes
		])
])

CF_RESTORE_XTRA_FLAGS([CF_CONST_X_STRING])

case "$cf_cv_const_x_string" in
(no)
	CF_APPEND_TEXT(CPPFLAGS,-DXTSTRINGDEFINES)
	;;
(*)
	CF_APPEND_TEXT(CPPFLAGS,-D_CONST_X_STRING)
	;;
esac

])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_DISABLE_ECHO version: 14 updated: 2021/09/04 06:35:04
dnl ---------------
dnl You can always use "make -n" to see the actual options, but it is hard to
dnl pick out/analyze warning messages when the compile-line is long.
dnl
dnl Sets:
dnl	ECHO_LT - symbol to control if libtool is verbose
dnl	ECHO_LD - symbol to prefix "cc -o" lines
dnl	RULE_CC - symbol to put before implicit "cc -c" lines (e.g., .c.o)
dnl	SHOW_CC - symbol to put before explicit "cc -c" lines
dnl	ECHO_CC - symbol to put before any "cc" line
dnl
AC_DEFUN([CF_DISABLE_ECHO],[
AC_MSG_CHECKING(if you want to see long compiling messages)
CF_ARG_DISABLE(echo,
	[  --disable-echo          do not display "compiling" commands],
	[
	ECHO_LT='--silent'
	ECHO_LD='@echo linking [$]@;'
	RULE_CC='@echo compiling [$]<'
	SHOW_CC='@echo compiling [$]@'
	ECHO_CC='@'
],[
	ECHO_LT=''
	ECHO_LD=''
	RULE_CC=''
	SHOW_CC=''
	ECHO_CC=''
])
AC_MSG_RESULT($enableval)
AC_SUBST(ECHO_LT)
AC_SUBST(ECHO_LD)
AC_SUBST(RULE_CC)
AC_SUBST(SHOW_CC)
AC_SUBST(ECHO_CC)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_DISABLE_LEAKS version: 9 updated: 2021/04/03 16:41:50
dnl ----------------
dnl Combine no-leak checks with the libraries or tools that are used for the
dnl checks.
AC_DEFUN([CF_DISABLE_LEAKS],[

AC_REQUIRE([CF_WITH_DMALLOC])
AC_REQUIRE([CF_WITH_DBMALLOC])
AC_REQUIRE([CF_WITH_VALGRIND])

AC_MSG_CHECKING(if you want to perform memory-leak testing)
AC_ARG_ENABLE(leaks,
	[  --disable-leaks         test: free permanent memory, analyze leaks],
	[enable_leaks=$enableval],
	[enable_leaks=yes])
dnl with_no_leaks is more readable...
if test "x$enable_leaks" = xno; then with_no_leaks=yes; else with_no_leaks=no; fi
AC_MSG_RESULT($with_no_leaks)

if test "$enable_leaks" = no ; then
	AC_DEFINE(NO_LEAKS,1,[Define to 1 if you want to perform memory-leak testing.])
	AC_DEFINE(YY_NO_LEAKS,1,[Define to 1 if you want to perform memory-leak testing.])
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_DISABLE_LIBTOOL_VERSION version: 3 updated: 2015/04/17 21:13:04
dnl --------------------------
dnl Check if we should use the libtool 1.5 feature "-version-number" instead of
dnl the older "-version-info" feature.  The newer feature allows us to use
dnl version numbering on shared libraries which make them compatible with
dnl various systems.
AC_DEFUN([CF_DISABLE_LIBTOOL_VERSION],
[
AC_MSG_CHECKING(if libtool -version-number should be used)
CF_ARG_DISABLE(libtool-version,
	[  --disable-libtool-version  enable to use libtool's incompatible naming scheme],
	[cf_libtool_version=no],
	[cf_libtool_version=yes])
AC_MSG_RESULT($cf_libtool_version)

if test "$cf_libtool_version" = yes ; then
	LIBTOOL_VERSION="-version-number"
else
	LIBTOOL_VERSION="-version-info"
	case "x$VERSION" in
	(x)
		AC_MSG_WARN(VERSION was not set)
		;;
	(x*.*.*)
		ABI_VERSION="$VERSION"
		CF_VERBOSE(ABI_VERSION: $ABI_VERSION)
		;;
	(x*:*:*)
		ABI_VERSION=`echo "$VERSION" | sed -e 's/:/./g'`
		CF_VERBOSE(ABI_VERSION: $ABI_VERSION)
		;;
	(*)
		AC_MSG_WARN(unexpected VERSION value: $VERSION)
		;;
	esac
fi

AC_SUBST(ABI_VERSION)
AC_SUBST(LIBTOOL_VERSION)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_DISABLE_RPATH_HACK version: 3 updated: 2021/01/05 20:14:44
dnl ---------------------
dnl The rpath-hack makes it simpler to build programs, particularly with the
dnl *BSD ports which may have essential libraries in unusual places.  But it
dnl can interfere with building an executable for the base system.  Use this
dnl option in that case.
AC_DEFUN([CF_DISABLE_RPATH_HACK],
[
AC_MSG_CHECKING(if rpath-hack should be disabled)
CF_ARG_DISABLE(rpath-hack,
	[  --disable-rpath-hack    don't add rpath options for additional libraries],
	[enable_rpath_hack=no],
	[enable_rpath_hack=yes])
dnl TODO - drop cf_disable_rpath_hack
if test "x$enable_rpath_hack" = xno; then cf_disable_rpath_hack=yes; else cf_disable_rpath_hack=no; fi
AC_MSG_RESULT($cf_disable_rpath_hack)

if test "$enable_rpath_hack" = yes ; then
	CF_RPATH_HACK
fi
])
dnl ---------------------------------------------------------------------------
dnl CF_ENABLE_RPATH version: 2 updated: 2010/03/27 18:39:42
dnl ---------------
dnl Check if the rpath option should be used, setting cache variable
dnl cf_cv_enable_rpath if so.
AC_DEFUN([CF_ENABLE_RPATH],
[
AC_MSG_CHECKING(if rpath option should be used)
AC_ARG_ENABLE(rpath,
[  --enable-rpath          use rpath option when generating shared libraries],
[cf_cv_enable_rpath=$enableval],
[cf_cv_enable_rpath=no])
AC_MSG_RESULT($cf_cv_enable_rpath)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_FORGET_TOOL version: 1 updated: 2013/04/06 18:03:09
dnl --------------
dnl Forget that we saw the given tool.
AC_DEFUN([CF_FORGET_TOOL],[
unset ac_cv_prog_ac_ct_$1
unset ac_ct_$1
unset $1
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GCC_ATTRIBUTES version: 24 updated: 2021/03/20 12:00:25
dnl -----------------
dnl Test for availability of useful gcc __attribute__ directives to quiet
dnl compiler warnings.  Though useful, not all are supported -- and contrary
dnl to documentation, unrecognized directives cause older compilers to barf.
AC_DEFUN([CF_GCC_ATTRIBUTES],
[AC_REQUIRE([AC_PROG_FGREP])dnl
AC_REQUIRE([CF_C11_NORETURN])dnl

if test "$GCC" = yes || test "$GXX" = yes
then
cat > conftest.i <<EOF
#ifndef GCC_PRINTF
#define GCC_PRINTF 0
#endif
#ifndef GCC_SCANF
#define GCC_SCANF 0
#endif
#ifndef GCC_NORETURN
#define GCC_NORETURN /* nothing */
#endif
#ifndef GCC_UNUSED
#define GCC_UNUSED /* nothing */
#endif
EOF
if test "$GCC" = yes
then
	AC_CHECKING([for $CC __attribute__ directives])
cat > "conftest.$ac_ext" <<EOF
#line __oline__ "${as_me:-configure}"
#include <stdio.h>
#include "confdefs.h"
#include "conftest.h"
#include "conftest.i"
#if	GCC_PRINTF
#define GCC_PRINTFLIKE(fmt,var) __attribute__((format(printf,fmt,var)))
#else
#define GCC_PRINTFLIKE(fmt,var) /*nothing*/
#endif
#if	GCC_SCANF
#define GCC_SCANFLIKE(fmt,var)  __attribute__((format(scanf,fmt,var)))
#else
#define GCC_SCANFLIKE(fmt,var)  /*nothing*/
#endif
extern void wow(char *,...) GCC_SCANFLIKE(1,2);
extern GCC_NORETURN void oops(char *,...) GCC_PRINTFLIKE(1,2);
extern GCC_NORETURN void foo(void);
int main(int argc GCC_UNUSED, char *argv[[]] GCC_UNUSED) { (void)argc; (void)argv; return 0; }
EOF
	cf_printf_attribute=no
	cf_scanf_attribute=no
	for cf_attribute in scanf printf unused noreturn
	do
		CF_UPPER(cf_ATTRIBUTE,$cf_attribute)
		cf_directive="__attribute__(($cf_attribute))"
		echo "checking for $CC $cf_directive" 1>&AC_FD_CC

		case "$cf_attribute" in
		(printf)
			cf_printf_attribute=yes
			cat >conftest.h <<EOF
#define GCC_$cf_ATTRIBUTE 1
EOF
			;;
		(scanf)
			cf_scanf_attribute=yes
			cat >conftest.h <<EOF
#define GCC_$cf_ATTRIBUTE 1
EOF
			;;
		(*)
			cat >conftest.h <<EOF
#define GCC_$cf_ATTRIBUTE $cf_directive
EOF
			;;
		esac

		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... $cf_attribute)
			cat conftest.h >>confdefs.h
			case "$cf_attribute" in
			(noreturn)
				AC_DEFINE_UNQUOTED(GCC_NORETURN,$cf_directive,[Define to noreturn-attribute for gcc])
				;;
			(printf)
				cf_value='/* nothing */'
				if test "$cf_printf_attribute" != no ; then
					cf_value='__attribute__((format(printf,fmt,var)))'
					AC_DEFINE(GCC_PRINTF,1,[Define to 1 if the compiler supports gcc-like printf attribute.])
				fi
				AC_DEFINE_UNQUOTED(GCC_PRINTFLIKE(fmt,var),$cf_value,[Define to printf-attribute for gcc])
				;;
			(scanf)
				cf_value='/* nothing */'
				if test "$cf_scanf_attribute" != no ; then
					cf_value='__attribute__((format(scanf,fmt,var)))'
					AC_DEFINE(GCC_SCANF,1,[Define to 1 if the compiler supports gcc-like scanf attribute.])
				fi
				AC_DEFINE_UNQUOTED(GCC_SCANFLIKE(fmt,var),$cf_value,[Define to sscanf-attribute for gcc])
				;;
			(unused)
				AC_DEFINE_UNQUOTED(GCC_UNUSED,$cf_directive,[Define to unused-attribute for gcc])
				;;
			esac
		fi
	done
else
	${FGREP-fgrep} define conftest.i >>confdefs.h
fi
rm -rf ./conftest*
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GCC_VERSION version: 9 updated: 2023/03/05 14:30:13
dnl --------------
dnl Find version of gcc, and (because icc/clang pretend to be gcc without being
dnl compatible), attempt to determine if icc/clang is actually used.
AC_DEFUN([CF_GCC_VERSION],[
AC_REQUIRE([AC_PROG_CC])
GCC_VERSION=none
if test "$GCC" = yes ; then
	AC_MSG_CHECKING(version of $CC)
	GCC_VERSION="`${CC} --version 2>/dev/null | sed -e '2,$d' -e 's/^[[^(]]*([[^)]][[^)]]*) //' -e 's/^[[^0-9.]]*//' -e 's/[[^0-9.]].*//'`"
	test -z "$GCC_VERSION" && GCC_VERSION=unknown
	AC_MSG_RESULT($GCC_VERSION)
fi
CF_INTEL_COMPILER(GCC,INTEL_COMPILER,CFLAGS)
CF_CLANG_COMPILER(GCC,CLANG_COMPILER,CFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GCC_WARNINGS version: 41 updated: 2021/01/01 16:53:59
dnl ---------------
dnl Check if the compiler supports useful warning options.  There's a few that
dnl we don't use, simply because they're too noisy:
dnl
dnl	-Wconversion (useful in older versions of gcc, but not in gcc 2.7.x)
dnl	-Winline (usually not worthwhile)
dnl	-Wredundant-decls (system headers make this too noisy)
dnl	-Wtraditional (combines too many unrelated messages, only a few useful)
dnl	-Wwrite-strings (too noisy, but should review occasionally).  This
dnl		is enabled for ncurses using "--enable-const".
dnl	-pedantic
dnl
dnl Parameter:
dnl	$1 is an optional list of gcc warning flags that a particular
dnl		application might want to use, e.g., "no-unused" for
dnl		-Wno-unused
dnl Special:
dnl	If $with_ext_const is "yes", add a check for -Wwrite-strings
dnl
AC_DEFUN([CF_GCC_WARNINGS],
[
AC_REQUIRE([CF_GCC_VERSION])
if test "x$have_x" = xyes; then CF_CONST_X_STRING fi
cat > "conftest.$ac_ext" <<EOF
#line __oline__ "${as_me:-configure}"
int main(int argc, char *argv[[]]) { return (argv[[argc-1]] == 0) ; }
EOF
if test "$INTEL_COMPILER" = yes
then
# The "-wdXXX" options suppress warnings:
# remark #1419: external declaration in primary source file
# remark #1683: explicit conversion of a 64-bit integral type to a smaller integral type (potential portability problem)
# remark #1684: conversion from pointer to same-sized integral type (potential portability problem)
# remark #193: zero used for undefined preprocessing identifier
# remark #593: variable "curs_sb_left_arrow" was set but never used
# remark #810: conversion from "int" to "Dimension={unsigned short}" may lose significant bits
# remark #869: parameter "tw" was never referenced
# remark #981: operands are evaluated in unspecified order
# warning #279: controlling expression is constant

	AC_CHECKING([for $CC warning options])
	cf_save_CFLAGS="$CFLAGS"
	EXTRA_CFLAGS="$EXTRA_CFLAGS -Wall"
	for cf_opt in \
		wd1419 \
		wd1683 \
		wd1684 \
		wd193 \
		wd593 \
		wd279 \
		wd810 \
		wd869 \
		wd981
	do
		CFLAGS="$cf_save_CFLAGS $EXTRA_CFLAGS -$cf_opt"
		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... -$cf_opt)
			EXTRA_CFLAGS="$EXTRA_CFLAGS -$cf_opt"
		fi
	done
	CFLAGS="$cf_save_CFLAGS"
elif test "$GCC" = yes && test "$GCC_VERSION" != "unknown"
then
	AC_CHECKING([for $CC warning options])
	cf_save_CFLAGS="$CFLAGS"
	cf_warn_CONST=""
	test "$with_ext_const" = yes && cf_warn_CONST="Wwrite-strings"
	cf_gcc_warnings="Wignored-qualifiers Wlogical-op Wvarargs"
	test "x$CLANG_COMPILER" = xyes && cf_gcc_warnings=
	for cf_opt in W Wall \
		Wbad-function-cast \
		Wcast-align \
		Wcast-qual \
		Wdeclaration-after-statement \
		Wextra \
		Winline \
		Wmissing-declarations \
		Wmissing-prototypes \
		Wnested-externs \
		Wpointer-arith \
		Wshadow \
		Wstrict-prototypes \
		Wundef Wno-inline $cf_gcc_warnings $cf_warn_CONST $1
	do
		CFLAGS="$cf_save_CFLAGS $EXTRA_CFLAGS -$cf_opt"
		if AC_TRY_EVAL(ac_compile); then
			test -n "$verbose" && AC_MSG_RESULT(... -$cf_opt)
			case "$cf_opt" in
			(Winline)
				case "$GCC_VERSION" in
				([[34]].*)
					CF_VERBOSE(feature is broken in gcc $GCC_VERSION)
					continue;;
				esac
				;;
			(Wpointer-arith)
				case "$GCC_VERSION" in
				([[12]].*)
					CF_VERBOSE(feature is broken in gcc $GCC_VERSION)
					continue;;
				esac
				;;
			esac
			EXTRA_CFLAGS="$EXTRA_CFLAGS -$cf_opt"
		fi
	done
	CFLAGS="$cf_save_CFLAGS"
fi
rm -rf ./conftest*

AC_SUBST(EXTRA_CFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_GNU_SOURCE version: 10 updated: 2018/12/10 20:09:41
dnl -------------
dnl Check if we must define _GNU_SOURCE to get a reasonable value for
dnl _XOPEN_SOURCE, upon which many POSIX definitions depend.  This is a defect
dnl (or misfeature) of glibc2, which breaks portability of many applications,
dnl since it is interwoven with GNU extensions.
dnl
dnl Well, yes we could work around it...
dnl
dnl Parameters:
dnl	$1 is the nominal value for _XOPEN_SOURCE
AC_DEFUN([CF_GNU_SOURCE],
[
cf_gnu_xopen_source=ifelse($1,,500,$1)

AC_CACHE_CHECK(if this is the GNU C library,cf_cv_gnu_library,[
AC_TRY_COMPILE([#include <sys/types.h>],[
	#if __GLIBC__ > 0 && __GLIBC_MINOR__ >= 0
		return 0;
	#elif __NEWLIB__ > 0 && __NEWLIB_MINOR__ >= 0
		return 0;
	#else
	#	error not GNU C library
	#endif],
	[cf_cv_gnu_library=yes],
	[cf_cv_gnu_library=no])
])

if test x$cf_cv_gnu_library = xyes; then

	# With glibc 2.19 (13 years after this check was begun), _DEFAULT_SOURCE
	# was changed to help a little.  newlib incorporated the change about 4
	# years later.
	AC_CACHE_CHECK(if _DEFAULT_SOURCE can be used as a basis,cf_cv_gnu_library_219,[
		cf_save="$CPPFLAGS"
		CF_APPEND_TEXT(CPPFLAGS,-D_DEFAULT_SOURCE)
		AC_TRY_COMPILE([#include <sys/types.h>],[
			#if (__GLIBC__ == 2 && __GLIBC_MINOR__ >= 19) || (__GLIBC__ > 2)
				return 0;
			#elif (__NEWLIB__ == 2 && __NEWLIB_MINOR__ >= 4) || (__GLIBC__ > 3)
				return 0;
			#else
			#	error GNU C library __GLIBC__.__GLIBC_MINOR__ is too old
			#endif],
			[cf_cv_gnu_library_219=yes],
			[cf_cv_gnu_library_219=no])
		CPPFLAGS="$cf_save"
	])

	if test "x$cf_cv_gnu_library_219" = xyes; then
		cf_save="$CPPFLAGS"
		AC_CACHE_CHECK(if _XOPEN_SOURCE=$cf_gnu_xopen_source works with _DEFAULT_SOURCE,cf_cv_gnu_dftsrc_219,[
			CF_ADD_CFLAGS(-D_DEFAULT_SOURCE -D_XOPEN_SOURCE=$cf_gnu_xopen_source)
			AC_TRY_COMPILE([
				#include <limits.h>
				#include <sys/types.h>
				],[
				#if (_XOPEN_SOURCE >= $cf_gnu_xopen_source) && (MB_LEN_MAX > 1)
					return 0;
				#else
				#	error GNU C library is too old
				#endif],
				[cf_cv_gnu_dftsrc_219=yes],
				[cf_cv_gnu_dftsrc_219=no])
			])
		test "x$cf_cv_gnu_dftsrc_219" = "xyes" || CPPFLAGS="$cf_save"
	else
		cf_cv_gnu_dftsrc_219=maybe
	fi

	if test "x$cf_cv_gnu_dftsrc_219" != xyes; then

		AC_CACHE_CHECK(if we must define _GNU_SOURCE,cf_cv_gnu_source,[
		AC_TRY_COMPILE([#include <sys/types.h>],[
			#ifndef _XOPEN_SOURCE
			#error	expected _XOPEN_SOURCE to be defined
			#endif],
			[cf_cv_gnu_source=no],
			[cf_save="$CPPFLAGS"
			 CF_ADD_CFLAGS(-D_GNU_SOURCE)
			 AC_TRY_COMPILE([#include <sys/types.h>],[
				#ifdef _XOPEN_SOURCE
				#error	expected _XOPEN_SOURCE to be undefined
				#endif],
				[cf_cv_gnu_source=no],
				[cf_cv_gnu_source=yes])
			CPPFLAGS="$cf_save"
			])
		])

		if test "$cf_cv_gnu_source" = yes
		then
		AC_CACHE_CHECK(if we should also define _DEFAULT_SOURCE,cf_cv_default_source,[
			CF_APPEND_TEXT(CPPFLAGS,-D_GNU_SOURCE)
			AC_TRY_COMPILE([#include <sys/types.h>],[
				#ifdef _DEFAULT_SOURCE
				#error	expected _DEFAULT_SOURCE to be undefined
				#endif],
				[cf_cv_default_source=no],
				[cf_cv_default_source=yes])
			])
			if test "$cf_cv_default_source" = yes
			then
				CF_APPEND_TEXT(CPPFLAGS,-D_DEFAULT_SOURCE)
			fi
		fi
	fi

fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_HELP_MESSAGE version: 4 updated: 2019/12/31 08:53:54
dnl ---------------
dnl Insert text into the help-message, for readability, from AC_ARG_WITH.
AC_DEFUN([CF_HELP_MESSAGE],
[CF_ACVERSION_CHECK(2.53,[],[
AC_DIVERT_HELP($1)])dnl
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_INTEL_COMPILER version: 9 updated: 2023/02/18 17:41:25
dnl -----------------
dnl Check if the given compiler is really the Intel compiler for Linux.  It
dnl tries to imitate gcc, but does not return an error when it finds a mismatch
dnl between prototypes, e.g., as exercised by CF_MISSING_CHECK.
dnl
dnl This macro should be run "soon" after AC_PROG_CC or AC_PROG_CPLUSPLUS, to
dnl ensure that it is not mistaken for gcc/g++.  It is normally invoked from
dnl the wrappers for gcc and g++ warnings.
dnl
dnl $1 = GCC (default) or GXX
dnl $2 = INTEL_COMPILER (default) or INTEL_CPLUSPLUS
dnl $3 = CFLAGS (default) or CXXFLAGS
AC_DEFUN([CF_INTEL_COMPILER],[
AC_REQUIRE([AC_CANONICAL_HOST])
ifelse([$2],,INTEL_COMPILER,[$2])=no

if test "$ifelse([$1],,[$1],GCC)" = yes ; then
	case "$host_os" in
	(linux*|gnu*)
		AC_MSG_CHECKING(if this is really Intel ifelse([$1],GXX,C++,C) compiler)
		cf_save_CFLAGS="$ifelse([$3],,CFLAGS,[$3])"
		ifelse([$3],,CFLAGS,[$3])="$ifelse([$3],,CFLAGS,[$3]) -no-gcc"
		AC_TRY_COMPILE([],[
#ifdef __INTEL_COMPILER
#else
#error __INTEL_COMPILER is not defined
#endif
],[ifelse([$2],,INTEL_COMPILER,[$2])=yes
cf_save_CFLAGS="$cf_save_CFLAGS -we147"
],[])
		ifelse([$3],,CFLAGS,[$3])="$cf_save_CFLAGS"
		AC_MSG_RESULT($ifelse([$2],,INTEL_COMPILER,[$2]))
		;;
	esac
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_LD_RPATH_OPT version: 9 updated: 2021/01/01 13:31:04
dnl ---------------
dnl For the given system and compiler, find the compiler flags to pass to the
dnl loader to use the "rpath" feature.
AC_DEFUN([CF_LD_RPATH_OPT],
[
AC_REQUIRE([CF_CHECK_CACHE])

LD_RPATH_OPT=
if test "x$cf_cv_enable_rpath" != xno
then
	AC_MSG_CHECKING(for an rpath option)
	case "$cf_cv_system_name" in
	(irix*)
		if test "$GCC" = yes; then
			LD_RPATH_OPT="-Wl,-rpath,"
		else
			LD_RPATH_OPT="-rpath "
		fi
		;;
	(linux*|gnu*|k*bsd*-gnu|freebsd*)
		LD_RPATH_OPT="-Wl,-rpath,"
		;;
	(openbsd[[2-9]].*|mirbsd*)
		LD_RPATH_OPT="-Wl,-rpath,"
		;;
	(dragonfly*)
		LD_RPATH_OPT="-rpath "
		;;
	(netbsd*)
		LD_RPATH_OPT="-Wl,-rpath,"
		;;
	(osf*|mls+*)
		LD_RPATH_OPT="-rpath "
		;;
	(solaris2*)
		LD_RPATH_OPT="-R"
		;;
	(*)
		;;
	esac
	AC_MSG_RESULT($LD_RPATH_OPT)

	case "x$LD_RPATH_OPT" in
	(x-R*)
		AC_MSG_CHECKING(if we need a space after rpath option)
		cf_save_LIBS="$LIBS"
		CF_ADD_LIBS(${LD_RPATH_OPT}$libdir)
		AC_TRY_LINK(, , cf_rpath_space=no, cf_rpath_space=yes)
		LIBS="$cf_save_LIBS"
		AC_MSG_RESULT($cf_rpath_space)
		test "$cf_rpath_space" = yes && LD_RPATH_OPT="$LD_RPATH_OPT "
		;;
	esac
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_LIBTOOL_VERSION version: 1 updated: 2013/04/06 18:03:09
dnl ------------------
AC_DEFUN([CF_LIBTOOL_VERSION],[
if test -n "$LIBTOOL" && test "$LIBTOOL" != none
then
	cf_cv_libtool_version=`$LIBTOOL --version 2>&1 | sed -e '/^$/d' |sed -e '2,$d' -e 's/([[^)]]*)//g' -e 's/^[[^1-9]]*//' -e 's/[[^0-9.]].*//'`
else
	cf_cv_libtool_version=
fi
test -z "$cf_cv_libtool_version" && unset cf_cv_libtool_version
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_LIB_PREFIX version: 14 updated: 2021/01/01 13:31:04
dnl -------------
dnl Compute the library-prefix for the given host system
dnl $1 = variable to set
define([CF_LIB_PREFIX],
[
	case "$cf_cv_system_name" in
	(OS/2*|os2*)
		if test "$DFT_LWR_MODEL" = libtool; then
			LIB_PREFIX='lib'
		else
			LIB_PREFIX=''
		fi
		;;
	(*-msvc*)
		LIB_PREFIX=''
		;;
	(*)	LIB_PREFIX='lib'
		;;
	esac
ifelse($1,,,[$1=$LIB_PREFIX])
	AC_SUBST(LIB_PREFIX)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_LIB_SUFFIX version: 28 updated: 2021/01/01 16:53:59
dnl -------------
dnl Compute the library file-suffix from the given model name
dnl $1 = model name
dnl $2 = variable to set (the nominal library suffix)
dnl $3 = dependency variable to set (actual filename)
dnl The variable $LIB_SUFFIX, if set, prepends the variable to set.
AC_DEFUN([CF_LIB_SUFFIX],
[
	case X$1 in
	(Xlibtool)
		$2='.la'
		$3=[$]$2
		;;
	(Xdebug)
		case "$cf_cv_system_name" in
		(*-msvc*)
			$2='_g.lib'
			;;
		(*)
			$2='_g.a'
			;;
		esac
		$3=[$]$2
		;;
	(Xprofile)
		case "$cf_cv_system_name" in
		(*-msvc*)
			$2='_p.lib'
			;;
		(*)
			$2='_p.a'
			;;
		esac
		$3=[$]$2
		;;
	(Xshared)
		case "$cf_cv_system_name" in
		(aix[[5-7]]*)
			$2='.so'
			$3=[$]$2
			;;
		(*-msvc*)
			$2='.dll'
			$3='.dll.lib'
			;;
		(cygwin*|msys*|mingw*)
			$2='.dll'
			$3='.dll.a'
			;;
		(darwin*)
			$2='.dylib'
			$3=[$]$2
			;;
		(hpux*)
			case "$target" in
			(ia64*)
				$2='.so'
				$3=[$]$2
				;;
			(*)
				$2='.sl'
				$3=[$]$2
				;;
			esac
			;;
		(*)
			$2='.so'
			$3=[$]$2
			;;
		esac
		;;
	(*)
		case "$target" in
		(*-msvc*)
			$2='.lib'
			;;
		(*)
			$2='.a'
			;;
		esac
		$3=[$]$2
		;;
	esac
	if test -n "${LIB_SUFFIX}${EXTRA_SUFFIX}"
	then
		$2="${LIB_SUFFIX}${EXTRA_SUFFIX}[$]{$2}"
		$3="${LIB_SUFFIX}${EXTRA_SUFFIX}[$]{$3}"
	fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAKEFLAGS version: 21 updated: 2021/09/04 06:47:34
dnl ------------
dnl Some 'make' programs support ${MAKEFLAGS}, some ${MFLAGS}, to pass 'make'
dnl options to lower-levels.  It is very useful for "make -n" -- if we have it.
dnl (GNU 'make' does both, something POSIX 'make', which happens to make the
dnl ${MAKEFLAGS} variable incompatible because it adds the assignments :-)
AC_DEFUN([CF_MAKEFLAGS],
[AC_REQUIRE([AC_PROG_FGREP])dnl

AC_CACHE_CHECK(for makeflags variable, cf_cv_makeflags,[
	cf_cv_makeflags=''
	for cf_option in '-${MAKEFLAGS}' '${MFLAGS}'
	do
		cat >cf_makeflags.tmp <<CF_EOF
SHELL = $SHELL
all :
	@ echo '.$cf_option'
CF_EOF
		cf_result=`${MAKE:-make} -k -f cf_makeflags.tmp 2>/dev/null | ${FGREP-fgrep} -v "ing directory" | sed -e 's,[[ 	]]*$,,'`
		case "$cf_result" in
		(.*k|.*kw)
			cf_result="`${MAKE:-make} -k -f cf_makeflags.tmp CC=cc 2>/dev/null`"
			case "$cf_result" in
			(.*CC=*)	cf_cv_makeflags=
				;;
			(*)	cf_cv_makeflags=$cf_option
				;;
			esac
			break
			;;
		(.-)
			;;
		(*)
			CF_MSG_LOG(given option \"$cf_option\", no match \"$cf_result\")
			;;
		esac
	done
	rm -f cf_makeflags.tmp
])

AC_SUBST(cf_cv_makeflags)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MAKE_TAGS version: 6 updated: 2010/10/23 15:52:32
dnl ------------
dnl Generate tags/TAGS targets for makefiles.  Do not generate TAGS if we have
dnl a monocase filesystem.
AC_DEFUN([CF_MAKE_TAGS],[
AC_REQUIRE([CF_MIXEDCASE_FILENAMES])

AC_CHECK_PROGS(CTAGS, exctags ctags)
AC_CHECK_PROGS(ETAGS, exetags etags)

AC_CHECK_PROG(MAKE_LOWER_TAGS, ${CTAGS:-ctags}, yes, no)

if test "$cf_cv_mixedcase" = yes ; then
	AC_CHECK_PROG(MAKE_UPPER_TAGS, ${ETAGS:-etags}, yes, no)
else
	MAKE_UPPER_TAGS=no
fi

if test "$MAKE_UPPER_TAGS" = yes ; then
	MAKE_UPPER_TAGS=
else
	MAKE_UPPER_TAGS="#"
fi

if test "$MAKE_LOWER_TAGS" = yes ; then
	MAKE_LOWER_TAGS=
else
	MAKE_LOWER_TAGS="#"
fi

AC_SUBST(CTAGS)
AC_SUBST(ETAGS)

AC_SUBST(MAKE_UPPER_TAGS)
AC_SUBST(MAKE_LOWER_TAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MIXEDCASE_FILENAMES version: 9 updated: 2021/01/01 16:53:59
dnl ----------------------
dnl Check if the file-system supports mixed-case filenames.  If we're able to
dnl create a lowercase name and see it as uppercase, it doesn't support that.
AC_DEFUN([CF_MIXEDCASE_FILENAMES],
[
AC_CACHE_CHECK(if filesystem supports mixed-case filenames,cf_cv_mixedcase,[
if test "$cross_compiling" = yes ; then
	case "$target_alias" in
	(*-os2-emx*|*-msdosdjgpp*|*-cygwin*|*-msys*|*-mingw*|*-uwin*|darwin*)
		cf_cv_mixedcase=no
		;;
	(*)
		cf_cv_mixedcase=yes
		;;
	esac
else
	rm -f conftest CONFTEST
	echo test >conftest
	if test -f CONFTEST ; then
		cf_cv_mixedcase=no
	else
		cf_cv_mixedcase=yes
	fi
	rm -f conftest CONFTEST
fi
])
test "$cf_cv_mixedcase" = yes && AC_DEFINE(MIXEDCASE_FILENAMES,1,[Define to 1 if filesystem supports mixed-case filenames.])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_MSG_LOG version: 5 updated: 2010/10/23 15:52:32
dnl ----------
dnl Write a debug message to config.log, along with the line number in the
dnl configure script.
AC_DEFUN([CF_MSG_LOG],[
echo "${as_me:-configure}:__oline__: testing $* ..." 1>&AC_FD_CC
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NO_LEAKS_OPTION version: 9 updated: 2021/06/13 19:45:41
dnl ------------------
dnl see CF_WITH_NO_LEAKS
dnl
dnl $1 = option/name
dnl $2 = help-text
dnl $3 = symbol to define if the option is set
dnl $4 = additional actions to take if the option is set
AC_DEFUN([CF_NO_LEAKS_OPTION],[
AC_MSG_CHECKING(if you want to use $1 for testing)
AC_ARG_WITH($1,
	[$2],
	[case "x$withval" in
	(x|xno) ;;
	(*)
		: "${with_cflags:=-g}"
		: "${enable_leaks:=no}"
		with_$1=yes
		AC_DEFINE_UNQUOTED($3,1,"Define to 1 if you want to use $1 for testing.")ifelse([$4],,[
	 $4
])
		;;
	esac],
	[with_$1=])
AC_MSG_RESULT(${with_$1:-no})

case ".$with_cflags" in
(.*-g*)
	case .$CFLAGS in
	(.*-g*)
		;;
	(*)
		CF_ADD_CFLAGS([-g])
		;;
	esac
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_NUMBER_SYNTAX version: 3 updated: 2023/05/06 16:14:29
dnl ----------------
dnl Check if the given variable is a positive integer.  Report an error if not.
dnl $1 is the variable
dnl $2 is the message
AC_DEFUN([CF_NUMBER_SYNTAX],[
if test -n "$1" ; then
  case `echo "$1" | sed -e 's/^[[0-9]]*$/0/g'` in
  (0)
 	;;
  (*)
	AC_MSG_ERROR($2 is not a number: $1)
 	;;
  esac
else
  AC_MSG_ERROR($2 value is empty)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PATH_SYNTAX version: 18 updated: 2020/12/31 18:40:20
dnl --------------
dnl Check the argument to see that it looks like a pathname.  Rewrite it if it
dnl begins with one of the prefix/exec_prefix variables, and then again if the
dnl result begins with 'NONE'.  This is necessary to work around autoconf's
dnl delayed evaluation of those symbols.
AC_DEFUN([CF_PATH_SYNTAX],[
if test "x$prefix" != xNONE; then
	cf_path_syntax="$prefix"
else
	cf_path_syntax="$ac_default_prefix"
fi

case ".[$]$1" in
(.\[$]\(*\)*|.\'*\'*)
	;;
(..|./*|.\\*)
	;;
(.[[a-zA-Z]]:[[\\/]]*) # OS/2 EMX
	;;
(.\[$]\{*prefix\}*|.\[$]\{*dir\}*)
	eval $1="[$]$1"
	case ".[$]$1" in
	(.NONE/*)
		$1=`echo "[$]$1" | sed -e s%NONE%$cf_path_syntax%`
		;;
	esac
	;;
(.no|.NONE/*)
	$1=`echo "[$]$1" | sed -e s%NONE%$cf_path_syntax%`
	;;
(*)
	ifelse([$2],,[AC_MSG_ERROR([expected a pathname, not \"[$]$1\"])],$2)
	;;
esac
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PKG_CONFIG version: 13 updated: 2023/10/28 11:59:01
dnl -------------
dnl Check for the package-config program, unless disabled by command-line.
dnl
dnl Sets $PKG_CONFIG to the pathname of the pkg-config program.
AC_DEFUN([CF_PKG_CONFIG],
[
AC_MSG_CHECKING(if you want to use pkg-config)
AC_ARG_WITH(pkg-config,
	[[  --with-pkg-config[=CMD] enable/disable use of pkg-config and its name CMD]],
	[cf_pkg_config=$withval],
	[cf_pkg_config=yes])
AC_MSG_RESULT($cf_pkg_config)

case "$cf_pkg_config" in
(no)
	PKG_CONFIG=none
	;;
(yes)
	CF_ACVERSION_CHECK(2.52,
		[AC_PATH_TOOL(PKG_CONFIG, pkg-config, none)],
		[AC_PATH_PROG(PKG_CONFIG, pkg-config, none)])
	;;
(*)
	PKG_CONFIG=$withval
	;;
esac

test -z "$PKG_CONFIG" && PKG_CONFIG=none
if test "$PKG_CONFIG" != none ; then
	CF_PATH_SYNTAX(PKG_CONFIG)
elif test "x$cf_pkg_config" != xno ; then
	AC_MSG_WARN(pkg-config is not installed)
fi

AC_SUBST(PKG_CONFIG)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_POSIX_C_SOURCE version: 12 updated: 2023/02/18 17:41:25
dnl -----------------
dnl Define _POSIX_C_SOURCE to the given level, and _POSIX_SOURCE if needed.
dnl
dnl	POSIX.1-1990				_POSIX_SOURCE
dnl	POSIX.1-1990 and			_POSIX_SOURCE and
dnl		POSIX.2-1992 C-Language			_POSIX_C_SOURCE=2
dnl		Bindings Option
dnl	POSIX.1b-1993				_POSIX_C_SOURCE=199309L
dnl	POSIX.1c-1996				_POSIX_C_SOURCE=199506L
dnl	X/Open 2000				_POSIX_C_SOURCE=200112L
dnl
dnl Parameters:
dnl	$1 is the nominal value for _POSIX_C_SOURCE
AC_DEFUN([CF_POSIX_C_SOURCE],
[AC_REQUIRE([CF_POSIX_VISIBLE])dnl

if test "$cf_cv_posix_visible" = no; then

cf_POSIX_C_SOURCE=ifelse([$1],,199506L,[$1])

cf_save_CFLAGS="$CFLAGS"
cf_save_CPPFLAGS="$CPPFLAGS"

CF_REMOVE_DEFINE(cf_trim_CFLAGS,$cf_save_CFLAGS,_POSIX_C_SOURCE)
CF_REMOVE_DEFINE(cf_trim_CPPFLAGS,$cf_save_CPPFLAGS,_POSIX_C_SOURCE)

AC_CACHE_CHECK(if we should define _POSIX_C_SOURCE,cf_cv_posix_c_source,[
	CF_MSG_LOG(if the symbol is already defined go no further)
	AC_TRY_COMPILE([#include <sys/types.h>],[
#ifndef _POSIX_C_SOURCE
#error _POSIX_C_SOURCE is not defined
#endif],
	[cf_cv_posix_c_source=no],
	[cf_want_posix_source=no
	 case .$cf_POSIX_C_SOURCE in
	 (.[[12]]??*)
		cf_cv_posix_c_source="-D_POSIX_C_SOURCE=$cf_POSIX_C_SOURCE"
		;;
	 (.2)
		cf_cv_posix_c_source="-D_POSIX_C_SOURCE=$cf_POSIX_C_SOURCE"
		cf_want_posix_source=yes
		;;
	 (.*)
		cf_want_posix_source=yes
		;;
	 esac
	 if test "$cf_want_posix_source" = yes ; then
		AC_TRY_COMPILE([#include <sys/types.h>],[
#ifdef _POSIX_SOURCE
#error _POSIX_SOURCE is defined
#endif],[],
		cf_cv_posix_c_source="$cf_cv_posix_c_source -D_POSIX_SOURCE")
	 fi
	 CF_MSG_LOG(ifdef from value $cf_POSIX_C_SOURCE)
	 CFLAGS="$cf_trim_CFLAGS"
	 CPPFLAGS="$cf_trim_CPPFLAGS"
	 CF_APPEND_TEXT(CPPFLAGS,$cf_cv_posix_c_source)
	 CF_MSG_LOG(if the second compile does not leave our definition intact error)
	 AC_TRY_COMPILE([#include <sys/types.h>],[
#ifndef _POSIX_C_SOURCE
#error _POSIX_C_SOURCE is not defined
#endif],,
	 [cf_cv_posix_c_source=no])
	 CFLAGS="$cf_save_CFLAGS"
	 CPPFLAGS="$cf_save_CPPFLAGS"
	])
])

if test "$cf_cv_posix_c_source" != no ; then
	CFLAGS="$cf_trim_CFLAGS"
	CPPFLAGS="$cf_trim_CPPFLAGS"
	CF_ADD_CFLAGS($cf_cv_posix_c_source)
fi

fi # cf_cv_posix_visible

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_POSIX_VISIBLE version: 1 updated: 2018/12/31 20:46:17
dnl ----------------
dnl POSIX documents test-macros which an application may set before any system
dnl headers are included to make features available.
dnl
dnl Some BSD platforms (originally FreeBSD, but copied by a few others)
dnl diverged from POSIX in 2002 by setting symbols which make all of the most
dnl recent features visible in the system header files unless the application
dnl overrides the corresponding test-macros.  Doing that introduces portability
dnl problems.
dnl
dnl This macro makes a special check for the symbols used for this, to avoid a
dnl conflicting definition.
AC_DEFUN([CF_POSIX_VISIBLE],
[
AC_CACHE_CHECK(if the POSIX test-macros are already defined,cf_cv_posix_visible,[
AC_TRY_COMPILE([#include <stdio.h>],[
#if defined(__POSIX_VISIBLE) && ((__POSIX_VISIBLE - 0L) > 0) \
	&& defined(__XSI_VISIBLE) && ((__XSI_VISIBLE - 0L) > 0) \
	&& defined(__BSD_VISIBLE) && ((__BSD_VISIBLE - 0L) > 0) \
	&& defined(__ISO_C_VISIBLE) && ((__ISO_C_VISIBLE - 0L) > 0)
#error conflicting symbols found
#endif
],[cf_cv_posix_visible=no],[cf_cv_posix_visible=yes])
])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PROG_AR version: 1 updated: 2009/01/01 20:15:22
dnl ----------
dnl Check for archiver "ar".
AC_DEFUN([CF_PROG_AR],[
AC_CHECK_TOOL(AR, ar, ar)
])
dnl ---------------------------------------------------------------------------
dnl CF_PROG_CC version: 5 updated: 2019/12/31 08:53:54
dnl ----------
dnl standard check for CC, plus followup sanity checks
dnl $1 = optional parameter to pass to AC_PROG_CC to specify compiler name
AC_DEFUN([CF_PROG_CC],[
CF_ACVERSION_CHECK(2.53,
	[AC_MSG_WARN(this will incorrectly handle gnatgcc choice)
	 AC_REQUIRE([AC_PROG_CC])],
	[])
ifelse($1,,[AC_PROG_CC],[AC_PROG_CC($1)])
CF_GCC_VERSION
CF_ACVERSION_CHECK(2.52,
	[AC_PROG_CC_STDC],
	[CF_ANSI_CC_REQD])
CF_CC_ENV_FLAGS
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PROG_LINT version: 5 updated: 2022/08/20 15:44:13
dnl ------------
AC_DEFUN([CF_PROG_LINT],
[
AC_CHECK_PROGS(LINT, lint cppcheck splint)
case "x$LINT" in
(xcppcheck|x*/cppcheck)
	test -z "$LINT_OPTS" && LINT_OPTS="--enable=all"
	;;
esac
AC_SUBST(LINT_OPTS)
AC_SUBST(LINT_LIBS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_PROG_YACC version: 3 updated: 2022/12/21 19:22:20
dnl ------------
dnl A better version of AC_PROC_YACC, verifies that we'll only choose bison if
dnl we'll be able to compile with it.  Bison uses alloca, which isn't all that
dnl portable.
AC_DEFUN([CF_PROG_YACC],
[
AC_REQUIRE([AC_PROG_CC])
AC_CACHE_VAL(cf_cv_prog_YACC,[
if test -n "$YACC" ; then
  cf_cv_prog_YACC="$YACC" # Let the user override the test.
else
cat >conftest.y <<EOF
%{
int yylex(void);
void yyerror(const char *s);
void yyerror(const char *s) { (void)s; }
%}
%token	NUMBER
%%
time	: NUMBER ':' NUMBER
	;
%%
int yylex(void) { return NUMBER; }
int main(void) { return yyparse(); }
EOF
  for cf_prog in 'bison -y' byacc yacc
  do
    rm -f y.tab.[ch]
    AC_MSG_CHECKING(for $cf_prog)
    cf_command="$cf_prog conftest.y"
    cf_result=no
    if AC_TRY_EVAL(cf_command) && test -s y.tab.c ; then
      mv y.tab.c conftest.c
      rm -f y.tab.h
      if test "$cf_prog" = 'bison -y' ; then
        if AC_TRY_EVAL(ac_link) && test -s conftest ; then
          cf_result=yes
        fi
      else
        cf_result=yes
      fi
    fi
    AC_MSG_RESULT($cf_result)
    if test $cf_result = yes ; then
      cf_cv_prog_YACC="$cf_prog"
      break
    fi
  done
fi
])
YACC="$cf_cv_prog_YACC"
AC_SUBST(YACC)dnl
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_REMOVE_CFLAGS version: 3 updated: 2021/09/05 17:25:40
dnl ----------------
dnl Remove a given option from CFLAGS/CPPFLAGS
dnl $1 = option to remove
dnl $2 = variable to update
dnl $3 = nonempty to allow verbose message
define([CF_REMOVE_CFLAGS],
[
cf_tmp_cflag=`echo "x$1" | sed -e 's/^.//' -e 's/=.*//'`
while true
do
	cf_old_cflag=`echo "x[$]$2" | sed -e 's/^.//' -e 's/[[ 	]][[ 	]]*-/ -/g' -e "s%$cf_tmp_cflag\\(=[[^ 	]][[^ 	]]*\\)\?%%" -e 's/^[[ 	]]*//' -e 's%[[ ]][[ ]]*-D% -D%g' -e 's%[[ ]][[ ]]*-I% -I%g'`
	test "[$]$2" != "$cf_old_cflag" || break
	ifelse([$3],,,[CF_VERBOSE(removing old option $1 from $2)])
	$2="$cf_old_cflag"
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_REMOVE_DEFINE version: 3 updated: 2010/01/09 11:05:50
dnl ----------------
dnl Remove all -U and -D options that refer to the given symbol from a list
dnl of C compiler options.  This works around the problem that not all
dnl compilers process -U and -D options from left-to-right, so a -U option
dnl cannot be used to cancel the effect of a preceding -D option.
dnl
dnl $1 = target (which could be the same as the source variable)
dnl $2 = source (including '$')
dnl $3 = symbol to remove
define([CF_REMOVE_DEFINE],
[
$1=`echo "$2" | \
	sed	-e 's/-[[UD]]'"$3"'\(=[[^ 	]]*\)\?[[ 	]]/ /g' \
		-e 's/-[[UD]]'"$3"'\(=[[^ 	]]*\)\?[$]//g'`
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_RESTORE_XTRA_FLAGS version: 1 updated: 2020/01/11 16:47:45
dnl ---------------------
dnl Restore flags saved in CF_SAVE_XTRA_FLAGS
dnl $1 = name of current macro
define([CF_RESTORE_XTRA_FLAGS],
[
LIBS="$cf_save_LIBS_$1"
CFLAGS="$cf_save_CFLAGS_$1"
CPPFLAGS="$cf_save_CPPFLAGS_$1"
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_RPATH_HACK version: 13 updated: 2021/01/03 18:30:50
dnl -------------
AC_DEFUN([CF_RPATH_HACK],
[AC_REQUIRE([AC_PROG_FGREP])dnl
AC_REQUIRE([CF_LD_RPATH_OPT])dnl

AC_MSG_CHECKING(for updated LDFLAGS)
if test -n "$LD_RPATH_OPT" ; then
	AC_MSG_RESULT(maybe)

	AC_CHECK_PROGS(cf_ldd_prog,ldd,no)
	cf_rpath_list="/usr/lib /lib"
	if test "$cf_ldd_prog" != no
	then
		cf_rpath_oops=

AC_TRY_LINK([#include <stdio.h>],
		[printf("Hello");],
		[cf_rpath_oops=`"$cf_ldd_prog" "conftest$ac_exeext" | ${FGREP-fgrep} ' not found' | sed -e 's% =>.*$%%' |sort | uniq`
		 cf_rpath_list=`"$cf_ldd_prog" "conftest$ac_exeext" | ${FGREP-fgrep} / | sed -e 's%^.*[[ 	]]/%/%' -e 's%/[[^/]][[^/]]*$%%' |sort | uniq`])

		# If we passed the link-test, but get a "not found" on a given library,
		# this could be due to inept reconfiguration of gcc to make it only
		# partly honor /usr/local/lib (or whatever).  Sometimes this behavior
		# is intentional, e.g., installing gcc in /usr/bin and suppressing the
		# /usr/local libraries.
		if test -n "$cf_rpath_oops"
		then
			for cf_rpath_src in $cf_rpath_oops
			do
				for cf_rpath_dir in \
					/usr/local \
					/usr/pkg \
					/opt/sfw
				do
					if test -f "$cf_rpath_dir/lib/$cf_rpath_src"
					then
						CF_VERBOSE(...adding -L$cf_rpath_dir/lib to LDFLAGS for $cf_rpath_src)
						LDFLAGS="$LDFLAGS -L$cf_rpath_dir/lib"
						break
					fi
				done
			done
		fi
	fi

	CF_VERBOSE(...checking EXTRA_LDFLAGS $EXTRA_LDFLAGS)

	CF_RPATH_HACK_2(LDFLAGS)
	CF_RPATH_HACK_2(LIBS)

	CF_VERBOSE(...checked EXTRA_LDFLAGS $EXTRA_LDFLAGS)
else
	AC_MSG_RESULT(no)
fi
AC_SUBST(EXTRA_LDFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_RPATH_HACK_2 version: 8 updated: 2021/01/01 13:31:04
dnl ---------------
dnl Do one set of substitutions for CF_RPATH_HACK, adding an rpath option to
dnl EXTRA_LDFLAGS for each -L option found.
dnl
dnl $cf_rpath_list contains a list of directories to ignore.
dnl
dnl $1 = variable name to update.  The LDFLAGS variable should be the only one,
dnl      but LIBS often has misplaced -L options.
AC_DEFUN([CF_RPATH_HACK_2],
[
CF_VERBOSE(...checking $1 [$]$1)

cf_rpath_dst=
for cf_rpath_src in [$]$1
do
	case "$cf_rpath_src" in
	(-L*)

		# check if this refers to a directory which we will ignore
		cf_rpath_skip=no
		if test -n "$cf_rpath_list"
		then
			for cf_rpath_item in $cf_rpath_list
			do
				if test "x$cf_rpath_src" = "x-L$cf_rpath_item"
				then
					cf_rpath_skip=yes
					break
				fi
			done
		fi

		if test "$cf_rpath_skip" = no
		then
			# transform the option
			if test "$LD_RPATH_OPT" = "-R " ; then
				cf_rpath_tmp=`echo "$cf_rpath_src" |sed -e "s%-L%-R %"`
			else
				cf_rpath_tmp=`echo "$cf_rpath_src" |sed -e "s%-L%$LD_RPATH_OPT%"`
			fi

			# if we have not already added this, add it now
			cf_rpath_tst=`echo "$EXTRA_LDFLAGS" | sed -e "s%$cf_rpath_tmp %%"`
			if test "x$cf_rpath_tst" = "x$EXTRA_LDFLAGS"
			then
				CF_VERBOSE(...Filter $cf_rpath_src ->$cf_rpath_tmp)
				EXTRA_LDFLAGS="$cf_rpath_tmp $EXTRA_LDFLAGS"
			fi
		fi
		;;
	esac
	cf_rpath_dst="$cf_rpath_dst $cf_rpath_src"
done
$1=$cf_rpath_dst

CF_VERBOSE(...checked $1 [$]$1)
AC_SUBST(EXTRA_LDFLAGS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_SAVE_XTRA_FLAGS version: 1 updated: 2020/01/11 16:46:44
dnl ------------------
dnl Use this macro to save CFLAGS/CPPFLAGS/LIBS before checks against X headers
dnl and libraries which do not update those variables.
dnl
dnl $1 = name of current macro
define([CF_SAVE_XTRA_FLAGS],
[
cf_save_LIBS_$1="$LIBS"
cf_save_CFLAGS_$1="$CFLAGS"
cf_save_CPPFLAGS_$1="$CPPFLAGS"
LIBS="$LIBS ${X_PRE_LIBS} ${X_LIBS} ${X_EXTRA_LIBS}"
for cf_X_CFLAGS in $X_CFLAGS
do
	case "x$cf_X_CFLAGS" in
	x-[[IUD]]*)
		CPPFLAGS="$CPPFLAGS $cf_X_CFLAGS"
		;;
	*)
		CFLAGS="$CFLAGS $cf_X_CFLAGS"
		;;
	esac
done
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_SHARED_OPTS version: 111 updated: 2024/03/29 20:08:49
dnl --------------
dnl --------------
dnl Attempt to determine the appropriate CC/LD options for creating a shared
dnl library.
dnl
dnl Notes:
dnl a) ${LOCAL_LDFLAGS} is used to link executables that will run within
dnl the build-tree, i.e., by making use of the libraries that are compiled in
dnl $rel_builddir/lib We avoid compiling-in a $rel_builddir/lib path for the
dnl shared library since that can lead to unexpected results at runtime.
dnl b) ${LOCAL_LDFLAGS2} has the same intention but assumes that the shared
dnl libraries are compiled in ../../lib
dnl
dnl The variable 'cf_cv_do_symlinks' is used to control whether we configure
dnl to install symbolic links to the rel/abi versions of shared libraries.
dnl
dnl The variable 'cf_cv_shlib_version' controls whether we use the rel or abi
dnl version when making symbolic links.
dnl
dnl The variable 'cf_cv_shlib_version_infix' controls whether shared library
dnl version numbers are infix (ex: libncurses.<ver>.dylib) or postfix
dnl (ex: libncurses.so.<ver>).
dnl
dnl Some loaders leave 'so_locations' lying around.  It is nice to clean up.
AC_DEFUN([CF_SHARED_OPTS],
[
	AC_REQUIRE([CF_LD_RPATH_OPT])

	RM_SHARED_OPTS=
	LOCAL_LDFLAGS=
	LOCAL_LDFLAGS2=
	LD_SHARED_OPTS=
	INSTALL_LIB="-m 644"
	: ${rel_builddir:=.}

	shlibdir=$libdir
	AC_SUBST(shlibdir)

	MAKE_DLLS="#"
	AC_SUBST(MAKE_DLLS)

	cf_cv_do_symlinks=no
	cf_ld_rpath_opt=
	test "$cf_cv_enable_rpath" = yes && cf_ld_rpath_opt="$LD_RPATH_OPT"

	AC_MSG_CHECKING(whether to use release or ABI version in shared library file names)
	AC_ARG_WITH(shlib-version,
	[[  --with-shlib-version[={rel|abi}] use release or ABI version in shared library file names]],
	[test -z "$withval" && withval=auto
	case "$withval" in
	(yes)
		cf_cv_shlib_version=auto
		;;
	(rel|abi|auto)
		cf_cv_shlib_version=$withval
		;;
	(*)
		AC_MSG_RESULT($withval)
		AC_MSG_ERROR([option value must be one of: rel, abi, or auto])
		;;
	esac
	],[cf_cv_shlib_version=auto])
	AC_MSG_RESULT($cf_cv_shlib_version)

	cf_cv_rm_so_locs=no
	cf_try_cflags=

	# Some less-capable ports of gcc support only -fpic
	CC_SHARED_OPTS=

	cf_try_fPIC=no
	if test "$GCC" = yes
	then
		cf_try_fPIC=yes
	else
		case "$cf_cv_system_name" in
		(*linux*)	# e.g., PGI compiler
			cf_try_fPIC=yes
			;;
		esac
	fi

	if test "$cf_try_fPIC" = yes
	then
		AC_MSG_CHECKING(which $CC option to use)
		cf_save_CFLAGS="$CFLAGS"
		for CC_SHARED_OPTS in -fPIC -fpic ''
		do
			CFLAGS="$cf_save_CFLAGS $CC_SHARED_OPTS"
			AC_TRY_COMPILE([#include <stdio.h>],[int x = 1; (void)x],[break],[])
		done
		AC_MSG_RESULT($CC_SHARED_OPTS)
		CFLAGS="$cf_save_CFLAGS"
	fi

	cf_cv_shlib_version_infix=no

	case "$cf_cv_system_name" in
	(aix4.[3-9]*|aix[[5-7]]*)
		if test "$GCC" = yes; then
			CC_SHARED_OPTS='-Wl,-brtl'
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-brtl -Wl,-blibpath:${RPATH_LIST}:/usr/lib -o [$]@'
		else
			CC_SHARED_OPTS='-brtl'
			# as well as '-qpic=large -G' or perhaps "-bM:SRE -bnoentry -bexpall"
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -G -Wl,-brtl -Wl,-blibpath:${RPATH_LIST}:/usr/lib -o [$]@'
		fi
		;;
	(beos*)
		MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -o $[@] -Xlinker -soname=`basename $[@]` -nostart -e 0'
		;;
	(cygwin*)
		CC_SHARED_OPTS=
		MK_SHARED_LIB=$SHELL' '$rel_builddir'/mk_shared_lib.sh [$]@ [$]{CC} [$]{CFLAGS}'
		RM_SHARED_OPTS="$RM_SHARED_OPTS $rel_builddir/mk_shared_lib.sh *.dll.a"
		cf_cv_shlib_version=cygdll
		cf_cv_shlib_version_infix=cygdll
		shlibdir=$bindir
		MAKE_DLLS=
		cat >mk_shared_lib.sh <<-CF_EOF
		#!$SHELL
		SHARED_LIB=\[$]1
		IMPORT_LIB=\`echo "\[$]1" | sed -e 's/cyg/lib/' -e 's/[[0-9]]*\.dll[$]/.dll.a/'\`
		shift
		cat <<-EOF
		Linking shared library
		** SHARED_LIB \[$]SHARED_LIB
		** IMPORT_LIB \[$]IMPORT_LIB
EOF
		exec \[$]* ${LDFLAGS} -shared -Wl,--out-implib=\[$]{IMPORT_LIB} -Wl,--export-all-symbols -o \[$]{SHARED_LIB}
CF_EOF
		chmod +x mk_shared_lib.sh
		;;
	(msys*)
		CC_SHARED_OPTS=
		MK_SHARED_LIB=$SHELL' '$rel_builddir'/mk_shared_lib.sh [$]@ [$]{CC} [$]{CFLAGS}'
		RM_SHARED_OPTS="$RM_SHARED_OPTS $rel_builddir/mk_shared_lib.sh *.dll.a"
		cf_cv_shlib_version=msysdll
		cf_cv_shlib_version_infix=msysdll
		shlibdir=$bindir
		MAKE_DLLS=
		cat >mk_shared_lib.sh <<-CF_EOF
		#!$SHELL
		SHARED_LIB=\[$]1
		IMPORT_LIB=\`echo "\[$]1" | sed -e 's/msys-/lib/' -e 's/[[0-9]]*\.dll[$]/.dll.a/'\`
		shift
		cat <<-EOF
		Linking shared library
		** SHARED_LIB \[$]SHARED_LIB
		** IMPORT_LIB \[$]IMPORT_LIB
EOF
		exec \[$]* ${LDFLAGS} -shared -Wl,--out-implib=\[$]{IMPORT_LIB} -Wl,--export-all-symbols -o \[$]{SHARED_LIB}
CF_EOF
		chmod +x mk_shared_lib.sh
		;;
	(darwin*)
		cf_try_cflags="no-cpp-precomp"
		CC_SHARED_OPTS="-dynamic"
		MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -dynamiclib -install_name ${libdir}/`basename $[@]` -compatibility_version ${ABI_VERSION} -current_version ${ABI_VERSION} -o $[@]'
		test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=abi
		cf_cv_shlib_version_infix=yes
		AC_CACHE_CHECK([if ld -search_paths_first works], cf_cv_ldflags_search_paths_first, [
			cf_save_LDFLAGS=$LDFLAGS
			LDFLAGS="$LDFLAGS -Wl,-search_paths_first"
			AC_TRY_LINK(, [int i;], cf_cv_ldflags_search_paths_first=yes, cf_cv_ldflags_search_paths_first=no)
				LDFLAGS=$cf_save_LDFLAGS])
		if test "$cf_cv_ldflags_search_paths_first" = yes; then
			LDFLAGS="$LDFLAGS -Wl,-search_paths_first"
		fi
		;;
	(haiku*)
		CF_SHARED_SONAME
		MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-soname,'$cf_cv_shared_soname',-stats,-lc -o $[@]'
		;;
	(hpux[[7-8]]*)
		# HP-UX 8.07 ld lacks "+b" option used for libdir search-list
		if test "$GCC" != yes; then
			CC_SHARED_OPTS='+Z'
		fi
		MK_SHARED_LIB='${LD} ${LDFLAGS} -b -o $[@]'
		INSTALL_LIB="-m 555"
		;;
	(hpux*)
		# (tested with gcc 2.7.2 -- I don't have c89)
		if test "$GCC" = yes; then
			LD_SHARED_OPTS='-Xlinker +b -Xlinker ${libdir}'
		else
			CC_SHARED_OPTS='+Z'
			LD_SHARED_OPTS='-Wl,+b,${libdir}'
		fi
		MK_SHARED_LIB='${LD} ${LDFLAGS} +b ${libdir} -b -o $[@]'
		# HP-UX shared libraries must be executable, and should be
		# readonly to exploit a quirk in the memory manager.
		INSTALL_LIB="-m 555"
		;;
	(interix*)
		test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=rel
		if test "$cf_cv_shlib_version" = rel; then
			cf_shared_soname='`basename $[@] .${REL_VERSION}`.${ABI_VERSION}'
		else
			cf_shared_soname='`basename $[@]`'
		fi
		CC_SHARED_OPTS=
		MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-rpath,${RPATH_LIST} -Wl,-h,'$cf_shared_soname' -o $[@]'
		;;
	(irix*)
		if test "$cf_cv_enable_rpath" = yes ; then
			EXTRA_LDFLAGS="${cf_ld_rpath_opt}\${RPATH_LIST} $EXTRA_LDFLAGS"
		fi
		# tested with IRIX 5.2 and 'cc'.
		if test "$GCC" != yes; then
			CC_SHARED_OPTS='-KPIC'
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -rdata_shared -soname `basename $[@]` -o $[@]'
		else
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-soname,`basename $[@]` -o $[@]'
		fi
		cf_cv_rm_so_locs=yes
		;;
	(linux*|gnu*|k*bsd*-gnu)
		if test "$DFT_LWR_MODEL" = "shared" && test -n "$LD_RPATH_OPT" ; then
			LOCAL_LDFLAGS="${LD_RPATH_OPT}\$(LOCAL_LIBDIR)"
			LOCAL_LDFLAGS2="$LOCAL_LDFLAGS"
		fi
		if test "$cf_cv_enable_rpath" = yes ; then
			EXTRA_LDFLAGS="${cf_ld_rpath_opt}\${RPATH_LIST} $EXTRA_LDFLAGS"
		fi
		CF_SHARED_SONAME
		MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-soname,'$cf_cv_shared_soname',-stats,-lc -o $[@]'
		;;
	(mingw*msvc*)
		cf_cv_shlib_version=msvcdll
		cf_cv_shlib_version_infix=msvcdll
		shlibdir=$bindir
		MAKE_DLLS=
		if test "$DFT_LWR_MODEL" = "shared" ; then
			LOCAL_LDFLAGS="-link -dll"
			LOCAL_LDFLAGS2="$LOCAL_LDFLAGS"
			EXTRA_LDFLAGS="-link -dll $EXTRA_LDFLAGS"
		fi
		CC_SHARED_OPTS=
		MK_SHARED_LIB=$SHELL' '$rel_builddir'/mk_shared_lib.sh [$]@ ${LD} [$]{CFLAGS}'
		RM_SHARED_OPTS="$RM_SHARED_OPTS $rel_builddir/mk_shared_lib.sh *.dll.lib"
		cat >mk_shared_lib.sh <<-CF_EOF
		#!$SHELL
		SHARED_LIB=\[$]1
		IMPORT_LIB=\`echo "\[$]1" | sed -e 's/[[0-9]]*\.dll[$]/.dll.lib/'\`
		shift
		my_ld=\[$]1
		shift
		cat <<-EOF
		Linking shared library
		** SHARED LIB \$SHARED_LIB
		** IMPORT_LIB \$IMPORT_LIB
EOF
		args=\$(echo \[$]* | sed -E "s#-l(\w*)#\1.dll.lib#g" | sed -E "s#-L(\w*)#-LIBPATH:\1#g")
		exec \$my_ld -DLL -IMPLIB:"\${IMPORT_LIB}" -OUT:"\${SHARED_LIB}" ${LDFLAGS} \$args
		mv "\${IMPORT_LIB}" "\${IMPORT_LIB}"
CF_EOF
		chmod +x mk_shared_lib.sh
		cat >mk_prog.sh <<-CF_EOF
		#!$SHELL
		shift
		# Ignore first argument (compiler) and use LD (link.exe) unconditionally
		LD="[$]LD"
		clopts=()
		ldopts=("/subsystem:console")
		libs=()
		isdll=0
		while test \[$]# -gt 0; do
			case "\[$]1" in
				-link)
					# ignore -link argument
					;;
				-M[[TD]] | -M[[TD]]d)
					# ignore runtime-library option
					;;
				-dll)
					isdll=1
					;;
				-W* | -w*)
					# ignore warnings
					;;
				-D*)
					clopts+=("\[$]1")
					;;
				-I*)
					clopts+=("\[$]1")
					;;
				-l*)
					libs+=("\`echo \"\[$]1\" | sed \"s/^-l//\"\`")
					;;
				-L*)
					ldopts+=("\`echo \"\[$]1\" | sed \"s/^-L/-LIBPATH:/\"\`")
					;;
				*.obj | *.o)
					ldopts+=("\[$]1")
					;;
				-Wl,*)
					for linkarg in \`echo '\[$]1' | sed -e 's/-Wl,//' -e 's/,/ /'\`; do
						ldopts+=("\[$]{linkarg}")
					done
					;;
				*.lib)
					ldopts+=("\[$]1")
					;;
				-o)
					shift
					ldopts+=("-out:\[$]1")
					;;
				*)
					clopts+=("\[$]1")
					ldopts+=("\[$]1")
					;;
			esac
			shift
		done
		if [[ "\$isdll" -ne 0 ]]; then
			for lib in \[$]{libs[[*]]}; do
				ldopts+=("\[$]lib.dll.lib")
			done
		else
			for lib in \[$]{libs[[*]]}; do
				ldopts+=("\[$]lib.lib")
			done
		fi
		cat <<-EOF
		Creating program
		** ld options:   "\[$]{ldopts[[@]]}"
EOF
		exec \[$]LD \[$]{ldopts[[@]]}
CF_EOF
		chmod +x mk_prog.sh
		LINK_PROGS="$SHELL ${rel_builddir}/mk_prog.sh"
		LINK_TESTS="$SHELL ${rel_builddir}/mk_prog.sh"
		;;
	(mingw*)
		cf_cv_shlib_version=mingw
		cf_cv_shlib_version_infix=mingw
		shlibdir=$bindir
		MAKE_DLLS=
		if test "$DFT_LWR_MODEL" = "shared" ; then
			LOCAL_LDFLAGS="-Wl,--enable-auto-import"
			LOCAL_LDFLAGS2="$LOCAL_LDFLAGS"
			EXTRA_LDFLAGS="-Wl,--enable-auto-import $EXTRA_LDFLAGS"
		fi
		CC_SHARED_OPTS=
		MK_SHARED_LIB=$SHELL' '$rel_builddir'/mk_shared_lib.sh [$]@ [$]{CC} [$]{CFLAGS}'
		RM_SHARED_OPTS="$RM_SHARED_OPTS $rel_builddir/mk_shared_lib.sh *.dll.a"
		cat >mk_shared_lib.sh <<-CF_EOF
		#!$SHELL
		SHARED_LIB=\[$]1
		IMPORT_LIB=\`echo "\[$]1" | sed -e 's/[[0-9]]*\.dll[$]/.dll.a/'\`
		shift
		cat <<-EOF
		Linking shared library
		** SHARED_LIB \[$]SHARED_LIB
		** IMPORT_LIB \[$]IMPORT_LIB
EOF
		exec \[$]* ${LDFLAGS} -shared -Wl,--enable-auto-import,--out-implib=\[$]{IMPORT_LIB} -Wl,--export-all-symbols -o \[$]{SHARED_LIB}
CF_EOF
		chmod +x mk_shared_lib.sh
		;;
	(openbsd[[2-9]].*|mirbsd*)
		if test "$DFT_LWR_MODEL" = "shared" && test -n "$LD_RPATH_OPT" ; then
			LOCAL_LDFLAGS="${LD_RPATH_OPT}\$(LOCAL_LIBDIR)"
			LOCAL_LDFLAGS2="$LOCAL_LDFLAGS"
		fi
		if test "$cf_cv_enable_rpath" = yes ; then
			EXTRA_LDFLAGS="${cf_ld_rpath_opt}\${RPATH_LIST} $EXTRA_LDFLAGS"
		fi
		CC_SHARED_OPTS="$CC_SHARED_OPTS -DPIC"
		CF_SHARED_SONAME
		MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-Bshareable,-soname,'$cf_cv_shared_soname',-stats,-lc -o $[@]'
		;;
	(nskJ*)
		CC_SHARED_OPTS=
		MK_SHARED_LIB='${LD} -Wshared -Weld=-export_all -o $[@]'
		;;
	(nskL*)
		CC_SHARED_OPTS=
		MK_SHARED_LIB='${LD} -Wshared -Wxld=-export_all -o $[@]'
		;;
	(nto-qnx*|openbsd*|freebsd[[12]].*)
		CC_SHARED_OPTS="$CC_SHARED_OPTS -DPIC"
		MK_SHARED_LIB='${LD} ${LDFLAGS} -Bshareable -o $[@]'
		test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=rel
		;;
	(dragonfly*|freebsd*)
		CC_SHARED_OPTS="$CC_SHARED_OPTS -DPIC"
		if test "$DFT_LWR_MODEL" = "shared" && test "$cf_cv_enable_rpath" = yes ; then
			LOCAL_LDFLAGS="${cf_ld_rpath_opt}\$(LOCAL_LIBDIR)"
			LOCAL_LDFLAGS2="${cf_ld_rpath_opt}\${RPATH_LIST} $LOCAL_LDFLAGS"
			EXTRA_LDFLAGS="${cf_ld_rpath_opt}\${RPATH_LIST} $EXTRA_LDFLAGS"
		fi
		CF_SHARED_SONAME
		MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-soname,'$cf_cv_shared_soname',-stats,-lc -o $[@]'
		;;
	(netbsd*)
		CC_SHARED_OPTS="$CC_SHARED_OPTS -DPIC"
		if test "$DFT_LWR_MODEL" = "shared" && test "$cf_cv_enable_rpath" = yes ; then
			LOCAL_LDFLAGS="${cf_ld_rpath_opt}\$(LOCAL_LIBDIR)"
			LOCAL_LDFLAGS2="$LOCAL_LDFLAGS"
			EXTRA_LDFLAGS="${cf_ld_rpath_opt}\${RPATH_LIST} $EXTRA_LDFLAGS"
			if test "$cf_cv_shlib_version" = auto; then
			if test -f /usr/libexec/ld.elf_so; then
				cf_cv_shlib_version=abi
			else
				cf_cv_shlib_version=rel
			fi
			fi
			CF_SHARED_SONAME
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -Wl,-soname,'$cf_cv_shared_soname' -o $[@]'
		else
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -o $[@]'
		fi
		;;
	(osf*|mls+*)
		# tested with OSF/1 V3.2 and 'cc'
		# tested with OSF/1 V3.2 and gcc 2.6.3 (but the c++ demo didn't
		# link with shared libs).
		MK_SHARED_LIB='${LD} ${LDFLAGS} -set_version ${REL_VERSION}:${ABI_VERSION} -expect_unresolved "*" -shared -soname `basename $[@]`'
		case "$host_os" in
		(osf4*)
			MK_SHARED_LIB="${MK_SHARED_LIB} -msym"
			;;
		esac
		MK_SHARED_LIB="${MK_SHARED_LIB}"' -o $[@]'
		if test "$DFT_LWR_MODEL" = "shared" && test -n "$LD_RPATH_OPT" ; then
			LOCAL_LDFLAGS="${LD_RPATH_OPT}\$(LOCAL_LIBDIR)"
			LOCAL_LDFLAGS2="$LOCAL_LDFLAGS"
		fi
		cf_cv_rm_so_locs=yes
		;;
	(sco3.2v5*)  # also uw2* and UW7: hops 13-Apr-98
		# tested with osr5.0.5
		if test "$GCC" != yes; then
			CC_SHARED_OPTS='-belf -KPIC'
		fi
		MK_SHARED_LIB='${LD} ${LDFLAGS} -dy -G -h `basename $[@] .${REL_VERSION}`.${ABI_VERSION} -o [$]@'
		if test "$cf_cv_enable_rpath" = yes ; then
			# only way is to set LD_RUN_PATH but no switch for it
			RUN_PATH=$libdir
		fi
		test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=rel
		LINK_PROGS='LD_RUN_PATH=${libdir}'
		LINK_TESTS='Pwd=`pwd`;LD_RUN_PATH=`dirname $${Pwd}`/lib'
		;;
	(sunos4*)
		# tested with SunOS 4.1.1 and gcc 2.7.0
		if test "$GCC" != yes; then
			CC_SHARED_OPTS='-KPIC'
		fi
		MK_SHARED_LIB='${LD} ${LDFLAGS} -assert pure-text -o $[@]'
		test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=rel
		;;
	(solaris2*)
		# tested with SunOS 5.5.1 (solaris 2.5.1) and gcc 2.7.2
		# tested with SunOS 5.10 (solaris 10) and gcc 3.4.3
		if test "$DFT_LWR_MODEL" = "shared" ; then
			LOCAL_LDFLAGS="-R\$(LOCAL_LIBDIR):\${libdir}"
			LOCAL_LDFLAGS2="$LOCAL_LDFLAGS"
		fi
		if test "$cf_cv_enable_rpath" = yes ; then
			EXTRA_LDFLAGS="-R\${libdir} $EXTRA_LDFLAGS"
		fi
		CF_SHARED_SONAME
		if test "$GCC" != yes; then
			cf_save_CFLAGS="$CFLAGS"
			for cf_shared_opts in -xcode=pic32 -xcode=pic13 -KPIC -Kpic -O
			do
				CFLAGS="$cf_shared_opts $cf_save_CFLAGS"
				AC_TRY_COMPILE([#include <stdio.h>],[printf("Hello\\n");],[break])
			done
			CFLAGS="$cf_save_CFLAGS"
			CC_SHARED_OPTS=$cf_shared_opts
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -dy -G -Wl,-h,'$cf_cv_shared_soname' -o $[@]'
		else
			MK_SHARED_LIB='${CC} ${LDFLAGS} ${CFLAGS} -shared -dy -G -Wl,-h,'$cf_cv_shared_soname' -o $[@]'
		fi
		;;
	(sysv5uw7*|unix_sv*)
		# tested with UnixWare 7.1.0 (gcc 2.95.2 and cc)
		if test "$GCC" != yes; then
			CC_SHARED_OPTS='-KPIC'
		fi
		MK_SHARED_LIB='${LD} ${LDFLAGS} -d y -G -o [$]@'
		;;
	(*)
		CC_SHARED_OPTS='unknown'
		MK_SHARED_LIB='echo unknown'
		;;
	esac

	# This works if the last tokens in $MK_SHARED_LIB are the -o target.
	case "$cf_cv_shlib_version" in
	(rel|abi)
		case "$MK_SHARED_LIB" in
		(*'-o $[@]')
			test "$cf_cv_do_symlinks" = no && cf_cv_do_symlinks=yes
			;;
		(*)
			AC_MSG_WARN(ignored --with-shlib-version)
			;;
		esac
		;;
	esac

	if test -n "$cf_try_cflags"
	then
cat > conftest.$ac_ext <<EOF
#line __oline__ "${as_me:-configure}"
#include <stdio.h>
int main(int argc, char *argv[[]])
{
	printf("hello\\n");
	return (argv[[argc-1]] == 0) ;
}
EOF
		cf_save_CFLAGS="$CFLAGS"
		for cf_opt in $cf_try_cflags
		do
			CFLAGS="$cf_save_CFLAGS -$cf_opt"
			AC_MSG_CHECKING(if CFLAGS option -$cf_opt works)
			if AC_TRY_EVAL(ac_compile); then
				AC_MSG_RESULT(yes)
				cf_save_CFLAGS="$CFLAGS"
			else
				AC_MSG_RESULT(no)
			fi
		done
		CFLAGS="$cf_save_CFLAGS"
	fi


	# RPATH_LIST is a colon-separated list of directories
	test -n "$cf_ld_rpath_opt" && MK_SHARED_LIB="$MK_SHARED_LIB $cf_ld_rpath_opt\${RPATH_LIST}"
	test -z "$RPATH_LIST" && RPATH_LIST="\${libdir}"

	test "$cf_cv_rm_so_locs" = yes && RM_SHARED_OPTS="$RM_SHARED_OPTS so_locations"

	CF_VERBOSE(CC_SHARED_OPTS: $CC_SHARED_OPTS)
	CF_VERBOSE(MK_SHARED_LIB:  $MK_SHARED_LIB)

	AC_SUBST(CC_SHARED_OPTS)
	AC_SUBST(LD_RPATH_OPT)
	AC_SUBST(LD_SHARED_OPTS)
	AC_SUBST(MK_SHARED_LIB)
	AC_SUBST(RM_SHARED_OPTS)

	AC_SUBST(LINK_PROGS)
	AC_SUBST(LINK_TESTS)

	AC_SUBST(EXTRA_LDFLAGS)
	AC_SUBST(LOCAL_LDFLAGS)
	AC_SUBST(LOCAL_LDFLAGS2)

	AC_SUBST(INSTALL_LIB)
	AC_SUBST(RPATH_LIST)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_SHARED_SONAME version: 3 updated: 2008/09/08 18:34:43
dnl ----------------
dnl utility macro for CF_SHARED_OPTS, constructs "$cf_cv_shared_soname" for
dnl substitution into MK_SHARED_LIB string for the "-soname" (or similar)
dnl option.
dnl
dnl $1 is the default that should be used for "$cf_cv_shlib_version".
dnl If missing, use "rel".
define([CF_SHARED_SONAME],
[
	test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=ifelse($1,,rel,$1)
	if test "$cf_cv_shlib_version" = rel; then
		cf_cv_shared_soname='`basename $[@] .${REL_VERSION}`.${ABI_VERSION}'
	else
		cf_cv_shared_soname='`basename $[@]`'
	fi
])
dnl ---------------------------------------------------------------------------
dnl CF_TRY_PKG_CONFIG version: 6 updated: 2020/12/31 10:54:15
dnl -----------------
dnl This is a simple wrapper to use for pkg-config, for libraries which may be
dnl available in that form.
dnl
dnl $1 = package name, which may be a shell variable
dnl $2 = extra logic to use, if any, after updating CFLAGS and LIBS
dnl $3 = logic to use if pkg-config does not have the package
AC_DEFUN([CF_TRY_PKG_CONFIG],[
AC_REQUIRE([CF_PKG_CONFIG])

if test "$PKG_CONFIG" != none && "$PKG_CONFIG" --exists "$1"; then
	CF_VERBOSE(found package $1)
	cf_pkgconfig_incs="`$PKG_CONFIG --cflags "$1" 2>/dev/null`"
	cf_pkgconfig_libs="`$PKG_CONFIG --libs   "$1" 2>/dev/null`"
	CF_VERBOSE(package $1 CFLAGS: $cf_pkgconfig_incs)
	CF_VERBOSE(package $1 LIBS: $cf_pkgconfig_libs)
	CF_ADD_CFLAGS($cf_pkgconfig_incs)
	CF_ADD_LIBS($cf_pkgconfig_libs)
	ifelse([$2],,:,[$2])
else
	cf_pkgconfig_incs=
	cf_pkgconfig_libs=
	ifelse([$3],,:,[$3])
fi
])
dnl ---------------------------------------------------------------------------
dnl CF_TRY_XOPEN_SOURCE version: 4 updated: 2022/09/10 15:16:16
dnl -------------------
dnl If _XOPEN_SOURCE is not defined in the compile environment, check if we
dnl can define it successfully.
AC_DEFUN([CF_TRY_XOPEN_SOURCE],[
AC_CACHE_CHECK(if we should define _XOPEN_SOURCE,cf_cv_xopen_source,[
	AC_TRY_COMPILE(CF__XOPEN_SOURCE_HEAD,CF__XOPEN_SOURCE_BODY,
	[cf_cv_xopen_source=no],
	[cf_save="$CPPFLAGS"
	 CF_APPEND_TEXT(CPPFLAGS,-D_XOPEN_SOURCE=$cf_XOPEN_SOURCE)
	 AC_TRY_COMPILE(CF__XOPEN_SOURCE_HEAD,CF__XOPEN_SOURCE_BODY,
		[cf_cv_xopen_source=no],
		[cf_cv_xopen_source=$cf_XOPEN_SOURCE])
		CPPFLAGS="$cf_save"
	])
])

if test "$cf_cv_xopen_source" != no ; then
	CF_REMOVE_DEFINE(CFLAGS,$CFLAGS,_XOPEN_SOURCE)
	CF_REMOVE_DEFINE(CPPFLAGS,$CPPFLAGS,_XOPEN_SOURCE)
	cf_temp_xopen_source="-D_XOPEN_SOURCE=$cf_cv_xopen_source"
	CF_APPEND_CFLAGS($cf_temp_xopen_source)
fi
])
dnl ---------------------------------------------------------------------------
dnl CF_UPPER version: 5 updated: 2001/01/29 23:40:59
dnl --------
dnl Make an uppercase version of a variable
dnl $1=uppercase($2)
AC_DEFUN([CF_UPPER],
[
$1=`echo "$2" | sed y%abcdefghijklmnopqrstuvwxyz./-%ABCDEFGHIJKLMNOPQRSTUVWXYZ___%`
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_VERBOSE version: 3 updated: 2007/07/29 09:55:12
dnl ----------
dnl Use AC_VERBOSE w/o the warnings
AC_DEFUN([CF_VERBOSE],
[test -n "$verbose" && echo "	$1" 1>&AC_FD_MSG
CF_MSG_LOG([$1])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_VERSION_INFO version: 8 updated: 2021/01/01 13:31:04
dnl ---------------
dnl Define several useful symbols derived from the VERSION file.  A separate
dnl file is preferred to embedding the version numbers in various scripts.
dnl (automake is a textbook-example of why the latter is a bad idea, but there
dnl are others).
dnl
dnl The file contents are:
dnl	libtool-version	release-version	patch-version
dnl or
dnl	release-version
dnl where
dnl	libtool-version (see ?) consists of 3 integers separated by '.'
dnl	release-version consists of a major version and minor version
dnl		separated by '.', optionally followed by a patch-version
dnl		separated by '-'.  The minor version need not be an
dnl		integer (but it is preferred).
dnl	patch-version is an integer in the form yyyymmdd, so ifdef's and
dnl		scripts can easily compare versions.
dnl
dnl If libtool is used, the first form is required, since CF_WITH_LIBTOOL
dnl simply extracts the first field using 'cut -f1'.
dnl
dnl Optional parameters:
dnl $1 = internal name for package
dnl $2 = external name for package
AC_DEFUN([CF_VERSION_INFO],
[
if test -f "$srcdir/VERSION" ; then
	AC_MSG_CHECKING(for package version)

	# if there are not enough fields, cut returns the last one...
	cf_field1=`sed -e '2,$d' "$srcdir/VERSION" |cut -f1`
	cf_field2=`sed -e '2,$d' "$srcdir/VERSION" |cut -f2`
	cf_field3=`sed -e '2,$d' "$srcdir/VERSION" |cut -f3`

	# this is how CF_BUNDLED_INTL uses $VERSION:
	VERSION="$cf_field1"

	VERSION_MAJOR=`echo "$cf_field2" | sed -e 's/\..*//'`
	test -z "$VERSION_MAJOR" && AC_MSG_ERROR(missing major-version)

	VERSION_MINOR=`echo "$cf_field2" | sed -e 's/^[[^.]]*\.//' -e 's/-.*//'`
	test -z "$VERSION_MINOR" && AC_MSG_ERROR(missing minor-version)

	AC_MSG_RESULT(${VERSION_MAJOR}.${VERSION_MINOR})

	AC_MSG_CHECKING(for package patch date)
	VERSION_PATCH=`echo "$cf_field3" | sed -e 's/^[[^-]]*-//'`
	case .$VERSION_PATCH in
	(.)
		AC_MSG_ERROR(missing patch-date $VERSION_PATCH)
		;;
	(.[[0-9]][[0-9]][[0-9]][[0-9]][[0-9]][[0-9]][[0-9]][[0-9]])
		;;
	(*)
		AC_MSG_ERROR(illegal patch-date $VERSION_PATCH)
		;;
	esac
	AC_MSG_RESULT($VERSION_PATCH)
else
	AC_MSG_ERROR(did not find $srcdir/VERSION)
fi

# show the actual data that we have for versions:
CF_VERBOSE(ABI VERSION $VERSION)
CF_VERBOSE(VERSION_MAJOR $VERSION_MAJOR)
CF_VERBOSE(VERSION_MINOR $VERSION_MINOR)
CF_VERBOSE(VERSION_PATCH $VERSION_PATCH)

AC_SUBST(VERSION)
AC_SUBST(VERSION_MAJOR)
AC_SUBST(VERSION_MINOR)
AC_SUBST(VERSION_PATCH)

dnl if a package name is given, define its corresponding version info.  We
dnl need the package name to ensure that the defined symbols are unique.
ifelse($1,,,[
	cf_PACKAGE=$1
	PACKAGE=ifelse($2,,$1,$2)
	AC_DEFINE_UNQUOTED(PACKAGE, "$PACKAGE",[Define to the package-name])
	AC_SUBST(PACKAGE)
	CF_UPPER(cf_PACKAGE,$cf_PACKAGE)
	AC_DEFINE_UNQUOTED(${cf_PACKAGE}_VERSION,"${VERSION_MAJOR}.${VERSION_MINOR}")
	AC_DEFINE_UNQUOTED(${cf_PACKAGE}_PATCHDATE,${VERSION_PATCH})
])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_ABI_VERSION version: 5 updated: 2023/01/07 16:32:06
dnl -------------------
dnl Allow library's ABI to be overridden.  Generally this happens when a
dnl packager has incremented the ABI past that used in the original package,
dnl and wishes to keep doing this.
dnl
dnl $1 is the package name, if any, to derive a corresponding {package}_ABI
dnl symbol.
AC_DEFUN([CF_WITH_ABI_VERSION],[
test -z "$cf_cv_abi_version" && cf_cv_abi_version=0
AC_ARG_WITH(abi-version,
[  --with-abi-version=XXX  override derived ABI version],[
	if test "x$cf_cv_abi_version" != "x$withval"
	then
		AC_MSG_WARN(overriding ABI version $cf_cv_abi_version to $withval)
		case "$cf_cv_rel_version" in
		(5.*)
			cf_cv_rel_version=$withval.0
			;;
		(6.*)
			cf_cv_rel_version=$withval.9	# FIXME: should be 10 as of 6.0 release
			;;
		esac
	fi
	cf_cv_abi_version=$withval])
	CF_NUMBER_SYNTAX($cf_cv_abi_version,ABI version)
ifelse($1,,,[
$1_ABI=$cf_cv_abi_version
])
cf_cv_abi_default=$cf_cv_abi_version
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_DBMALLOC version: 7 updated: 2010/06/21 17:26:47
dnl ----------------
dnl Configure-option for dbmalloc.  The optional parameter is used to override
dnl the updating of $LIBS, e.g., to avoid conflict with subsequent tests.
AC_DEFUN([CF_WITH_DBMALLOC],[
CF_NO_LEAKS_OPTION(dbmalloc,
	[  --with-dbmalloc         test: use Conor Cahill's dbmalloc library],
	[USE_DBMALLOC])

if test "$with_dbmalloc" = yes ; then
	AC_CHECK_HEADER(dbmalloc.h,
		[AC_CHECK_LIB(dbmalloc,[debug_malloc]ifelse([$1],,[],[,$1]))])
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_DMALLOC version: 7 updated: 2010/06/21 17:26:47
dnl ---------------
dnl Configure-option for dmalloc.  The optional parameter is used to override
dnl the updating of $LIBS, e.g., to avoid conflict with subsequent tests.
AC_DEFUN([CF_WITH_DMALLOC],[
CF_NO_LEAKS_OPTION(dmalloc,
	[  --with-dmalloc          test: use Gray Watson's dmalloc library],
	[USE_DMALLOC])

if test "$with_dmalloc" = yes ; then
	AC_CHECK_HEADER(dmalloc.h,
		[AC_CHECK_LIB(dmalloc,[dmalloc_debug]ifelse([$1],,[],[,$1]))])
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_EXPORT_SYMS version: 5 updated: 2023/11/22 20:48:30
dnl -------------------
dnl Use this with libtool to specify the list of symbols that may be exported.
dnl The input file contains one symbol per line; comments work with "#".
dnl
dnl $1 = basename of the ".sym" file (default $PACKAGE)
AC_DEFUN([CF_WITH_EXPORT_SYMS],
[
AC_MSG_CHECKING(if exported-symbols file should be used)
AC_ARG_WITH(export-syms,
	[[  --with-export-syms[=SYM-FILE] limit symbols exported by libtool to those listed in SYM-FILE]],
	[with_export_syms=$withval],
	[with_export_syms=no])
if test "x$with_export_syms" = xyes
then
	with_export_syms='${top_srcdir}/package/ifelse($1,,${PACKAGE},[$1]).sym'
	AC_SUBST(PACKAGE)
fi
AC_MSG_RESULT($with_export_syms)
if test "x$with_export_syms" != xno
then
	EXPORT_SYMS="-export-symbols $with_export_syms"
	AC_SUBST(EXPORT_SYMS)
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_INSTALL_PREFIX version: 4 updated: 2010/10/23 15:52:32
dnl ----------------------
dnl Configure-script option to give a default value for the poorly-chosen name
dnl $(DESTDIR).
AC_DEFUN([CF_WITH_INSTALL_PREFIX],
[
AC_MSG_CHECKING(for install-prefix)
AC_ARG_WITH(install-prefix,
	[  --with-install-prefix=XXX sets DESTDIR, useful for packaging],
	[cf_opt_with_install_prefix=$withval],
	[cf_opt_with_install_prefix=${DESTDIR:-no}])
AC_MSG_RESULT($cf_opt_with_install_prefix)
if test "$cf_opt_with_install_prefix" != no ; then
	CF_PATH_SYNTAX(cf_opt_with_install_prefix)
	DESTDIR=$cf_opt_with_install_prefix
fi
AC_SUBST(DESTDIR)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_LIBTOOL version: 36 updated: 2021/01/01 13:31:04
dnl ---------------
dnl Provide a configure option to incorporate libtool.  Define several useful
dnl symbols for the makefile rules.
dnl
dnl The reference to AC_PROG_LIBTOOL does not normally work, since it uses
dnl macros from libtool.m4 which is in the aclocal directory of automake.
dnl Following is a simple script which turns on the AC_PROG_LIBTOOL macro.
dnl But that still does not work properly since the macro is expanded outside
dnl the CF_WITH_LIBTOOL macro:
dnl
dnl	#!/bin/sh
dnl	ACLOCAL=`aclocal --print-ac-dir`
dnl	if test -z "$ACLOCAL" ; then
dnl		echo cannot find aclocal directory
dnl		exit 1
dnl	elif test ! -f $ACLOCAL/libtool.m4 ; then
dnl		echo cannot find libtool.m4 file
dnl		exit 1
dnl	fi
dnl
dnl	LOCAL=aclocal.m4
dnl	ORIG=aclocal.m4.orig
dnl
dnl	trap "mv $ORIG $LOCAL" 0 1 2 3 15
dnl	rm -f $ORIG
dnl	mv $LOCAL $ORIG
dnl
dnl	# sed the LIBTOOL= assignment to omit the current directory?
dnl	sed -e 's/^LIBTOOL=.*/LIBTOOL=${LIBTOOL:-libtool}/' $ACLOCAL/libtool.m4 >>$LOCAL
dnl	cat $ORIG >>$LOCAL
dnl
dnl	autoconf-257 $*
dnl
AC_DEFUN([CF_WITH_LIBTOOL],
[
AC_REQUIRE([CF_DISABLE_LIBTOOL_VERSION])
ifdef([AC_PROG_LIBTOOL],,[
LIBTOOL=
])
# common library maintenance symbols that are convenient for libtool scripts:
LIB_CREATE='${AR} -cr'
LIB_OBJECT='${OBJECTS}'
LIB_SUFFIX=.a
LIB_PREP="$RANLIB"

# symbols used to prop libtool up to enable it to determine what it should be
# doing:
LIB_CLEAN=
LIB_COMPILE=
LIB_LINK='${CC}'
LIB_INSTALL=
LIB_UNINSTALL=

AC_MSG_CHECKING(if you want to build libraries with libtool)
AC_ARG_WITH(libtool,
	[  --with-libtool          generate libraries with libtool],
	[with_libtool=$withval],
	[with_libtool=no])
AC_MSG_RESULT($with_libtool)
if test "$with_libtool" != "no"; then
ifdef([AC_PROG_LIBTOOL],[
	# missing_content_AC_PROG_LIBTOOL{{
	AC_PROG_LIBTOOL
	# missing_content_AC_PROG_LIBTOOL}}
],[
	if test "$with_libtool" != "yes" ; then
		CF_PATH_SYNTAX(with_libtool)
		LIBTOOL=$with_libtool
	else
		AC_CHECK_TOOLS(LIBTOOL,[libtool glibtool],none)
		CF_LIBTOOL_VERSION
		if test -z "$cf_cv_libtool_version" && test "$LIBTOOL" = libtool
		then
			CF_FORGET_TOOL(LIBTOOL)
			AC_CHECK_TOOLS(LIBTOOL,[glibtool],none)
			CF_LIBTOOL_VERSION
		fi
	fi
	if test -z "$LIBTOOL" ; then
		AC_MSG_ERROR(Cannot find libtool)
	fi
])dnl
	LIB_CREATE='${LIBTOOL} --mode=link ${CC} -rpath ${libdir} ${LIBTOOL_VERSION} `cut -f1 ${top_srcdir}/VERSION` ${LIBTOOL_OPTS} ${LT_UNDEF} $(LIBS) -o'
	LIB_OBJECT='${OBJECTS:.o=.lo}'
	LIB_SUFFIX=.la
	LIB_CLEAN='${LIBTOOL} --mode=clean'
	LIB_COMPILE='${LIBTOOL} --mode=compile'
	LIB_LINK='${LIBTOOL} --mode=link ${CC} ${LIBTOOL_OPTS}'
	LIB_INSTALL='${LIBTOOL} --mode=install'
	LIB_UNINSTALL='${LIBTOOL} --mode=uninstall'
	LIB_PREP=:

	CF_CHECK_LIBTOOL_VERSION

	# special hack to add -no-undefined (which libtool should do for itself)
	LT_UNDEF=
	case "$cf_cv_system_name" in
	(cygwin*|msys*|mingw32*|os2*|uwin*|aix[[4-7]])
		LT_UNDEF=-no-undefined
		;;
	esac
	AC_SUBST([LT_UNDEF])

	# special hack to add --tag option for C++ compiler
	case "$cf_cv_libtool_version" in
	(1.[[5-9]]*|[[2-9]].[[0-9.a-z]]*)
		LIBTOOL_CXX="$LIBTOOL --tag=CXX"
		LIBTOOL="$LIBTOOL --tag=CC"
		;;
	(*)
		LIBTOOL_CXX="$LIBTOOL"
		;;
	esac
else
	LIBTOOL=""
	LIBTOOL_CXX=""
fi

test -z "$LIBTOOL" && ECHO_LT=

AC_SUBST(LIBTOOL)
AC_SUBST(LIBTOOL_CXX)
AC_SUBST(LIBTOOL_OPTS)

AC_SUBST(LIB_CREATE)
AC_SUBST(LIB_OBJECT)
AC_SUBST(LIB_SUFFIX)
AC_SUBST(LIB_PREP)

AC_SUBST(LIB_CLEAN)
AC_SUBST(LIB_COMPILE)
AC_SUBST(LIB_LINK)
AC_SUBST(LIB_INSTALL)
AC_SUBST(LIB_UNINSTALL)

])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_LIBTOOL_OPTS version: 6 updated: 2023/11/22 20:48:30
dnl --------------------
dnl Allow user to pass additional libtool options into the library creation
dnl and link steps.  The main use for this is to do something like
dnl	./configure --with-libtool-opts=-static
dnl to get the same behavior as automake-flavored
dnl	./configure --enable-static
AC_DEFUN([CF_WITH_LIBTOOL_OPTS],[
AC_MSG_CHECKING(for additional libtool options)
AC_ARG_WITH(libtool-opts,
	[[  --with-libtool-opts[=XXX] give libtool additional options XXX]],
	[with_libtool_opts=$withval],
	[with_libtool_opts=no])
AC_MSG_RESULT($with_libtool_opts)

case .$with_libtool_opts in
(.yes|.no|.)
	;;
(*)
	LIBTOOL_OPTS="$LIBTOOL_OPTS $with_libtool_opts"
	;;
esac

AC_SUBST(LIBTOOL_OPTS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_REL_VERSION version: 2 updated: 2023/05/06 18:18:18
dnl -------------------
dnl Allow library's release-version to be overridden.  Generally this happens when a
dnl packager has incremented the release-version past that used in the original package,
dnl and wishes to keep doing this.
dnl
dnl $1 is the package name, if any, to derive corresponding {package}_MAJOR
dnl and {package}_MINOR symbols
dnl symbol.
AC_DEFUN([CF_WITH_REL_VERSION],[
test -z "$cf_cv_rel_version" && cf_cv_rel_version=0.0
AC_ARG_WITH(rel-version,
[  --with-rel-version=XXX  override derived release version],
[AC_MSG_WARN(overriding release version $cf_cv_rel_version to $withval)
 cf_cv_rel_version=$withval])
ifelse($1,,[
 CF_NUMBER_SYNTAX($cf_cv_rel_version,Release version)
],[
 $1_MAJOR=`echo "$cf_cv_rel_version" | sed -e 's/\..*//'`
 $1_MINOR=`echo "$cf_cv_rel_version" | sed -e 's/^[[^.]]*//' -e 's/^\.//' -e 's/\..*//'`
 test -n "$1_MINOR" || $1_MINOR=0
 CF_NUMBER_SYNTAX([$]$1_MAJOR,Release major-version)
 CF_NUMBER_SYNTAX([$]$1_MINOR,Release minor-version)
])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_SHARED_OR_LIBTOOL version: 7 updated: 2014/11/02 16:11:49
dnl -------------------------
dnl Provide shared libraries using either autoconf macros (--with-shared) or
dnl using the external libtool script (--with-libtool).
dnl
dnl $1 = program name (all caps preferred)
dnl $1 = release version
dnl $2 = ABI version
define([CF_WITH_SHARED_OR_LIBTOOL],[

REL_VERSION=$2
ABI_VERSION=$3
cf_cv_rel_version=$REL_VERSION
AC_SUBST(ABI_VERSION)
AC_SUBST(REL_VERSION)

CF_WITH_REL_VERSION($1)
CF_WITH_ABI_VERSION

LIB_MODEL=static
DFT_LWR_MODEL=$LIB_MODEL
LIBTOOL_MAKE="#"

# use to comment-out makefile lines
MAKE_NORMAL=
MAKE_STATIC=
MAKE_SHARED="#"
MAKE_DLLS="#"

shlibdir=$libdir
AC_SUBST(shlibdir)

CF_WITH_LIBTOOL

LIB_CREATE="$LIB_CREATE \[$]@"

if test "$with_libtool" = "yes" ; then
	OBJEXT="lo"
	LIB_MODEL=libtool
	DFT_LWR_MODEL=$LIB_MODEL
	LIBTOOL_MAKE=
	CF_WITH_LIBTOOL_OPTS
	CF_WITH_EXPORT_SYMS
	MAKE_NORMAL="#"
	MAKE_STATIC="#"
	MAKE_SHARED=
else
	AC_MSG_CHECKING(if you want to build shared libraries)
	AC_ARG_WITH(shared,
		[  --with-shared           generate shared-libraries],
		[with_shared=$withval],
		[with_shared=no])
	AC_MSG_RESULT($with_shared)
	if test "$with_shared" = "yes" ; then
		LIB_MODEL=shared
		DFT_LWR_MODEL=$LIB_MODEL
		CF_SHARED_OPTS
		CF_WITH_VERSIONED_SYMS
		LIB_PREP=:
		LIB_CREATE="[$]MK_SHARED_LIB"
		CFLAGS="$CFLAGS $CC_SHARED_OPTS"
		MAKE_NORMAL="#"
		MAKE_STATIC="#"
		MAKE_SHARED=
	fi
fi

LIB_SUFFIX=
CF_LIB_SUFFIX($LIB_MODEL, DFT_LIB_SUFFIX, DFT_DEP_SUFFIX)
LIB_SUFFIX=$DFT_LIB_SUFFIX

AC_SUBST(DFT_LWR_MODEL)
AC_SUBST(DFT_LIB_SUFFIX)
AC_SUBST(DFT_DEP_SUFFIX)
AC_SUBST(LIB_MODEL)

AC_SUBST(LIBTOOL_MAKE)

AC_SUBST(MAKE_DLLS)
AC_SUBST(MAKE_NORMAL)
AC_SUBST(MAKE_SHARED)
AC_SUBST(MAKE_STATIC)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_VALGRIND version: 1 updated: 2006/12/14 18:00:21
dnl ----------------
AC_DEFUN([CF_WITH_VALGRIND],[
CF_NO_LEAKS_OPTION(valgrind,
	[  --with-valgrind         test: use valgrind],
	[USE_VALGRIND])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_VERSIONED_SYMS version: 13 updated: 2023/12/03 09:24:04
dnl ----------------------
dnl Use this when building shared library with ELF, to markup symbols with the
dnl version identifier from the given input file.  Generally that identifier is
dnl the same as the SONAME at which the symbol was first introduced.
dnl
dnl $1 = basename of the ".map" file (default $PACKAGE)
AC_DEFUN([CF_WITH_VERSIONED_SYMS],
[AC_REQUIRE([AC_PROG_FGREP])dnl
AC_REQUIRE([AC_PROG_EGREP])dnl

AC_MSG_CHECKING(if versioned-symbols file should be used)
AC_ARG_WITH(versioned-syms,
	[[  --with-versioned-syms[=MAP-FILE] version ELF shared library symbols per MAP-FILE]],
	[with_versioned_syms=$withval],
	[with_versioned_syms=no])
case "x$with_versioned_syms" in
(xyes)
	with_versioned_syms='${top_srcdir}/package/ifelse($1,,${PACKAGE},[$1]).map'
	AC_SUBST(PACKAGE)
	;;
(xno)
	;;
(x/*)
	test -f "$with_versioned_syms" || AC_MSG_ERROR(expected a filename: $with_versioned_syms)
	;;
(*)
	test -f "$with_versioned_syms" || AC_MSG_ERROR(expected a filename: $with_versioned_syms)
	with_versioned_syms=`pwd`/"$with_versioned_syms"
	;;
esac
AC_MSG_RESULT($with_versioned_syms)

RESULTING_SYMS=
VERSIONED_SYMS=
WILDCARD_SYMS=

if test "x$with_versioned_syms" != xno
then
	RESULTING_SYMS=$with_versioned_syms
	case "x$MK_SHARED_LIB" in
	(*-Wl,*)
		VERSIONED_SYMS="-Wl,--version-script,\${RESULTING_SYMS}"
		MK_SHARED_LIB=`echo "$MK_SHARED_LIB" | sed -e "s%-Wl,%\\[$]{VERSIONED_SYMS} -Wl,%"`
		CF_VERBOSE(MK_SHARED_LIB:  $MK_SHARED_LIB)
		;;
	(*-dy\ *)
		VERSIONED_SYMS="-Wl,-M,\${RESULTING_SYMS}"
		MK_SHARED_LIB=`echo "$MK_SHARED_LIB" | sed -e "s%-dy%\\[$]{VERSIONED_SYMS} -dy%"`
		CF_VERBOSE(MK_SHARED_LIB:  $MK_SHARED_LIB)
		;;
	(*)
		AC_MSG_WARN(this system does not support versioned-symbols)
		;;
	esac

	# Linux ld can selectively override scope, e.g., of symbols beginning with
	# "_" by first declaring some as global, and then using a wildcard to
	# declare the others as local.  Some other loaders cannot do this.  Check
	# by constructing a (very) simple shared library and inspecting its
	# symbols.
	if test "x$VERSIONED_SYMS" != "x"
	then
		AC_MSG_CHECKING(if wildcards can be used to selectively omit symbols)
		WILDCARD_SYMS=no

		# make sources
		rm -f conftest.*

		cat >conftest.ver <<EOF
module_1.0 {
global:
	globalf1;
local:
	localf1;
};
module_2.0 {
global:
	globalf2;
local:
	localf2;
	_*;
} module_1.0;
submodule_1.0 {
global:
	subglobalf1;
	_ismissing;
local:
	sublocalf1;
};
submodule_2.0 {
global:
	subglobalf2;
local:
	sublocalf2;
	_*;
} submodule_1.0;
EOF
		cat >conftest.$ac_ext <<EOF
#line __oline__ "configure"
extern int _ismissing(void);    int _ismissing(void)  { return 1; }
extern int _localf1(void);      int _localf1(void)    { return 1; }
extern int _localf2(void);      int _localf2(void)    { return 2; }
extern int globalf1(void);      int globalf1(void)    { return 1; }
extern int globalf2(void);      int globalf2(void)    { return 2; }
extern int _sublocalf1(void);   int _sublocalf1(void) { return 1; }
extern int _sublocalf2(void);   int _sublocalf2(void) { return 2; }
extern int subglobalf1(void);   int subglobalf1(void) { return 1; }
extern int subglobalf2(void);   int subglobalf2(void) { return 2; }
EOF
		cat >conftest.mk <<EOF
CC=${CC}
CFLAGS=${CFLAGS}
CPPFLAGS=${CPPFLAGS}
LDFLAGS=${LDFLAGS}
LIBS=${LIBS}
VERSIONED_SYMS=${VERSIONED_SYMS}
RESULTING_SYMS=conftest.ver
MK_SHARED_LIB=${MK_SHARED_LIB}
conftest.so: conftest.$ac_cv_objext
		\$(MK_SHARED_LIB) conftest.$ac_cv_objext
EOF

		# compile source, make library
		if make -f conftest.mk 2>&AC_FD_CC >/dev/null
		then
			# test for missing symbol in either Data or Text section
			cf_missing="`nm -P conftest.so 2>&AC_FD_CC |${FGREP-fgrep} _ismissing | ${EGREP-egrep} '[[ 	]][[DT]][[ 	]]'`"
			test -n "$cf_missing" && WILDCARD_SYMS=yes
		fi
		AC_MSG_RESULT($WILDCARD_SYMS)
		rm -f conftest.*
	fi
fi
AC_SUBST(RESULTING_SYMS)
AC_SUBST(VERSIONED_SYMS)
AC_SUBST(WILDCARD_SYMS)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_WITH_XPM version: 4 updated: 2023/11/23 06:40:35
dnl -----------
dnl Test for Xpm library, update compiler/loader flags if it is wanted and
dnl found.
dnl
dnl Also sets ICON_SUFFIX
AC_DEFUN([CF_WITH_XPM],
[
ICON_SUFFIX=.xbm

cf_save_cppflags="${CPPFLAGS}"
cf_save_ldflags="${LDFLAGS}"

AC_MSG_CHECKING(if you want to use the Xpm library for colored icon)
AC_ARG_WITH(xpm,
[[  --with-xpm[=DIR]        use Xpm library for colored icon, may specify path]],
	[cf_Xpm_library="$withval"],
	[cf_Xpm_library=yes])
AC_MSG_RESULT($cf_Xpm_library)

if test "$cf_Xpm_library" != no ; then
    if test "$cf_Xpm_library" != yes ; then
	CPPFLAGS="$CPPFLAGS -I$withval/include"
	LDFLAGS="$LDFLAGS -L$withval/lib"
    fi
    AC_CHECK_HEADER(X11/xpm.h,[
	AC_CHECK_LIB(Xpm, XpmCreatePixmapFromData,[
	    AC_DEFINE(HAVE_LIBXPM,1,[Define to 1 if we should use Xpm library])
	    ICON_SUFFIX=.xpm
	    LIBS="-lXpm $LIBS"],
	    [CPPFLAGS="${cf_save_cppflags}" LDFLAGS="${cf_save_ldflags}"],
	    [-lX11 $X_LIBS])],
	[CPPFLAGS="${cf_save_cppflags}" LDFLAGS="${cf_save_ldflags}"])
fi

AC_SUBST(ICON_SUFFIX)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_XOPEN_SOURCE version: 67 updated: 2023/09/06 18:55:27
dnl ---------------
dnl Try to get _XOPEN_SOURCE defined properly that we can use POSIX functions,
dnl or adapt to the vendor's definitions to get equivalent functionality,
dnl without losing the common non-POSIX features.
dnl
dnl Parameters:
dnl	$1 is the nominal value for _XOPEN_SOURCE
dnl	$2 is the nominal value for _POSIX_C_SOURCE
dnl
dnl The default case prefers _XOPEN_SOURCE over _POSIX_C_SOURCE if the
dnl implementation predefines it, because X/Open and most implementations agree
dnl that the latter is a legacy or "aligned" value.
dnl
dnl Because _XOPEN_SOURCE is preferred, if defining _POSIX_C_SOURCE turns
dnl that off, then refrain from setting _POSIX_C_SOURCE explicitly.
dnl
dnl References:
dnl https://pubs.opengroup.org/onlinepubs/007904975/functions/xsh_chap02_02.html
dnl https://docs.oracle.com/cd/E19253-01/816-5175/standards-5/index.html
dnl https://www.gnu.org/software/libc/manual/html_node/Feature-Test-Macros.html
AC_DEFUN([CF_XOPEN_SOURCE],[
AC_REQUIRE([AC_CANONICAL_HOST])
AC_REQUIRE([CF_POSIX_VISIBLE])

if test "$cf_cv_posix_visible" = no; then

cf_XOPEN_SOURCE=ifelse([$1],,500,[$1])
cf_POSIX_C_SOURCE=ifelse([$2],,199506L,[$2])
cf_xopen_source=

case "$host_os" in
(aix[[4-7]]*)
	cf_xopen_source="-D_ALL_SOURCE"
	;;
(darwin[[0-8]].*)
	cf_xopen_source="-D_APPLE_C_SOURCE"
	;;
(darwin*)
	cf_xopen_source="-D_DARWIN_C_SOURCE"
	cf_XOPEN_SOURCE=
	;;
(freebsd*|dragonfly*|midnightbsd*)
	# 5.x headers associate
	#	_XOPEN_SOURCE=600 with _POSIX_C_SOURCE=200112L
	#	_XOPEN_SOURCE=500 with _POSIX_C_SOURCE=199506L
	cf_POSIX_C_SOURCE=200112L
	cf_XOPEN_SOURCE=600
	cf_xopen_source="-D_BSD_TYPES -D__BSD_VISIBLE -D_POSIX_C_SOURCE=$cf_POSIX_C_SOURCE -D_XOPEN_SOURCE=$cf_XOPEN_SOURCE"
	;;
(hpux11*)
	cf_xopen_source="-D_HPUX_SOURCE -D_XOPEN_SOURCE=500"
	;;
(hpux*)
	cf_xopen_source="-D_HPUX_SOURCE"
	;;
(irix[[56]].*)
	cf_xopen_source="-D_SGI_SOURCE"
	cf_XOPEN_SOURCE=
	;;
(linux*gnu|linux*gnuabi64|linux*gnuabin32|linux*gnueabi|linux*gnueabihf|linux*gnux32|uclinux*|gnu*|mint*|k*bsd*-gnu|cygwin|msys|mingw*|linux*uclibc)
	CF_GNU_SOURCE($cf_XOPEN_SOURCE)
	;;
(minix*)
	cf_xopen_source="-D_NETBSD_SOURCE" # POSIX.1-2001 features are ifdef'd with this...
	;;
(mirbsd*)
	# setting _XOPEN_SOURCE or _POSIX_SOURCE breaks <sys/select.h> and other headers which use u_int / u_short types
	cf_XOPEN_SOURCE=
	CF_POSIX_C_SOURCE($cf_POSIX_C_SOURCE)
	;;
(netbsd*)
	cf_xopen_source="-D_NETBSD_SOURCE" # setting _XOPEN_SOURCE breaks IPv6 for lynx on NetBSD 1.6, breaks xterm, is not needed for ncursesw
	;;
(openbsd[[6-9]]*)
	# OpenBSD 6.x has broken locale support, both compile-time and runtime.
	# see https://www.mail-archive.com/bugs@openbsd.org/msg13200.html
	# Abusing the conformance level is a workaround.
	AC_MSG_WARN(this system does not provide usable locale support)
	cf_xopen_source="-D_BSD_SOURCE"
	cf_XOPEN_SOURCE=700
	;;
(openbsd[[4-5]]*)
	# setting _XOPEN_SOURCE lower than 500 breaks g++ compile with wchar.h, needed for ncursesw
	cf_xopen_source="-D_BSD_SOURCE"
	cf_XOPEN_SOURCE=600
	;;
(openbsd*)
	# setting _XOPEN_SOURCE breaks xterm on OpenBSD 2.8, is not needed for ncursesw
	;;
(osf[[45]]*)
	cf_xopen_source="-D_OSF_SOURCE"
	;;
(nto-qnx*)
	cf_xopen_source="-D_QNX_SOURCE"
	;;
(sco*)
	# setting _XOPEN_SOURCE breaks Lynx on SCO Unix / OpenServer
	;;
(solaris2.*)
	cf_xopen_source="-D__EXTENSIONS__"
	cf_cv_xopen_source=broken
	;;
(sysv4.2uw2.*) # Novell/SCO UnixWare 2.x (tested on 2.1.2)
	cf_XOPEN_SOURCE=
	cf_POSIX_C_SOURCE=
	;;
(*)
	CF_TRY_XOPEN_SOURCE
	cf_save_xopen_cppflags="$CPPFLAGS"
	CF_POSIX_C_SOURCE($cf_POSIX_C_SOURCE)
	# Some of these niche implementations use copy/paste, double-check...
	if test "$cf_cv_xopen_source" = no ; then
		CF_VERBOSE(checking if _POSIX_C_SOURCE interferes with _XOPEN_SOURCE)
		AC_TRY_COMPILE(CF__XOPEN_SOURCE_HEAD,CF__XOPEN_SOURCE_BODY,,[
			AC_MSG_WARN(_POSIX_C_SOURCE definition is not usable)
			CPPFLAGS="$cf_save_xopen_cppflags"])
	fi
	;;
esac

if test -n "$cf_xopen_source" ; then
	CF_APPEND_CFLAGS($cf_xopen_source,true)
fi

dnl In anything but the default case, we may have system-specific setting
dnl which is still not guaranteed to provide all of the entrypoints that
dnl _XOPEN_SOURCE would yield.
if test -n "$cf_XOPEN_SOURCE" && test -z "$cf_cv_xopen_source" ; then
	AC_MSG_CHECKING(if _XOPEN_SOURCE really is set)
	AC_TRY_COMPILE([#include <stdlib.h>],[
#ifndef _XOPEN_SOURCE
#error _XOPEN_SOURCE is not defined
#endif],
	[cf_XOPEN_SOURCE_set=yes],
	[cf_XOPEN_SOURCE_set=no])
	AC_MSG_RESULT($cf_XOPEN_SOURCE_set)
	if test "$cf_XOPEN_SOURCE_set" = yes
	then
		AC_TRY_COMPILE([#include <stdlib.h>],[
#if (_XOPEN_SOURCE - 0) < $cf_XOPEN_SOURCE
#error (_XOPEN_SOURCE - 0) < $cf_XOPEN_SOURCE
#endif],
		[cf_XOPEN_SOURCE_set_ok=yes],
		[cf_XOPEN_SOURCE_set_ok=no])
		if test "$cf_XOPEN_SOURCE_set_ok" = no
		then
			AC_MSG_WARN(_XOPEN_SOURCE is lower than requested)
		fi
	else
		CF_TRY_XOPEN_SOURCE
	fi
fi
fi # cf_cv_posix_visible
])
dnl ---------------------------------------------------------------------------
dnl CF_X_EXT version: 3 updated: 2010/06/02 05:03:05
dnl --------
AC_DEFUN([CF_X_EXT],[
CF_TRY_PKG_CONFIG(Xext,,[
	AC_CHECK_LIB(Xext,XextCreateExtension,
		[CF_ADD_LIB(Xext)])])
])dnl
dnl ---------------------------------------------------------------------------
dnl CF_X_TOOLKIT version: 27 updated: 2023/01/11 04:05:23
dnl ------------
dnl Check for X Toolkit libraries
AC_DEFUN([CF_X_TOOLKIT],
[
AC_REQUIRE([AC_PATH_XTRA])
AC_REQUIRE([CF_CHECK_CACHE])

# OSX is schizoid about who owns /usr/X11 (old) versus /opt/X11 (new) (and
# in some cases has installed dummy files in the former, other cases replaced
# it with a link to the new location).  This complicates the configure script.
# Check for that pitfall, and recover using pkg-config
#
# If none of these are set, the configuration is almost certainly broken.
if test -z "${X_CFLAGS}${X_PRE_LIBS}${X_LIBS}${X_EXTRA_LIBS}"
then
	CF_TRY_PKG_CONFIG(x11,,[AC_MSG_WARN(unable to find X11 library)])
	CF_TRY_PKG_CONFIG(ice,,[AC_MSG_WARN(unable to find ICE library)])
	CF_TRY_PKG_CONFIG(sm,,[AC_MSG_WARN(unable to find SM library)])
	CF_TRY_PKG_CONFIG(xt,,[AC_MSG_WARN(unable to find Xt library)])
else
	LIBS="$X_PRE_LIBS $LIBS $X_EXTRA_LIBS"
fi

cf_have_X_LIBS=no

CF_TRY_PKG_CONFIG(xt,[

	case "x$LIBS" in
	(*-lX11*)
		;;
	(*)
# we have an "xt" package, but it may omit Xt's dependency on X11
AC_CACHE_CHECK(for usable X dependency,cf_cv_xt_x11_compat,[
AC_TRY_LINK([
$ac_includes_default
#include <X11/Xlib.h>
],[
	int rc1 = XDrawLine((Display*) 0, (Drawable) 0, (GC) 0, 0, 0, 0, 0);
	int rc2 = XClearWindow((Display*) 0, (Window) 0);
	int rc3 = XMoveWindow((Display*) 0, (Window) 0, 0, 0);
	int rc4 = XMoveResizeWindow((Display*)0, (Window)0, 0, 0, 0, 0);
],[cf_cv_xt_x11_compat=yes],[cf_cv_xt_x11_compat=no])])
		if test "$cf_cv_xt_x11_compat" = no
		then
			CF_VERBOSE(work around broken X11 dependency)
			# 2010/11/19 - good enough until a working Xt on Xcb is delivered.
			CF_TRY_PKG_CONFIG(x11,,[CF_ADD_LIB_AFTER(-lXt,-lX11)])
		fi
		;;
	esac

AC_CACHE_CHECK(for usable X Toolkit package,cf_cv_xt_ice_compat,[
AC_TRY_LINK([
$ac_includes_default
#include <X11/Shell.h>
],[int num = IceConnectionNumber(0); (void) num
],[cf_cv_xt_ice_compat=yes],[cf_cv_xt_ice_compat=no])])

	if test "$cf_cv_xt_ice_compat" = no
	then
		# workaround for broken ".pc" files used for X Toolkit.
		case "x$X_PRE_LIBS" in
		(*-lICE*)
			case "x$LIBS" in
			(*-lICE*)
				;;
			(*)
				CF_VERBOSE(work around broken ICE dependency)
				CF_TRY_PKG_CONFIG(ice,
					[CF_TRY_PKG_CONFIG(sm)],
					[CF_ADD_LIB_AFTER(-lXt,$X_PRE_LIBS)])
				;;
			esac
			;;
		esac
	fi

	cf_have_X_LIBS=yes
],[

	LDFLAGS="$X_LIBS $LDFLAGS"
	CF_CHECK_CFLAGS($X_CFLAGS)

	AC_CHECK_FUNC(XOpenDisplay,,[
	AC_CHECK_LIB(X11,XOpenDisplay,
		[CF_ADD_LIB(X11)])])

	AC_CHECK_FUNC(XtAppInitialize,,[
	AC_CHECK_LIB(Xt, XtAppInitialize,
		[AC_DEFINE(HAVE_LIBXT,1,[Define to 1 if we can compile with the Xt library])
		 cf_have_X_LIBS=Xt
		 LIBS="-lXt $LIBS"])])
])

if test "$cf_have_X_LIBS" = no ; then
	AC_MSG_WARN(
[Unable to successfully link X Toolkit library (-lXt) with
test program.  You will have to check and add the proper libraries by hand
to makefile.])
fi
])dnl
dnl ---------------------------------------------------------------------------
dnl CF__ADD_SHLIB_RULES version: 6 updated: 2016/04/21 21:07:50
dnl -------------------
dnl Append rules for creating, installing, uninstalling and cleaning library.
dnl In particular, this is needed for shared libraries since there are symbolic
dnl links which depend on configuration choices.
dnl
dnl The logic is controlled by these cache variables:
dnl $cf_cv_do_symlinks
dnl $cf_cv_shlib_version
dnl
dnl The macro uses variables set by CF__DEFINE_SHLIB_VARS
dnl
dnl $1 = makefile to append to
dnl $2 = model (static, shared, libtool)
dnl $3 = objects (dependencies)
dnl $4 = additional libraries needed to link the shared library
define([CF__ADD_SHLIB_RULES],[

CF__DEFINE_LIB_TARGET

case x$2 in
(xlibtool|xshared)
	cf_libdeps="ifelse($4,,,[$4])"
	;;
(x*)
	cf_libdeps=
	;;
esac

cat >>$1 <<CF_EOF

# generated by CF__ADD_SHLIB_RULES
# libmodel: $2
# symlinks: $cf_cv_do_symlinks
# shlibver: $cf_cv_shlib_version

CF_EOF

cat >>$1 <<CF_EOF
$cf_libname :: \\
CF_EOF

cat >>$1 <<CF_EOF
		$3
	@echo linking \[$]@
	\$(LIBTOOL_CREATE) $3 $cf_libdeps
CF_EOF

if test "x$cf_cv_do_symlinks" = xyes
then
cat >>$1 <<CF_EOF
	\$(LN_S) $cf_libname $cf_liblink
	\$(LN_S) $cf_liblink $cf_libroot
CF_EOF
fi

cat >>$1 <<CF_EOF

install \\
install.libs :: \$(DESTDIR)\$(libdir)/$cf_libname

\$(DESTDIR)\$(libdir)/$cf_libname :: \\
		\$(DESTDIR)\$(libdir) \\
		$3
	@echo linking \[$]@
	\$(LIBTOOL_CREATE) $3 $cf_libdeps
CF_EOF

if test "x$cf_cv_do_symlinks" = xyes
then
cat >>$1 <<CF_EOF
	cd \$(DESTDIR)\$(libdir) && (\$(LN_S) $cf_libname $cf_liblink; \$(LN_S) $cf_liblink $cf_libroot; )
CF_EOF
fi

if test x$2 = xshared
then
cat >>$1 <<CF_EOF
	- \$(SHELL) -c "if test -z "\$(DESTDIR)" ; then /sbin/ldconfig; fi"
CF_EOF
fi

cat >>$1 <<CF_EOF

uninstall \\
uninstall.libs ::
	@echo uninstalling \$(DESTDIR)\$(libdir)/$cf_libname
CF_EOF

if test "x$cf_cv_do_symlinks" = xyes
then
cat >>$1 <<CF_EOF
	-rm -f \$(DESTDIR)\$(libdir)/$cf_libroot
	-rm -f \$(DESTDIR)\$(libdir)/$cf_liblink
CF_EOF
fi

cat >>$1 <<CF_EOF
	-rm -f \$(DESTDIR)\$(libdir)/$cf_libname

clean \\
clean.libs ::
CF_EOF

if test "x$cf_cv_do_symlinks" = xyes
then
cat >>$1 <<CF_EOF
	-rm -f $cf_libroot
	-rm -f $cf_liblink
CF_EOF
fi

cat >>$1 <<CF_EOF
	-rm -f $cf_libname

mostlyclean::
	-rm -f $3
# end generated by CF__ADD_SHLIB_RULES
CF_EOF
])dnl
dnl ---------------------------------------------------------------------------
dnl CF__DEFINE_LIB_TARGET version: 2 updated: 2015/05/10 19:52:14
dnl ---------------------
define([CF__DEFINE_LIB_TARGET],[
cf_libname=\${LIB_BASENAME}
cf_liblink=$cf_libname
cf_libroot=$cf_libname

if test "x$cf_cv_do_symlinks" = xyes
then
	case "x$cf_cv_shlib_version" in
	(xrel)
		cf_liblink="\${LIB_ABI_NAME}"
		cf_libname="\${LIB_REL_NAME}"
		;;
	(xabi)
		cf_liblink="\${LIB_REL_NAME}"
		cf_libname="\${LIB_ABI_NAME}"
		;;
	esac
fi
LIB_TARGET=$cf_libname
])dnl
dnl ---------------------------------------------------------------------------
dnl CF__DEFINE_SHLIB_VARS version: 4 updated: 2015/09/28 17:49:10
dnl ---------------------
dnl Substitute makefile variables useful for CF__ADD_SHLIB_RULES.
dnl
dnl The substitution requires these variables:
dnl		LIB_PREFIX - "lib"
dnl		LIB_ROOTNAME - "foo"
dnl		LIB_SUFFIX - ".so"
dnl		REL_VERSION - "5.0"
dnl		ABI_VERSION - "4.2.4"
define([CF__DEFINE_SHLIB_VARS],[
CF__DEFINE_LIB_TARGET
SET_SHLIB_VARS="# begin CF__DEFINE_SHLIB_VARS\\
LIB_BASENAME	= \${LIB_PREFIX}\${LIB_ROOTNAME}\${LIB_SUFFIX}\\
LIB_REL_NAME	= \${LIB_BASENAME}.\${REL_VERSION}\\
LIB_ABI_NAME	= \${LIB_BASENAME}.\${ABI_VERSION}\\
LIB_TARGET	= $LIB_TARGET\\
RM_SHARED_OPTS	= $RM_SHARED_OPTS\\
# end CF__DEFINE_SHLIB_VARS"
AC_SUBST(SET_SHLIB_VARS)
AC_SUBST(LIB_TARGET)
])dnl
dnl ---------------------------------------------------------------------------
dnl CF__INIT_SHLIB_RULES version: 2 updated: 2013/07/27 17:38:32
dnl --------------------
dnl The third parameter to AC_OUTPUT, used to pass variables needed for
dnl CF__ADD_SHLIB_RULES.
define([CF__INIT_SHLIB_RULES],[
ABI_VERSION="$ABI_VERSION"
REL_VERSION="$REL_VERSION"
LIB_MODEL="$LIB_MODEL"
LIB_PREFIX="$LIB_PREFIX"
LIB_ROOTNAME="$LIB_ROOTNAME"
DFT_DEP_SUFFIX="$DFT_DEP_SUFFIX"
RM_SHARED_OPTS="$RM_SHARED_OPTS"
cf_cv_do_symlinks="$cf_cv_do_symlinks"
cf_cv_shlib_version="$cf_cv_shlib_version"
])
dnl ---------------------------------------------------------------------------
dnl CF__XOPEN_SOURCE_BODY version: 2 updated: 2023/02/18 17:41:25
dnl ---------------------
dnl body of test when test-compiling for _XOPEN_SOURCE check
define([CF__XOPEN_SOURCE_BODY],
[
#ifndef _XOPEN_SOURCE
#error _XOPEN_SOURCE is not defined
#endif
])
dnl ---------------------------------------------------------------------------
dnl CF__XOPEN_SOURCE_HEAD version: 2 updated: 2023/02/18 17:41:25
dnl ---------------------
dnl headers to include when test-compiling for _XOPEN_SOURCE check
define([CF__XOPEN_SOURCE_HEAD],
[
$ac_includes_default
])
