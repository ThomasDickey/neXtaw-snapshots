AC_DEFUN(AC_CHECK_NEXTAW,
[
dnl Check for wide chars
AC_CHECK_HEADER(wctype.h, AC_DEFINE(HAS_WCTYPE_H))
AC_CHECK_HEADER(widec.h, , AC_DEFINE(NO_WIDEC_H))
AC_CHECK_HEADER(wchar.h, AC_DEFINE(HAS_WCHAR_H))
AC_CHECK_HEADER(X11/Xmu/Xmu.h, AC_DEFINE(HAS_XMU_H))
AC_CHECK_FUNC(wcslen, , AC_DEFINE(USE_XWCHAR_STRING))
AC_CHECK_FUNC(mbtowc, , AC_DEFINE(USE_XMBTOWC))

LDFLAGS="$LDFLAGS $X_LIBS"
dnl AC_CHECK_LIB(X11, main)
dnl AC_CHECK_LIB(Xt, main)
AC_CHECK_LIB(Xext, main)
AC_CHECK_LIB(Xmu, main)

dnl Generate warnings
if test "$GCC" = "yes"; then
        CFLAGS="-Wall $CFLAGS"
fi
])
