/*
 * Misc. functions for neXtaw
 *
 * Copyright 2015,2025 by Thomas E. Dickey
 * Copyright (c) 1996 Alfedo K. Kojima
 */

#ifndef _MISC_H_
#define _MISC_H_

#include <X11/IntrinsicP.h>
#include <X11/neXtaw/ThreeDP.h>

#ifdef XPM_TILE

#ifndef XtNbackgroundTile
#define XtNbackgroundTile "backgroundTile"
#endif

#ifndef XtCBackgroundTile
#define XtCBackgroundTile "BackgroundTile"
#endif

#ifndef XtRTilePixmap
#define XtRTilePixmap	"BackgroundTile"
#endif

#endif

extern void
  neXtawDrawShadowBox(Widget, ThreeDWidget, Position, Position, Position,
		      Position, Boolean);

extern Boolean
  neXtawcvtStringToTilePixmap(Display *, XrmValue *, Cardinal *,
			      XrmValuePtr, XrmValuePtr, XtPointer *);

#endif
