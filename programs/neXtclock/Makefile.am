noinst_PROGRAMS = neXtclock
neXtclock_SOURCES = clmask.bit clock.bit neXtclock.c
EXTRA_DIST = NeXtClock.ad README neXtclock.1x.html
noinst_MANS = neXtclock.1
LDADD = -L../../X11/neXtaw/.libs -lneXtaw \
	@X_LIBS@ -lXt -lX11 @X_PRE_LIBS@ @X_EXTRA_LIBS@
INCLUDES = -I../..

